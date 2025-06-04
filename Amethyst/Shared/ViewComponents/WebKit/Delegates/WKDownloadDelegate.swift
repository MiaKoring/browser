//
//  WKDownloadDelegate.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 04.12.24.
//
import WebKit
import Foundation

class DownloadDelegate: NSObject, WKDownloadDelegate {
    func webView(
        _ webView: WKWebView,
        navigationAction: WKNavigationAction,
        didBecome download: WKDownload
    ) {
        print("Download started from navigationAction: \(download.originalRequest?.url?.lastPathComponent ?? "unknown")")
        download.delegate = self // Set the delegate for this specific download's progress
        // Here you can update your UI to show a download is in progress
        // You might want to create a DownloadItem model and add it to a list
    }
    
    func webView(
        _ webView: WKWebView,
        navigationResponse: WKNavigationResponse,
        didBecome download: WKDownload
    ) {
        print("Download started from navigationResponse: \(download.originalRequest?.url?.lastPathComponent ?? "unknown")")
        download.delegate = self
    }
    
    func download(
        _ download: WKDownload,
        decideDestinationUsing response: URLResponse,
        suggestedFilename: String
    ) async -> URL? {
        if let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            let url = downloadsURL.appendingPathComponent(suggestedFilename)
            return url
        }
        return nil
    }
}
