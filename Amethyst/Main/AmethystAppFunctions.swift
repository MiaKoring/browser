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
        appViewModel.openWindow = { url in
            handleOpenSchema(url: url)
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
        
        
        appViewModel.openWindowByID = { id in
            openWindow(id: id)
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            return handleAndPassCommand(event)
        }
    }
    func handleAndPassCommand(_ event: NSEvent) -> NSEvent? {
        if event.modifierFlags.rawValue == 256 || ((event.modifierFlags.contains(.shift) || event.modifierFlags.contains(.capsLock)) && (!event.modifierFlags.contains(.command) && !event.modifierFlags.contains(.control) && !event.modifierFlags.contains(.option))) || appViewModel.currentlyActiveWindowId == "com_apple_SwiftUI_Settings_window" { return event }
        guard let keybind = Keybind(event) else { return event }
        guard keybind.execute(appViewModel: appViewModel, openWindow: openWindow) else {
            return nil
        }
        return event
    }
    
    func handleOpenSchema(url: URL) {
        Self.logger.warning("open schema triggered")
        let id = appViewModel.currentlyActiveWindowId
        guard let latestFocused = appViewModel.displayedWindows[id] ?? appViewModel.displayedWindows.values.first else {
            appViewModel.newURLToOpen = url
            Self.logger.error("no contentViewModel sadge")
            openWindow(id: "mainWindow")
            return
        }
        Self.logger.warning("wtf")
        let webVM = WebViewModel(contentViewModel: latestFocused, appViewModel: appViewModel)
        webVM.load(url: url)
        let tab = ATab(webViewModel: webVM)
        latestFocused.tabs.append(tab)
        latestFocused.currentTab = tab.id
        openWindow(id: latestFocused.id)
    }
}

