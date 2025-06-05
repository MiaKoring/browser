//
//  Download.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 10.12.24.
//
import SwiftUI
import CoreData

@Observable
class Progress: Equatable {
    static func == (lhs: Progress, rhs: Progress) -> Bool {
        lhs.value == rhs.value
    }
    
    var value: Double
    
    init(value: Double) {
        self.value = value
    }
}

@Observable
class DownloadManager: NSObject, URLSessionDownloadDelegate {
    var activeDownloads: [URLSessionTask: DownloadInfo] = [:]
    private var session: URLSession!
    private var resumeData: [URLSessionTask: Data] = [:]
        
    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60  // Längeres Request-Timeout
        config.timeoutIntervalForResource = 600  // 10 Minuten Gesamttimeout
        config.waitsForConnectivity = true
        config.httpMaximumConnectionsPerHost = 1 // Für stabilere große Downloads
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        session = URLSession(
            configuration: config,
            delegate: self,
            delegateQueue: .main
        )
    }
    
    func downloadFile(from url: URL, withName name: String?, referedBy: String? = nil) {
        var request = URLRequest(url: url)
        
        // Headers für große Downloads
        request.setValue("bytes=0-", forHTTPHeaderField: "Range")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.3 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        
        if let referedBy {
            request.setValue(referedBy, forHTTPHeaderField: "Referer")
        }
        
        let downloadTask = session.downloadTask(with: request)
        
        let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let filename = name ?? url.lastPathComponent
        let targetURL = downloadsDirectory.appendingPathComponent(filename)
        let downloadSidecarURL = targetURL.appendingPathExtension("download")

        activeDownloads[downloadTask] = DownloadInfo(
            originalURL: url,
            targetURL: targetURL,
            downloadURL: downloadSidecarURL,
            progress: Progress(value: 0.0),
            totalBytes: 0,
            downloadedBytes: 0,
            task: downloadTask
        )
        
        downloadTask.resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error as NSError? else { return }
        
#if DEBUG
        print("Download-Fehler: \(error.localizedDescription)")
        print("Error Domain: \(error.domain)")
        print("Error Code: \(error.code)")
#endif
        
        // Detailed Errorhandling
        if error.domain == NSURLErrorDomain {
            switch error.code {
            case NSURLErrorTimedOut,
                 NSURLErrorCancelled,
                 NSURLErrorNetworkConnectionLost:
                // Try to proceed download
                if let resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
#if DEBUG
                    print("Try to resume download")
#endif
                    let newDownloadTask = session.downloadTask(withResumeData: resumeData)
                    
                    // copy download info
                    if let originalTask = activeDownloads[task] {
                        activeDownloads[newDownloadTask] = originalTask
                    }
                    
                    newDownloadTask.resume()
                }
            default:
                print("Unhandled Error-Code: \(error.code)")
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let downloadInfo = activeDownloads[downloadTask] else {
            return
        }
        
        do {
            let targetURL = determineUniqueTargetURL(for: downloadInfo.targetURL)
            
            try FileManager.default.moveItem(at: location, to: targetURL)
            try? FileManager.default.removeItem(at: downloadInfo.downloadURL)
            
            activeDownloads.removeValue(forKey: downloadTask)
            
            saveBookmark(targetURL: downloadInfo.targetURL)
        } catch {
            print("Error while finishing download: \(error)")
        }
    }
    
    private func determineUniqueTargetURL(for originalURL: URL) -> URL {
        var targetURL = originalURL
        var suffix = 0
        
        while FileManager.default.fileExists(atPath: targetURL.path) {
            suffix += 1
            let fileExtension = targetURL.pathExtension
            let fileNameWithoutExtension = targetURL.deletingPathExtension().lastPathComponent
            
            targetURL = originalURL
                .deletingLastPathComponent()
                .appendingPathComponent("\(fileNameWithoutExtension)(\(suffix))")
                .appendingPathExtension(fileExtension)
        }
        
        return targetURL
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        guard var item = activeDownloads[downloadTask] else {
            return
        }
        
        item.progress.value = progress
        item.downloadedBytes = totalBytesWritten
        item.totalBytes = totalBytesExpectedToWrite
        
        activeDownloads[downloadTask] = item
    }
    
    func saveBookmark(targetURL: URL) {
        guard let bookmark = try? targetURL.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: [.nameKey, .contentTypeKey, .creationDateKey],
            relativeTo: nil
        ) else {
            print("failed to create Bookmark")
            return
        }
        
        DispatchQueue.main.async(execute: DispatchWorkItem(block: {
            let downloaded = DownloadedItem()
            downloaded.createdAt =  Date.now.timeIntervalSinceReferenceDate
            downloaded.bookmark = bookmark
            CDDownloadsController.insert(downloaded)
        }))
    }
}
