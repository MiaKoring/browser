

import Foundation

@Observable
class DownloadInfo {
    let originalURL: URL
    let targetURL: URL
    let downloadURL: URL
    var task: URLSessionTask
    
    var progress: Double = 0.0
    var totalBytes: Int64 = 0
    var downloadedBytes: Int64 = 0
    
    init(originalURL: URL, targetURL: URL, downloadURL: URL, task: URLSessionTask) {
        self.originalURL = originalURL
        self.targetURL = targetURL
        self.downloadURL = downloadURL
        self.task = task
    }
}
