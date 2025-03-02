//
//  Untitled.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//

import SwiftUI
import WebKit

extension TabOpener {
    func handleInputBarSubmit(text: String, tabID: UUID? = nil) {
        do {
            if text == ":q" {
                try context.delete(model: SavedTab.self)
                dismissWindow()
                return
            } else if text == ":clear" {
                contentViewModel.tabs = []
                contentViewModel.currentTab = nil
                return
            }
        } catch {
            print("deletings models failed")
        }
        print(text)
        
        if let _ = text.wholeMatch(of: Regexpr.url.regex) {
            processURL(text: text, tabID: tabID, hasProtocol: true)
        } else if let _ = text.wholeMatch(of: Regexpr.urlWithoutProtocol.regex) {
            processURL(text: text, tabID: tabID)
        } else if let _ = text.wholeMatch(of: Regexpr.ip.regex) {
            processURL(text: text, tabID: tabID, hasProtocol: true)
        } else if let _ = text.wholeMatch(of: Regexpr.ipWithoutProtocol.regex) {
            processURL(text: text, tabID: tabID)
        } else if let _ = text.wholeMatch(of: Regexpr.localhost.regex){
            let text = text.replacingOccurrences(of: "localhost", with: "127.0.0.1", range: text.firstRange(of: "localhost"))
            processURL(text: text, tabID: tabID, hasProtocol: true)
        } else if let _ = text.wholeMatch(of: Regexpr.localhostWithoutProtocol.regex){
            let text = text.replacingOccurrences(of: "localhost", with: "127.0.0.1", range: text.firstRange(of: "localhost"))
            processURL(text: "http://\(text)", tabID: tabID, hasProtocol: true)
        } else {
            processURL(text: text, tabID: tabID, searchEngine: true)
        }
    }
    
    private func processURL(text: String, tabID: UUID?, hasProtocol: Bool = false, searchEngine: Bool = false) {
        let vm = WebViewModel(processPool: contentViewModel.wkProcessPool, contentViewModel: contentViewModel, appViewModel: appViewModel)
        var url: URL? = nil
        if !searchEngine {
            vm.load(urlString: "\(hasProtocol ? "": "https://")\(text)")
        } else {
            let searchEngine = SearchEngine(rawValue: UDKey.searchEngine.intValue) ?? .duckduckgo
            url = searchEngine.makeSearchUrl(text)
            vm.load(urlString: url?.absoluteString ?? "")
        }
        if let tabID {
            guard let index = contentViewModel.tabs.firstIndex(where: {$0.id == tabID}) else {
                return
            }
            if !searchEngine {
                contentViewModel.tabs[index].webViewModel.load(urlString: "\(hasProtocol ? "": "https://")\(text)")
            } else {
                contentViewModel.tabs[index].webViewModel.load(urlString: url?.absoluteString ?? "")
            }
        } else {
            let tab = ATab(webViewModel: vm, restoredURLs: [])
            contentViewModel.tabs.append(tab)
            contentViewModel.currentTab = tab.id
        }
    }
}
