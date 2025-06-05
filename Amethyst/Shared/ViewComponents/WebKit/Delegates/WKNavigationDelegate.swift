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
            if let url = navigationAction.request.url, url.scheme != "blob" {
                appViewModel.downloadManager?.downloadFile(from: url, withName: url.lastPathComponent, referedBy: self.referer)
                return .cancel
            }
            return .download
        }
        return .allow
    }
    
    // Diese Methode ist der Hauptort, um Downloads basierend auf der Server-Antwort zu erkennen.
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationResponse: WKNavigationResponse,
            decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
        ) {
            guard let httpResponse = navigationResponse.response as? HTTPURLResponse,
                  let url = httpResponse.url else {
                decisionHandler(.allow)
                return
            }

            print("Decide Policy for Response: \(url.absoluteString)")
            print("Response MIMEType: \(httpResponse.mimeType ?? "N/A")")
            print("Response canShowMIMEType: \(navigationResponse.canShowMIMEType)")

            // Blockiere nicht, wenn wir es schon für diese URL tun/getan haben (deine Logik)
            if blockDownloadCheckforURL == url {
                 // decisionHandler(.allow) // Überdenke diese Logik. Wenn es ein Download ist, sollte es einer bleiben.
                                         // Vielleicht willst du hier eher nichts tun oder .cancel, wenn es schon läuft.
            }

            var isDownload = false
            var suggestedFilename = url.lastPathComponent // Fallback

            // 1. Content-Disposition: attachment ist ein starker Indikator
            let dispositionKey = httpResponse.allHeaderFields.keys.first { ($0 as? String)?.lowercased() == "content-disposition" }
            if let key = dispositionKey,
               let disposition = httpResponse.allHeaderFields[key] as? String,
               disposition.lowercased().contains("attachment") {
                isDownload = true
                suggestedFilename = parseFilename(from: disposition) ?? url.lastPathComponent
                print("Response: Content-Disposition attachment found. Filename: \(suggestedFilename)")
            }

            // 2. WebKit kann den MIME-Typ nicht anzeigen (wenn nicht schon durch Content-Disposition erkannt)
            if !isDownload && !navigationResponse.canShowMIMEType {
                isDownload = true
                print("Response: Cannot show MIMEType (\(httpResponse.mimeType ?? "")).")
                // Hier könnten wir auch versuchen, den Dateinamen aus Content-Disposition zu holen,
                // falls er vorhanden ist, auch wenn canShowMIMEType false ist.
                if let key = dispositionKey,
                   let disposition = httpResponse.allHeaderFields[key] as? String {
                    suggestedFilename = parseFilename(from: disposition) ?? url.lastPathComponent
                }
            }

            // 3. Spezifische MIME-Typen, die fast immer Downloads sind (wenn nicht schon erkannt)
            if !isDownload, let mimeType = httpResponse.mimeType?.lowercased() {
                let knownDownloadMimeTypes = [
                    "application/octet-stream",
                    "binary/octet-stream",
                    "application/zip",
                    "application/x-zip-compressed",
                    "application/x-rar-compressed",
                    "application/gzip",
                    "application/x-tar",
                    // Füge weitere hinzu, die für dich relevant sind
                ]
                if knownDownloadMimeTypes.contains(mimeType) {
                    isDownload = true
                    print("Response: Known download MIMEType \(mimeType).")
                    if let key = dispositionKey,
                       let disposition = httpResponse.allHeaderFields[key] as? String {
                        suggestedFilename = parseFilename(from: disposition) ?? url.lastPathComponent
                    }
                }
            }

            if isDownload {
                blockDownloadCheckforURL = url
                // Markiere diese URL (deine Logik)
                if url.scheme != "blob" {
                    decisionHandler(.cancel) // Verhindere, dass WebKit den Inhalt anzeigt/herunterlädt
                    
                    // Starte deinen eigenen Download-Manager
                    // Stelle sicher, dass sharedDownloadManager hier verfügbar ist
                    print("Initiating custom download for \(url) with suggested name: \(suggestedFilename)")
                    appViewModel.downloadManager?.downloadFile(from: url, withName: suggestedFilename, referedBy: self.referer)
                    return
                }
                decisionHandler(.download)
            } else {
                blockDownloadCheckforURL = nil
                decisionHandler(.allow)
            }
        }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if let urlStr = nsError.userInfo[NSURLErrorFailingURLStringErrorKey] as? String, let url = URL(string: urlStr) {
            Self.logger.debug("Error (didFail navigation): \(url.absoluteString) - \(error.localizedDescription)")
            self.currentURL = url
        } else {
            Self.logger.info("Error (didFail navigation): \(error.localizedDescription)")
        }
        
        // NSURLErrorCancelled (-999) is common and often not a "real" error for the user.
        // It can happen if a new navigation starts before a previous one finishes.
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            Self.logger.info("Navigation was cancelled (likely by a new navigation action or download decision).")
            return
        }
        if ErrorIgnoreManager.isURLErrorIgnored(error) { return } // Assuming this is your custom logic
        self.error = error
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if let urlStr = nsError.userInfo[NSURLErrorFailingURLStringErrorKey] as? String, let url = URL(string: urlStr) {
            Self.logger.debug("Error (didFailProvisionalNavigation): \(url.absoluteString) - \(error.localizedDescription)")
            self.currentURL = url
        } else {
            Self.logger.debug("Error (didFailProvisionalNavigation): \(error.localizedDescription)")
        }
        
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            Self.logger.info("Provisional navigation was cancelled.")
            return
        }
        if ErrorIgnoreManager.isURLErrorIgnored(error) { return }
        self.error = error
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Self.logger.info("DidFinish Navigation for: \(webView.url?.absoluteString ?? "N/A")")
        error = nil
        appendHistory()
        // Potentially clear blockDownloadCheckforURL here if the main frame finished loading
        // blockDownloadCheckforURL = nil
    }
    
    
    // Helper function to parse filename from content disposition header
    private func parseFilename(from contentDisposition: String) -> String? {
        // Example: "attachment; filename=\"example.zip\""
        // Example: "attachment; filename*=UTF-8''example%20%C3%A4%20.zip"
        let components = contentDisposition.split(separator: ";").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        for component in components {
            if component.lowercased().starts(with: "filename*=") { // Prefer filename*
                // Format: filename*=charset''encoded-value
                // e.g. filename*=UTF-8''example%20%C3%A4%20.zip
                if let encodedPart = component.split(separator: "''", maxSplits: 1).last {
                    return String(encodedPart).removingPercentEncoding
                }
            } else if component.lowercased().starts(with: "filename=") {
                // Format: filename="value" or filename=value
                var filename = component.dropFirst("filename=".count)
                if filename.hasPrefix("\"") && filename.hasSuffix("\"") {
                    filename = filename.dropFirst().dropLast()
                }
                return String(filename)
            }
        }
        return nil
    }
}
