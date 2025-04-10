//
//  AmethystAppFunctions.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 30.11.24.
//

import SwiftUI
import MeiliSearch

extension AmethystApp {
    func createNewWindow() {
        if !appViewModel.displayedWindows.contains("window1") {
            contentViewModel.currentTab = contentViewModel.tabs.first?.id
            openWindow(id: "window1")
        } else if !appViewModel.displayedWindows.contains("window2") {
            contentViewModel2.currentTab = contentViewModel.tabs.first?.id
            openWindow(id: "window2")
        } else if !appViewModel.displayedWindows.contains("window3") {
            contentViewModel3.currentTab = contentViewModel.tabs.first?.id
            openWindow(id: "window3")
        }
    }
    
    func toggleSidebar(fix: Bool = false) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return }
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
    
    func togglePasswordSidebar(fix: Bool = false) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return }
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
    
    func newTab() {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return }
        contentViewModel.triggerNewTab.toggle()
    }
    
    func navigate(back: Bool = true) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return }
        if let model = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab})?.webViewModel {
            if back {
                model.goBack()
            } else {
                model.goForward()
            }
        }
    }
    
    func navigateTabs(back: Bool = true) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId), contentViewModel.tabs.count > 0 else { return }
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
    
    func closeCurrentTab() {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else {
            return
        }
        contentViewModel.handleClose()
    }
    
    func tabSwitchingDisabled(back: Bool = true) -> Bool {
        let currentWindow = appViewModel.currentlyActiveWindowId
        guard let contentViewModel = contentViewModel(for: currentWindow) else { return true }
        let tabCount = contentViewModel.tabs.count
        return tabCount <= 0
    }
    
    func openTabHistory() {
        let currentWindow = appViewModel.currentlyActiveWindowId
        guard let contentViewModel = contentViewModel(for: currentWindow) else { return }
        contentViewModel.triggerRestoredHistory.toggle()
        print("shouldOpen")
    }
    
    func isTabHistoryDisabled()-> Bool {
        let currentWindow = appViewModel.currentlyActiveWindowId
        guard let contentViewModel = contentViewModel(for: currentWindow), let tab = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab}), !tab.restoredURLs.isEmpty else { return true }
        return false
    }
    
    func reload(fromSource: Bool = false) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return }
        if let tab = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab}) {
            if !fromSource {
                tab.webViewModel.webView?.reload()
            } else {
                tab.webViewModel.webView?.reloadFromOrigin()
            }
        }
    }
    
    func reloadDisabled() -> Bool {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return true }
        return contentViewModel.tabs.isEmpty || contentViewModel.currentTab == nil || contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab}) == nil
    }
    
    func onAppear() {
        appViewModel.modelContainer = container
        appViewModel.showMeiliSetup = !UDKey.wasMeiliSetupOnce.boolValue
        appDelegate.configure(appViewModel: appViewModel, contentViewModel: contentViewModel, contentViewModel2: contentViewModel2, contentViewModel3: contentViewModel3, container: container)
        appViewModel.openWindow = { url in
            openWindow(value: url)
        }
        do {
            appViewModel.meili = try MeiliSearch(host: "http://localhost:7700", apiKey: KeyChainManager.getValue(for: .meiliMasterKey))
        } catch {
            print(error)
        }
        
        appViewModel.openMiniInNewTab = { url, id, newTab in
            let vm = WebViewModel(processPool: contentViewModel.wkProcessPool, contentViewModel: contentViewModel, appViewModel: appViewModel)
            vm.load(urlString: url?.absoluteString ?? "")
            let tab = ATab(webViewModel: vm, restoredURLs: [])
            switch id {
            case "window1":
                contentViewModel.tabs.append(tab)
                if newTab {
                    contentViewModel.currentTab = tab.id
                }
                openWindow(id: "window1")
            case "window2":
                contentViewModel2.tabs.append(tab)
                if newTab {
                    contentViewModel2.currentTab = tab.id
                }
                openWindow(id: "window2")
            default:
                contentViewModel3.tabs.append(tab)
                if newTab {
                    contentViewModel3.currentTab = tab.id
                }
                openWindow(id: "window3")
            }
        }
        
        appViewModel.openWindowByID = { id in
            openWindow(id: id)
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            return handleAndPassCommand(event)
        }
    }
    
    func search() {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return }
        contentViewModel.showInlineSearch.toggle()
    }
    
    func showHistory() {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId) else { return }
        contentViewModel.showHistory.toggle()
    }
    
    func zoom(enlarge: Bool = true) {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId), let webViewModel = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab})?.webViewModel else { return }
        webViewModel.webView?.evaluateJavaScript("document.body.style.zoom = (parseFloat(document.body.style.zoom || 1.0) \(enlarge ? "+": "-") 0.1)") { (result, error) in
            if let error = error {
                print("Zoom \(enlarge ? "in": "out") error: \(error)")
            }
        }
    }
    
    func resetZoom() {
        guard let contentViewModel = contentViewModel(for: appViewModel.currentlyActiveWindowId), let webViewModel = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab})?.webViewModel else { return }
        webViewModel.webView?.evaluateJavaScript("document.body.style.zoom = 1.0") { (result, error) in
            if let error = error {
                print("Zoom reset error: \(error)")
            }
        }
    }
    
    func contentViewModel(for id: String) -> ContentViewModel? {
        switch id {
        case "window1":
            contentViewModel
        case "window2":
            contentViewModel2
        case "window3":
            contentViewModel3
        default:
            nil
        }
    }
    
    @SceneBuilder
    func createWindow(id: String, viewModel: ContentViewModel) -> some Scene {
        Window("Amethyst Browser", id: id) {
            ContentView()
                .frame(minWidth: 600, minHeight: 600)
                .ignoresSafeArea(.container, edges: .top)
                .modelContainer(container)
                .modelContext(context)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == id }) {
                            window.standardWindowButton(.closeButton)?.isHidden = true
                            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                            window.standardWindowButton(.zoomButton)?.isHidden = true
                            window.delegate = appViewModel
                        }
                    }
                    onAppear()
                }
                .environment(appViewModel)
                .environment(viewModel)
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                    print("registered")
                    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                        return handleAndPassCommand(event)
                    }
                }
        }
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .windowStyle(.hiddenTitleBar)
        .defaultAppStorage(UserDefaults.standard)
    }
    
    func handleAndPassCommand(_ event: NSEvent) -> NSEvent? {
        if event.modifierFlags.rawValue == 256 || ((event.modifierFlags.contains(.shift) || event.modifierFlags.contains(.capsLock)) && (!event.modifierFlags.contains(.command) && !event.modifierFlags.contains(.control) && !event.modifierFlags.contains(.option))) { return event }
        
        //go back
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.goBackShortcut.shortcut.key, modifiers: UDKey.goBackShortcut.shortcut.modifier), event: event) {
            navigate()
            return nil
        }
        
        //go forward
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.goForwardShortcut.shortcut.key, modifiers: UDKey.goForwardShortcut.shortcut.modifier), event: event) {
            navigate(back: false)
            return nil
        }
        
        //reload
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.reloadShortcut.shortcut.key, modifiers: UDKey.reloadShortcut.shortcut.modifier), event: event) {
            reload()
            return nil
        }
        
        // previous tab
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.previousTabShortcut.shortcut.key, modifiers: UDKey.previousTabShortcut.shortcut.modifier), event: event) {
            navigateTabs()
            return nil
        }
        
        // next tab
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.nextTabShortcut.shortcut.key, modifiers: UDKey.nextTabShortcut.shortcut.modifier), event: event) {
            navigateTabs(back: false)
            return nil
        }
        
        // reload from source
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.reloadFromSourceShortcut.shortcut.key, modifiers: UDKey.reloadFromSourceShortcut.shortcut.modifier), event: event) {
            reload(fromSource: true)
            return nil
        }
        
        //searchbar
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.openSearchbarShortcut.shortcut.key, modifiers: UDKey.openSearchbarShortcut.shortcut.modifier), event: event) {
            newTab()
            return nil
        }
        
        // close current tab
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.closeCurrentTabShortcut.shortcut.key, modifiers: UDKey.closeCurrentTabShortcut.shortcut.modifier), event: event) {
            closeCurrentTab()
            return nil
        }
        
        //toggle sidebar
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.toggleSidebarShortcut.shortcut.key, modifiers: UDKey.toggleSidebarShortcut.shortcut.modifier), event: event) {
            toggleSidebar()
            return nil
        }
        
        //toggle password sidebar
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.togglePasswordsShortcut.shortcut.key, modifiers: UDKey.togglePasswordsShortcut.shortcut.modifier), event: event) {
            togglePasswordSidebar()
            return nil
        }
        
        //document search
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.openInlineSearchShortcut.shortcut.key, modifiers: UDKey.openInlineSearchShortcut.shortcut.modifier), event: event) {
            
            search()
            return nil
        }
        
        //toggle sidebar fixed
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.toggleSidebarFixedShortcut.shortcut.key, modifiers: UDKey.toggleSidebarFixedShortcut.shortcut.modifier), event: event) {
            toggleSidebar(fix: true)
            return nil
        }
        
        //toggle password sidebar fixed
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.togglePasswordsFixedShortcut.shortcut.key, modifiers: UDKey.togglePasswordsFixedShortcut.shortcut.modifier), event: event) {
            togglePasswordSidebar(fix: true)
            return nil
        }
        
        //Zoom in
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.zoomInShortcut.shortcut.key, modifiers: UDKey.zoomInShortcut.shortcut.modifier), event: event) {
            zoom()
        }
        
        //Zoom out
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.zoomOutShortcut.shortcut.key, modifiers: UDKey.zoomOutShortcut.shortcut.modifier), event: event) {
            zoom(enlarge: false)
        }
        
        //reset Zoom
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.resetZoomShortcut.shortcut.key, modifiers: UDKey.resetZoomShortcut.shortcut.modifier), event: event) {
            resetZoom()
        }
        
        //new window
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.newWindowShortcut.shortcut.key, modifiers: UDKey.newWindowShortcut.shortcut.modifier), event: event) {
            createNewWindow()
            return nil
        }
        
        //show history
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.showHistoryShortcut.shortcut.key, modifiers: UDKey.showHistoryShortcut.shortcut.modifier), event: event) {
            showHistory()
            return nil
        }
        //show tab history
        if expectedShortcutMatchesEvent(expected: KeyboardShortcut(UDKey.showRestoredTabhistoryShortcut.shortcut.key, modifiers: UDKey.showRestoredTabhistoryShortcut.shortcut.modifier), event: event) {
            openTabHistory()
            return nil
        }
        return event
    }
    
    func expectedShortcutMatchesEvent(expected: KeyboardShortcut, event: NSEvent) -> Bool {
        return event.characters?.first?.lowercased() == expected.key.character.lowercased() &&
        (event.modifierFlags.contains(.control) == expected.modifiers.contains(.control)) && (event.modifierFlags.contains(.command) == expected.modifiers.contains(.command)) && (event.modifierFlags.contains(.shift) == expected.modifiers.contains(.shift)) && (event.modifierFlags.contains(.capsLock) == expected.modifiers.contains(.capsLock)) && (event.modifierFlags.contains(.option) == expected.modifiers.contains(.option))
    }
}

