//
//  Download.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 10.12.24.
//
import SwiftUI
import CoreData
import OSLog

@Observable
class DownloadManager: NSObject, URLSessionDownloadDelegate {
    var activeDownloads: [URLSessionTask: DownloadInfo] = [:]
    private var session: URLSession!
    
    private static var logger = Logger(subsystem: AmethystApp.subSystem, category: "DownloadManager")
        
    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60  // Longer Request-Timeout
        config.timeoutIntervalForResource = 600  // 10 minutes full timeout
        config.waitsForConnectivity = true
        config.httpMaximumConnectionsPerHost = 1 // for more stable, bigger downloads
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        self.session = URLSession(
            configuration: config,
            delegate: self,
            delegateQueue: .main
        )
    }
    
    func downloadFile(from url: URL, withName name: String?, referedBy: String? = nil) {
        var request = URLRequest(url: url)
        
        // Headers für download request
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
            task: downloadTask
        )
        
        downloadTask.resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error as NSError? else { return }
        
        Self.logger.error("""
Download-Error: \(error.localizedDescription)
Error Domain: \(error.domain)
Error Code: \(error.code)
""")
        
        // check if download can be resumed
        if error.domain == NSURLErrorDomain, let resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
            // Try to proceed download
            Self.logger.info("Attempting to resume download for task: \(task.taskIdentifier)")
            
            // copy download info
            guard let oldDownloadInfo = activeDownloads.removeValue(forKey: task) else {
                return
            }
            
            let newDownloadTask = session.downloadTask(withResumeData: resumeData)
            
            oldDownloadInfo.task = newDownloadTask
            activeDownloads[newDownloadTask] = oldDownloadInfo
            
            newDownloadTask.resume()
            
        } else {
            activeDownloads.removeValue(forKey: task)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let downloadInfo = activeDownloads[downloadTask] else {
            Self.logger.warning("Finished download for an untracked task: \(downloadTask.taskIdentifier)")
            return
        }
        
        do {
            // Ensure the final destination URL is unique to avoid overwriting files.
            let uniqueTargetURL = determineUniqueTargetURL(for: downloadInfo.targetURL)
            
            try FileManager.default.moveItem(at: location, to: uniqueTargetURL)
            // Clean up the .download sidecar file.
            try? FileManager.default.removeItem(at: downloadInfo.downloadURL)
            
            saveBookmark(targetURL: downloadInfo.targetURL)
        } catch {
            Self.logger.error("Error finishing download: \(error)")
        }
        activeDownloads.removeValue(forKey: downloadTask)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let downloadInfo = activeDownloads[downloadTask] {
            downloadInfo.progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            downloadInfo.downloadedBytes = totalBytesWritten
            downloadInfo.totalBytes = totalBytesExpectedToWrite
        }
    }
    
    private func determineUniqueTargetURL(for originalURL: URL) -> URL {
        var targetURL = originalURL
        let fileManager = FileManager.default
        var suffix = 0
        
        let fileExtension = originalURL.pathExtension
        let fileNameWithoutExtension = originalURL.deletingPathExtension().lastPathComponent
        let directory = originalURL.deletingLastPathComponent()
        
        while fileManager.fileExists(atPath: targetURL.path) {
            suffix += 1
            let newFileName = "\(fileNameWithoutExtension) (\(suffix))"
            targetURL = directory
                .appendingPathComponent(newFileName)
                .appendingPathExtension(fileExtension)
        }
        
        return targetURL
    }
    
    private func saveBookmark(targetURL: URL) {
        do {
            let bookmark = try targetURL.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: [.nameKey, .contentTypeKey, .creationDateKey],
                relativeTo: nil
            )
            let downloaded = DownloadedItem()
            downloaded.createdAt =  Date.now.timeIntervalSinceReferenceDate
            downloaded.bookmark = bookmark
            CDDownloadsController.insert(downloaded)
        } catch {
            Self.logger.error("failed to create Bookmark with Error: \(error.localizedDescription)")
        }
    }
}
