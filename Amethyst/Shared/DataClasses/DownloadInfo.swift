

import Foundation

struct DownloadInfo {
    let originalURL: URL
    let targetURL: URL
    let downloadURL: URL
    var progress: Progress
    var totalBytes: Int64
    var downloadedBytes: Int64
    
    let task: URLSessionTask
}
