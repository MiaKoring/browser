//
//  WKUIDelegate.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 04.12.24.
//
import WebKit

extension WebViewModel: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let customAction = (webView as? AWKWebView)?.contextualMenuAction {
            switch customAction {
            case .openInNewTab:
                return openInNewTab(configuration: configuration)
            case .openInBackground:
                let newWebViewModel = WebViewModel(config: configuration, contentViewModel: contentViewModel, appViewModel: appViewModel)
                let newTab = ATab(webViewModel: newWebViewModel)
                contentViewModel.tabs.append(newTab)
                return newWebViewModel.webView
            case .openInNewWindow:
                guard let url = navigationAction.request.url, let open = appViewModel.openWindowByID else { return nil }
                appViewModel.newURLToOpen = url
                open("mainWindow")
                return nil
            }
        } else if navigationAction.targetFrame == nil && !navigationAction.shouldPerformDownload {
            return openInNewTab(configuration: configuration)
        } else {
            return nil
        }
    }
    
    func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo) async -> [URL]? {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = parameters.allowsMultipleSelection
        
        let response = await openPanel.begin()

        if response == .OK {
            return openPanel.urls
        } else {
            return nil
        }
    }
    
    private func openInNewTab(configuration: WKWebViewConfiguration) -> WKWebView? {
        let newWebViewModel = WebViewModel(config: configuration, contentViewModel: contentViewModel, appViewModel: appViewModel)
        let newTab = ATab(webViewModel: newWebViewModel)
        if let index = contentViewModel.tabs.firstIndex(where: {$0.id == contentViewModel.currentTab}) {
            contentViewModel.tabs.insert(newTab, at: index + 1)
        } else {
            contentViewModel.tabs.append(newTab)
        }
        contentViewModel.currentTab = newTab.id
        return newWebViewModel.webView
    }
}
