//
//  NavigationDelegate.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 04.12.24.
//
import SwiftData
@preconcurrency import WebKit
import OSLog

extension WebViewModel: WKNavigationDelegate {
    static let logger = Logger(subsystem: AmethystApp.subSystem, category: "WebViewModel")
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        Self.logger.debug("Decide Policy: \(navigationAction.request.allHTTPHeaderFields ?? [:])")
        
        //safes referer, so downloads which expect a referer still work. Only updates if Referer is set in the hope that sites which don't need a referer header also don't block if one is set.
        if let referer = navigationAction.request.allHTTPHeaderFields?["Referer"] {
            self.referer = referer
        }
        
        if let _ = navigationAction.request.url, contentViewModel.isLoaded {
            switch navigationAction.navigationType {
            case .reload, .backForward, .formResubmitted, .formSubmitted:
                cache = nil
            case .linkActivated, .other:
                cache = true
            @unknown default:
                cache = nil
            }
        }
        if navigationAction.shouldPerformDownload {
            Self.logger.info("Action: WebKit suggests download for \(navigationAction.request.url?.absoluteString ?? "N/A")")
            return .download
        }
        return .allow
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let httpResponse = navigationResponse.response as? HTTPURLResponse,
              let url = httpResponse.url else {
            decisionHandler(.allow)
            return
        }
        #if DEBUG
        print("Decide Policy for Response: \(url.absoluteString)")
        print("Response Headers: \(httpResponse.allHeaderFields)")
        print("Response MIMEType: \(httpResponse.mimeType ?? "N/A")")
        print("Response canShowMIMEType: \(navigationResponse.canShowMIMEType)")
        #endif
        
        if blockDownloadCheckforURL == url {
            decisionHandler(.allow)
            return
        }
        
        // 1. Check if WebKit can show the MIME type
        // This is a very strong indicator. If WebKit can't show it, it's likely a download.
        if !navigationResponse.canShowMIMEType {
            Self.logger.debug("Response: Cannot show MIMEType for \(url.absoluteString) (\(httpResponse.mimeType ?? "")). Treating as download.")
            blockDownloadCheckforURL = url //mark as processed for download
            decisionHandler(.download)
            return
        }
        
        // 2. Check for Content-Disposition: attachment
        // Case-insensitive check for "Content-Disposition" header
        let dispositionKey = httpResponse.allHeaderFields.keys.first { ($0 as? String)?.caseInsensitiveCompare("content-disposition") == .orderedSame }
        if let key = dispositionKey,
           let disposition = httpResponse.allHeaderFields[key] as? String,
           disposition.lowercased().contains("attachment") {
            Self.logger.info("Response: Content-Disposition attachment found for \(url.absoluteString). Treating as download.")
            blockDownloadCheckforURL = url
            decisionHandler(.download)
            return
        }
        
        // 3. Check for specific "download-only" MIME types (use sparingly and be specific)
        // This is a fallback if the above checks didn't catch it.
        if let mimeType = httpResponse.mimeType?.lowercased() {
            let knownDownloadMimeTypes = [
                "application/octet-stream", // Generic binary
                "binary/octet-stream",      // Another generic binary
                "application/zip",
                "application/x-zip-compressed",
                "application/x-rar-compressed",
                "application/gzip",
                "application/x-tar"
                // Add other specific types that are *definitely* downloads
                // and *not* viewable (e.g., executables, specific archive formats).
                // Avoid broad "application/*" here.
            ]
            if knownDownloadMimeTypes.contains(mimeType) {
                // Double-check: even if it's a known download MIME type,
                // if canShowMIMEType was true (e.g., a PDF plugin exists for application/pdf),
                // we might have allowed it earlier. This check is for cases where
                // canShowMIMEType might be true but it's still semantically a download.
                // However, `!canShowMIMEType` should ideally catch most of these.
                print("Response: Known download MIMEType \(mimeType) for \(url.absoluteString). Treating as download.")
                blockDownloadCheckforURL = url
                if #available(iOS 14.5, macOS 11.3, *) {
                    decisionHandler(.download)
                } else {
                    decisionHandler(.cancel)
                    self.pendingDownload = PendingDownload(navigationResponse: navigationResponse)
                }
                return
            }
        }
        
        blockDownloadCheckforURL = nil
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if let urlStr = nsError.userInfo[NSURLErrorFailingURLStringErrorKey] as? String, let url = URL(string: urlStr) {
            print("Error (didFail navigation): \(url.absoluteString) - \(error.localizedDescription)")
            self.currentURL = url
        } else {
            print("Error (didFail navigation): \(error.localizedDescription)")
        }

        // NSURLErrorCancelled (-999) is common and often not a "real" error for the user.
        // It can happen if a new navigation starts before a previous one finishes.
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            print("Navigation was cancelled (likely by a new navigation action or download decision).")
            return
        }
        if ErrorIgnoreManager.isURLErrorIgnored(error) { return } // Assuming this is your custom logic
        self.error = error
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if let urlStr = nsError.userInfo[NSURLErrorFailingURLStringErrorKey] as? String, let url = URL(string: urlStr) {
            print("Error (didFailProvisionalNavigation): \(url.absoluteString) - \(error.localizedDescription)")
            self.currentURL = url
        } else {
            print("Error (didFailProvisionalNavigation): \(error.localizedDescription)")
        }

        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            print("Provisional navigation was cancelled.")
            return
        }
        if ErrorIgnoreManager.isURLErrorIgnored(error) { return }
        self.error = error
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("DidFinish Navigation for: \(webView.url?.absoluteString ?? "N/A")")
        error = nil
        appendHistory()
        // Potentially clear blockDownloadCheckforURL here if the main frame finished loading
        // blockDownloadCheckforURL = nil
    }
}
