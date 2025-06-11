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
    var container: ModelContainer
    static var subSystem = "de.touchthegrass.Amethyst"
    
    init() {
#if DEBUG
        guard let teamID = Bundle.main.object(forInfoDictionaryKey: "TeamID") as? String, let groupDBURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "\(teamID)group.de.touchthegrass.AmethystAuthenticator.dev")?.appendingPathComponent("shared.sqlite") else {
            fatalError("Couldn't find url for shared group db")
        }
#else
        guard let teamID = Bundle.main.object(forInfoDictionaryKey: "TeamID") as? String, let groupDBURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "\(teamID)group.de.touchthegrass.AmethystAuthenticator")?.appendingPathComponent("shared.sqlite") else {
            fatalError("Couldn't find url for shared group db")
        }
#endif
        let configuration = ModelConfiguration(url: groupDBURL)
        do {
            self.container = try ModelContainer(for: Account.self, migrationPlan: AAuthenticatorMigrations.self, configurations: configuration)
        } catch {
            fatalError("Couldn't create Model Container. Failed with: \(error.localizedDescription)")
        }
        self.appViewModel = AppViewModel()
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
                    .modelContainer(container)
            }
        }
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .windowStyle(.hiddenTitleBar)
        createWindow(id: "window2", viewModel: contentViewModel2)
        createWindow(id: "window3", viewModel: contentViewModel3)
            .commands {
                KeybindsGroup.window.commandGroup(
                    appViewModel: appViewModel,
                    contentViewModels: (contentViewModel, contentViewModel2, contentViewModel3),
                    openWindow: openWindow
                )
                KeybindsGroup.sidebars.commandGroup(
                    appViewModel: appViewModel,
                    contentViewModels: (contentViewModel, contentViewModel2, contentViewModel3),
                    openWindow: openWindow
                )
                KeybindsGroup.search.commandGroup(
                    appViewModel: appViewModel,
                    contentViewModels: (contentViewModel, contentViewModel2, contentViewModel3),
                    openWindow: openWindow
                )
                KeybindsGroup.view.commandGroup(
                    appViewModel: appViewModel,
                    contentViewModels: (contentViewModel, contentViewModel2, contentViewModel3),
                    openWindow: openWindow
                )
                KeybindsGroup.navigation.commandGroup(
                    appViewModel: appViewModel,
                    contentViewModels: (contentViewModel, contentViewModel2, contentViewModel3),
                    openWindow: openWindow
                )
                KeybindsGroup.archive.commandGroup(
                    appViewModel: appViewModel,
                    contentViewModels: (contentViewModel, contentViewModel2, contentViewModel3),
                    openWindow: openWindow
                )
            }
        Settings {
            SettingsView()
                .frame(width: 900, height: 500)
                .environment(appViewModel)
        }
    }
}
