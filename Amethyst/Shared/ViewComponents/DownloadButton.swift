//
//  DownloadButton.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 11.12.24.
//
/*
import SwiftUI
import WebKit

struct DownloadButton: View {
    @Environment(AppViewModel.self) var appViewModel
    @ObservedObject var webViewModel: WebViewModel
    var body: some View {
        if let url = webViewModel.currentURL,  let end = url.lastPathComponent.split(separator: "?").first?.suffix(4),
            [".pdf", ".doc", ".xls", ".ppt", ".txt", ".rtf", ".odt",
             ".jpg", ".png", ".gif", ".svg", ".bmp",
             ".mp3", ".wav", ".mp4", ".avi", ".mkv",
             ".zip", ".tar", ".rar",
             ".csv", ".sql", ".xml"]
            .contains(end) {
            Image(systemName: "arrow.down.app.fill")
                .font(.largeTitle)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .myPurple)
                .padding()
                .onTapGesture {
                    if let url = webViewModel.currentURL {
                        appViewModel.downloadManager?.downloadFile(from: url, withName: nil)
                    }
                }
        }
    }
}
*/
