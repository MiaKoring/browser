//
//  BrowserApp.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import SwiftUI
import AppKit
import SwiftData
import WebKit
import AmethystAuthenticatorCore


@main
struct AmethystApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) var openWindow
    @State var appViewModel: AppViewModel
    @State var contentViewModel = ContentViewModel(id: "window1")
    @State var contentViewModel2 = ContentViewModel(id: "window2")
    @State var contentViewModel3 = ContentViewModel(id: "window3")
    @Environment(\.modelContext) var context
    let container: ModelContainer
    let passwordContainer: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: SavedTab.self, BackForwardListItem.self, HistoryItem.self, HistoryDay.self, FavouriteItem.self, DownloadedItem.self, migrationPlan: TabMigration.self, configurations: ModelConfiguration(cloudKitDatabase: .none))
#if RELEASE
            guard let teamID = Bundle.main.object(forInfoDictionaryKey: "TeamID") as? String, let groupDBURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "\(teamID)de.touchthegrass.Amethyst.shared")?.appendingPathComponent("shared.sqlite") else {
                fatalError("Couldn't find url for shared group db")
            }
#elseif DEBUG
            guard let teamID = Bundle.main.object(forInfoDictionaryKey: "TeamID") as? String, let groupDBURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "\(teamID)de.touchthegrass.Amethyst.shared.dev")?.appendingPathComponent("shared.sqlite") else {
                fatalError("Couldn't find url for shared group db")
            }
#endif
            let configuration = ModelConfiguration(url: groupDBURL)
            do {
                self.passwordContainer = try ModelContainer(for: Account.self, migrationPlan: AAuthenticatorMigrations.self, configurations: configuration)
            } catch {
                fatalError("Couldn't create Model Container. Failed with: \(error.localizedDescription)")
            }
            
        } catch {
            fatalError("failed to initialize model container: \(error.localizedDescription)")
        }
        self.appViewModel = AppViewModel()
        appViewModel.modelContainer = container
        self.appViewModel.downloadManager = DownloadManager()
    }
    
    
    
    var body: some Scene {
        createWindow(id: "window1", viewModel: contentViewModel)
        WindowGroup(id: "singleWindow", for: URL.self) { value in
            if let _ = value.wrappedValue {
                SingleFrame(appViewModel: appViewModel, url: value)
                    .environment(appViewModel)
                    .environment(contentViewModel)
                    .onAppear() {
                        onAppear()
                    }
                    .ignoresSafeArea()
                    .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                            return handleAndPassCommand(event)
                        }
                    }
            }
        }
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .windowStyle(.hiddenTitleBar)
        createWindow(id: "window2", viewModel: contentViewModel2)
        createWindow(id: "window3", viewModel: contentViewModel3)
            .commands {
                CommandGroup(replacing: .newItem) {
                    Button("New Window") {
                        createNewWindow()
                    }
                    .keyboardShortcut(UDKey.newWindowShortcut.shortcut.key , modifiers: UDKey.newWindowShortcut.shortcut.modifier)
                }
                CommandGroup(after: .sidebar) {
                    Button("Toggle Sidebar") {
                        toggleSidebar()
                    }
                    .keyboardShortcut(UDKey.toggleSidebarShortcut.shortcut.key, modifiers: UDKey.toggleSidebarShortcut.shortcut.modifier)
                    Button("Fix Sidebar") {
                        toggleSidebar(fix: true)
                    }
                    .keyboardShortcut(UDKey.toggleSidebarFixedShortcut.shortcut.key, modifiers: UDKey.toggleSidebarFixedShortcut.shortcut.modifier)
                }
                CommandMenu("Find") {
                    Button("Open Searchbar") {
                        newTab()
                    }
                    .keyboardShortcut(UDKey.openSearchbarShortcut.shortcut.key, modifiers: UDKey.openSearchbarShortcut.shortcut.modifier)
                    Button("Document Search") {
                        search()
                    }
                    .keyboardShortcut(UDKey.openInlineSearchShortcut.shortcut.key, modifiers: UDKey.openInlineSearchShortcut.shortcut.modifier)
                    .disabled(!appViewModel.currentlyActiveWindowId.hasPrefix("window"))
                }
                CommandMenu("View") {
                    Button("Zoom In") {
                        zoom()
                    }
                    .keyboardShortcut(UDKey.zoomInShortcut.shortcut.key, modifiers: UDKey.zoomInShortcut.shortcut.modifier)
                    .disabled(contentViewModel(for: appViewModel.currentlyActiveWindowId)?.currentTab != nil)
                    Button("Zoom Out") {
                        zoom(enlarge: false)
                    }
                    .keyboardShortcut(UDKey.zoomOutShortcut.shortcut.key, modifiers: UDKey.zoomOutShortcut.shortcut.modifier)
                    .disabled(contentViewModel(for: appViewModel.currentlyActiveWindowId)?.currentTab != nil)
                    Button("Reset Zoom") {
                        resetZoom()
                    }
                    .keyboardShortcut(UDKey.resetZoomShortcut.shortcut.key, modifiers: UDKey.resetZoomShortcut.shortcut.modifier)
                    .disabled(contentViewModel(for: appViewModel.currentlyActiveWindowId)?.currentTab != nil)
                }
                CommandMenu("Navigation") {
                    Button("Go Back") {
                        navigate()
                    }
                    .keyboardShortcut(UDKey.goBackShortcut.shortcut.key, modifiers: UDKey.goBackShortcut.shortcut.modifier)
                    Button("Go Forward") {
                        navigate(back: false)
                    }
                    .keyboardShortcut(UDKey.goForwardShortcut.shortcut.key, modifiers: UDKey.goForwardShortcut.shortcut.modifier)
                    Button("Reload") {
                        reload()
                    }
                    .keyboardShortcut(UDKey.reloadShortcut.shortcut.key, modifiers: UDKey.reloadShortcut.shortcut.modifier)
                    .disabled(reloadDisabled())
                    Button("Reload from source") {
                        reload(fromSource: true)
                    }
                    .keyboardShortcut(UDKey.reloadFromSourceShortcut.shortcut.key, modifiers: UDKey.reloadFromSourceShortcut.shortcut.modifier)
                    .disabled(reloadDisabled())
                    Button("Previous Tab") {
                        navigateTabs()
                    }
                    .keyboardShortcut(UDKey.previousTabShortcut.shortcut.key, modifiers: UDKey.previousTabShortcut.shortcut.modifier)
                    .disabled(tabSwitchingDisabled())
                    Button("Next Tab") {
                        navigateTabs(back: false)
                    }
                    .keyboardShortcut(UDKey.nextTabShortcut.shortcut.key, modifiers: UDKey.nextTabShortcut.shortcut.modifier)
                    .disabled(tabSwitchingDisabled(back: false))
                    Button("Close current Tab") {
                        closeCurrentTab()
                    }
                    .keyboardShortcut(UDKey.closeCurrentTabShortcut.shortcut.key, modifiers: UDKey.closeCurrentTabShortcut.shortcut.modifier)
                    .disabled(contentViewModel(for: appViewModel.currentlyActiveWindowId)?.currentTab == nil)
                }
                CommandMenu("Archive") {
                    Button("Show History") {
                        showHistory()
                    }
                    .keyboardShortcut(UDKey.showHistoryShortcut.shortcut.key, modifiers: UDKey.showHistoryShortcut.shortcut.modifier)
                    Button("Show Restored Tabhistory") {
                        openTabHistory()
                    }
                    .keyboardShortcut(UDKey.showRestoredTabhistoryShortcut.shortcut.key, modifiers: UDKey.showRestoredTabhistoryShortcut.shortcut.modifier)
                    .disabled(isTabHistoryDisabled())
                }
            }
        Settings {
            SettingsView()
                .frame(width: 900, height: 500)
                .environment(appViewModel)
        }
    }
}

