//
//  AmethystAppFunctions.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 30.11.24.
//

import SwiftUI
import MeiliSearch

extension AmethystApp {    
    func onAppear() {
        appViewModel.showSetup = !UDKey.wasSetupOnce.boolValue
        appDelegate.configure(appViewModel: appViewModel, contentViewModel: contentViewModel, contentViewModel2: contentViewModel2, contentViewModel3: contentViewModel3)
        appViewModel.openWindow = { url in
            openWindow(value: url)
        }
        do {
            let meiliURL = MeiliSettings.meiliURL.stringValue(default: "127.0.0.1:37270")
            guard !meiliURL.isEmpty else {
                print("Meili not setup")
                return
            }
            appViewModel.meili = try MeiliSearch(host: "http://\(meiliURL)", apiKey: KeyChainManager.getValue(for: .meiliMasterKey))
        } catch {
            print(error)
        }
        
        appViewModel.openMiniInNewTab = openMiniInWindow
        
        appViewModel.openWindowByID = { id in
            openWindow(id: id)
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            return handleAndPassCommand(event)
        }
    }
    
    @SceneBuilder
    func createWindow(id: String, viewModel: ContentViewModel) -> some Scene {
        Window("Amethyst Browser \(id.replacingOccurrences(of: "window", with: ""))", id: id) {
            ContentView()
                .frame(minWidth: 600, minHeight: 600)
                .ignoresSafeArea(.container, edges: .top)
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
#if DEBUG
                    print("registered")
#endif
                    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                        return handleAndPassCommand(event)
                    }
                }
                .modelContainer(container)
        }
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .windowStyle(.hiddenTitleBar)
        .defaultAppStorage(UserDefaults.standard)
    }
    
    func handleAndPassCommand(_ event: NSEvent) -> NSEvent? {
        if event.modifierFlags.rawValue == 256 || ((event.modifierFlags.contains(.shift) || event.modifierFlags.contains(.capsLock)) && (!event.modifierFlags.contains(.command) && !event.modifierFlags.contains(.control) && !event.modifierFlags.contains(.option))) || appViewModel.currentlyActiveWindowId == "com_apple_SwiftUI_Settings_window" { return event }
        guard let keybind = Keybind(event) else { return event }
        guard keybind.execute(appViewModel: appViewModel, contentViewModels: (contentViewModel, contentViewModel2, contentViewModel3), openWindow: openWindow) else {
            return nil
        }
        return event
    }
    
    func openMiniInWindow(_ url: URL?, _ id: String, _ newTab: Bool) {
        let vm = WebViewModel(processPool: contentViewModel.wkProcessPool, contentViewModel: contentViewModel, appViewModel: appViewModel)
        vm.load(urlString: url?.absoluteString ?? "")
        let tab = ATab(webViewModel: vm)
        switch id {
        case "window1":
            handle(id: id, contentViewModel: contentViewModel, newTab: newTab, tab: tab)
        case "window2":
            handle(id: id, contentViewModel: contentViewModel2, newTab: newTab, tab: tab)
        default:
            handle(id: id, contentViewModel: contentViewModel3, newTab: newTab, tab: tab)
        }
        
        func handle(id: String, contentViewModel: ContentViewModel, newTab: Bool, tab: ATab) {
            contentViewModel.tabs.append(tab)
            if newTab {
                contentViewModel.currentTab = tab.id
            }
            openWindow(id: id)
        }
    }
}

