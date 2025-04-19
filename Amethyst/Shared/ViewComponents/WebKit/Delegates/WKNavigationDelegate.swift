//
//  NavigationDelegate.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 04.12.24.
//
import SwiftData
@preconcurrency import WebKit

extension WebViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        print("Decide Policy: \(navigationAction.request.allHTTPHeaderFields)")
        
        //safes referer, so downloads which expect a referer still work. Only updates if Referer is set in the hope, that sites which don't need a referer header also don't block if one is set.
        if let referer = navigationAction.request.allHTTPHeaderFields?["Referer"] {
            self.referer = referer
        }
        
        if let _ = navigationAction.request.url, contentViewModel.isLoaded {
            switch navigationAction.navigationType {
            case .reload, .backForward, .formResubmitted, .formSubmitted:
                cache = nil
                break
            case .linkActivated:
                cache = true
            case .other:
                cache = true
            @unknown default:
                cache = nil
                break
            }
        }
        if navigationAction.shouldPerformDownload {
            return .download
        }
        return .allow
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse,
           let mimeType = response.mimeType,
           blockDownloadCheckforURL != navigationResponse.response.url,
           (mimeType == "application/octet-stream" || mimeType == "binary/octet-stream" || (response.allHeaderFields["Content-Disposition"] as? String)?.contains("attachment") ?? false || (response.allHeaderFields["Content-Type"] as? String)?.contains("application") ?? false) {
            decisionHandler(.cancel)
            pendingDownload = PendingDownload(navigationResponse: navigationResponse)
        } else {
            blockDownloadCheckforURL = nil
            decisionHandler(.allow)
        }
        if let response = navigationResponse.response as? HTTPURLResponse {
            print("Decide Policy for response: \(response.allHeaderFields)")
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        if let urlStr = (error as NSError).userInfo[NSURLErrorFailingURLStringErrorKey] as? String, let url = URL(string: urlStr) {
            print("Error: \(url.absoluteString)")
            self.currentURL = url
        }
        if error.localizedDescription.contains("NSURLErrorDomain error -999") { return }
        if ErrorIgnoreManager.isURLErrorIgnored(error) { return }
        self.error = error
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        if let urlStr = (error as NSError).userInfo[NSURLErrorFailingURLStringErrorKey] as? String, let url = URL(string: urlStr) {
            print("Error: \(url.absoluteString)")
            print(error.localizedDescription)
            self.currentURL = url
        }
        
        if error.localizedDescription.contains("NSURLErrorDomain error -999") { return }
        if ErrorIgnoreManager.isURLErrorIgnored(error) { return }
        
        self.error = error
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        error = nil
        appendHistory()
    }
}
