//
//  KeybindFunctions.swift
//  Amethyst Project
//
//  Created by Mia Koring on 11.06.25.
//
import SwiftUI

extension Keybind {
    func toggleSidebar(fix: Bool = false, _ appViewModel: AppViewModel, _ contentViewModels: (ContentViewModel, ContentViewModel, ContentViewModel)) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId, contentViewModels: contentViewModels) else { return }
        if !fix {
            withAnimation(.linear(duration: 0.1)) {
                if contentViewModel.isSidebarFixed {
                    contentViewModel.isSidebarFixed = false
                    contentViewModel.isSidebarShown = false
                } else {
                    contentViewModel.isSidebarShown.toggle()
                }
            }
            return
        }
        contentViewModel.isSidebarShown = false
        withAnimation(.linear(duration: 0.1)) {
            contentViewModel.isSidebarFixed.toggle()
        }
    }
    
    func search(_ appViewModel: AppViewModel, _ contentViewModels: (ContentViewModel, ContentViewModel, ContentViewModel)) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId, contentViewModels: contentViewModels) else { return }
        contentViewModel.showInlineSearch.toggle()
    }
    
    func showHistory(_ appViewModel: AppViewModel, _ contentViewModels: (ContentViewModel, ContentViewModel, ContentViewModel)) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId, contentViewModels: contentViewModels) else { return }
        contentViewModel.showHistory.toggle()
    }
    
    func zoom(enlarge: Bool = true, _ appViewModel: AppViewModel, _ contentViewModels: (ContentViewModel, ContentViewModel, ContentViewModel)) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId, contentViewModels: contentViewModels), let webViewModel = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab})?.webViewModel else { return }
        webViewModel.webView?.evaluateJavaScript("document.body.style.zoom = (parseFloat(document.body.style.zoom || 1.0) \(enlarge ? "+": "-") 0.1)") { (result, error) in
            if let error = error {
                print("Zoom \(enlarge ? "in": "out") error: \(error)")
            }
        }
    }
    
    func resetZoom(_ appViewModel: AppViewModel, _ contentViewModels: (ContentViewModel, ContentViewModel, ContentViewModel)) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId, contentViewModels: contentViewModels), let webViewModel = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab})?.webViewModel else { return }
        webViewModel.webView?.evaluateJavaScript("document.body.style.zoom = 1.0") { (result, error) in
            if let error = error {
                print("Zoom reset error: \(error)")
            }
        }
    }
    
    func toggleSidebarOrientation(_ appViewModel: AppViewModel, _ contentViewModels: (ContentViewModel, ContentViewModel, ContentViewModel)) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId, contentViewModels: contentViewModels) else {
            print("No contentviewmodel")
            return
        }
        contentViewModel.sidebarOrientation = contentViewModel.sidebarOrientation.other
    }
    
    func createNewWindow(_ appViewModel: AppViewModel, _ contentViewModels: (ContentViewModel, ContentViewModel, ContentViewModel), _ openWindow: OpenWindowAction) {
        if !appViewModel.displayedWindows.contains("window1") {
            contentViewModels.0.currentTab = contentViewModels.0.tabs.first?.id
            openWindow(id: "window1")
        } else if !appViewModel.displayedWindows.contains("window2") {
            contentViewModels.1.currentTab = contentViewModels.1.tabs.first?.id
            openWindow(id: "window2")
        } else if !appViewModel.displayedWindows.contains("window3") {
            contentViewModels.2.currentTab = contentViewModels.2.tabs.first?.id
            openWindow(id: "window3")
        }
    }
    
    func togglePasswordSidebar(fix: Bool = false, _ appViewModel: AppViewModel, _ contentViewModels: (ContentViewModel, ContentViewModel, ContentViewModel)) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId, contentViewModels: contentViewModels) else { return }
        if !fix {
            withAnimation(.linear(duration: 0.1)) {
                if contentViewModel.isPasswordFixed {
                    contentViewModel.isPasswordFixed = false
                    contentViewModel.isPasswordShown = false
                } else {
                    contentViewModel.isPasswordShown.toggle()
                }
            }
            return
        }
        contentViewModel.isPasswordShown = false
        withAnimation(.linear(duration: 0.1)) {
            contentViewModel.isPasswordFixed.toggle()
        }
    }
    
    func newTab(_ appViewModel: AppViewModel, _ contentViewModels: (ContentViewModel, ContentViewModel, ContentViewModel)) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId, contentViewModels: contentViewModels) else { return }
        contentViewModel.triggerNewTab.toggle()
    }
    
    func navigate(back: Bool = true, _ appViewModel: AppViewModel, _ contentViewModels: (ContentViewModel, ContentViewModel, ContentViewModel)) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId, contentViewModels: contentViewModels) else { return }
        if let model = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab})?.webViewModel {
            if back {
                model.goBack()
            } else {
                model.goForward()
            }
        }
    }
    
    func navigateTabs(back: Bool = true, _ appViewModel: AppViewModel, _ contentViewModels: (ContentViewModel, ContentViewModel, ContentViewModel)) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId, contentViewModels: contentViewModels), contentViewModel.tabs.count > 0 else { return }
        if let currentTab = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab}) {
            currentTab.webViewModel.removeHighlights()
        }
        contentViewModel.showInlineSearch = false
        if back {
            guard let _ = contentViewModel.currentTab, let index = contentViewModel.tabs.firstIndex(where: {$0.id == contentViewModel.currentTab}) else {
                contentViewModel.currentTab = contentViewModel.tabs[0].id
                return
            }
            contentViewModel.currentTab = contentViewModel.tabs[max(0, index - 1)].id
            return
        }
        guard let index = contentViewModel.tabs.firstIndex(where: {$0.id == contentViewModel.currentTab}) else {
            contentViewModel.currentTab = contentViewModel.tabs[contentViewModel.tabs.count - 1].id
            return
        }
        contentViewModel.currentTab = contentViewModel.tabs[min(contentViewModel.tabs.count - 1, index + 1)].id
    }
    
    func closeCurrentTab(_ appViewModel: AppViewModel, _ contentViewModels: (ContentViewModel, ContentViewModel, ContentViewModel)) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId, contentViewModels: contentViewModels) else { return }
        
        withAnimation(.linear(duration: 0.2)) {
            guard let id = contentViewModel.currentTab else { return }
            contentViewModel.closeTab(id: id)
        }
    }
    
    func reload(fromSource: Bool = false, _ appViewModel: AppViewModel, _ contentViewModels: (ContentViewModel, ContentViewModel, ContentViewModel)) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId, contentViewModels: contentViewModels) else { return }
        if let tab = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab}) {
            if !fromSource {
                tab.webViewModel.webView?.reload()
            } else {
                tab.webViewModel.webView?.reloadFromOrigin()
            }
        }
    }
}
