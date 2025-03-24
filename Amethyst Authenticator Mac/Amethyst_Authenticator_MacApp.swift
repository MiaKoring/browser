//
//  Amethyst_Authenticator_MacApp.swift
//  Amethyst Authenticator Mac
//
//  Created by Mia Koring on 09.03.25.
//

import SwiftUI
import AmethystAuthenticatorCore
import SwiftData

@main
struct Amethyst_Authenticator_MacApp: App {
    let container: ModelContainer
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
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
