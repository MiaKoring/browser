//
//  WebView.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import SwiftUI
import WebKit
import CryptoTokenKit

struct WebViewNS: NSViewRepresentable {
    @ObservedObject var viewModel: WebViewModel
    
    func makeNSView(context: Context) -> WKWebView {
        return viewModel.getWebView()
    }
    
    func updateNSView(_ uiView: WKWebView, context: Context) {
        
    }
}

