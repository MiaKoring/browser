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
    
    var container: ModelContainer
    static var subSystem = "de.touchthegrass.Amethyst"
    
    static var windowRound: CGFloat = { if #available(macOS 26.0, *) { 16 } else { 10 } }()
    
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
        /*Window("Amethyst Control", id: "main") {
         ControlView()
         .environment(appViewModel)
         }
         */
        WindowGroup(id: "mainWindow") {
            ContentView()
                .frame(minWidth: 600, minHeight: 600)
                .ignoresSafeArea(.container, edges: .top)
                .onAppear {
                    onAppear()
                }
                .environment(appViewModel)
                .environment(ContentViewModel(id: UUID().uuidString))
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
#if DEBUG
                    print("registered")
#endif
                    NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                        return handleAndPassCommand(event)
                    }
                }
                .modelContainer(container)
                .defaultAppStorage(UserDefaults.standard)
        }
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        .windowStyle(.hiddenTitleBar)
        .commands {
            KeybindsGroup.window.commandGroup(
                appViewModel: appViewModel,
                openWindow: openWindow
            )
            KeybindsGroup.sidebars.commandGroup(
                appViewModel: appViewModel,
                openWindow: openWindow
            )
            KeybindsGroup.search.commandGroup(
                appViewModel: appViewModel,
                openWindow: openWindow
            )
            KeybindsGroup.view.commandGroup(
                appViewModel: appViewModel,
                openWindow: openWindow
            )
            KeybindsGroup.navigation.commandGroup(
                appViewModel: appViewModel,
                openWindow: openWindow
            )
            KeybindsGroup.archive.commandGroup(
                appViewModel: appViewModel,
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

struct ControlView: View {
    @Environment var appViewModel: AppViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Window Count: \(appViewModel.displayedWindows.count)")
            Button("Open New Tracked Window") {
                //appViewModel.openNewWindow()
            }
        }
        .frame(width: 300, height: 200)
    }
}
