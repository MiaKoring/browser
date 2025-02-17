//
//  Download.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 10.12.24.
//
import SwiftUI
import SwiftData

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
    struct DownloadInfo {
        let originalURL: URL
        let targetURL: URL
        let downloadURL: URL
        var progress: Progress
        var totalBytes: Int64
        var downloadedBytes: Int64
    }
    
    var activeDownloads: [URLSessionTask: DownloadInfo] = [:]
    private var session: URLSession!
        
    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }
    
    func downloadFile(from url: URL, withName name: String?) {
        let downloadTask = session.downloadTask(with: url)
        
        let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        
        let filename = url.lastPathComponent
        let targetURL: URL = downloadsDirectory.appendingPathComponent(name ?? filename)
        let downloadSidecarURL = targetURL.appendingPathExtension("download")

        activeDownloads[downloadTask] = DownloadInfo(
            originalURL: url,
            targetURL: targetURL,
            downloadURL: downloadSidecarURL,
            progress: Progress(value: 0.0),
            totalBytes: 0,
            downloadedBytes: 0
        )
        
        downloadTask.resume()
    }
    
    private func updateDownload(for task: URLSessionTask, progress: Double, downloadedBytes: Int64, totalBytes: Int64) {
        guard var downloadInfo = activeDownloads[task] else { return }
        
        downloadInfo.progress.value = progress
        downloadInfo.downloadedBytes = downloadedBytes
        downloadInfo.totalBytes = totalBytes
        activeDownloads[task] = downloadInfo
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let downloadInfo = activeDownloads[downloadTask] else {
            print("couldn't get active download info")
            return
        }
        
        do {
            var targetURL = downloadInfo.targetURL
            var suffix = 0
            
            while FileManager.default.fileExists(atPath: targetURL.path) {
                suffix += 1
                let fileExtension = targetURL.pathExtension
                let fileNameWithoutExtension = targetURL.deletingPathExtension().lastPathComponent
                
                targetURL = downloadInfo.targetURL
                    .deletingLastPathComponent()
                    .appendingPathComponent("\(fileNameWithoutExtension.replacing(/\(\d*\)/, with: ""))(\(suffix))")
                    .appendingPathExtension(fileExtension)
            }
            try FileManager.default.moveItem(at: location, to: targetURL)
            
            try? FileManager.default.removeItem(at: downloadInfo.downloadURL)
            
            
            activeDownloads.removeValue(forKey: downloadTask)
            
            guard let bookmark = try? targetURL.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: [.nameKey, .contentTypeKey, .creationDateKey],
                relativeTo: nil
            ) else {
                print("failed to create Bookmark")
                return
            }
            DispatchQueue.main.async(execute: DispatchWorkItem(block: {
                do {
                    let context = try ModelContext(ModelContainer(for: SavedTab.self, BackForwardListItem.self, HistoryItem.self, HistoryDay.self, FavouriteItem.self, DownloadedItem.self, migrationPlan: TabMigration.self))
                    let downloaded = DownloadedItem(bookmark: bookmark, createdAt: Date.now.timeIntervalSinceReferenceDate)
                    context.insert(downloaded)
                    try context.save()
                    print(downloaded.createdAt)
                    print(downloaded.bookmark)
                } catch {
                    print("error: \(error)")
                }
                
            }))
        } catch {
            print("Download-Fehler: \(error.localizedDescription)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let originalURL = downloadTask.originalRequest?.url else { return }
                
        let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let filename = originalURL.lastPathComponent
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        updateDownload(for: downloadTask, progress: progress, downloadedBytes: totalBytesWritten, totalBytes: totalBytesExpectedToWrite)
    }
}

