//
//  Amethyst_AuthenticatorApp.swift
//  Amethyst Authenticator
//
//  Created by Mia Koring on 07.03.25.
//

import SwiftUI
import AmethystAuthenticatorCore
import SwiftData

@main
struct Amethyst_AuthenticatorApp: App {
    let container: ModelContainer
    
    init() {
#if DEBUG
        guard let groupDBURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.de.touchthegrass.AmethystAuthenticator.dev")?.appendingPathComponent("shared.sqlite") else {
            fatalError("Couldn't find url for shared group db")
        }
#else
        guard let groupDBURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.de.touchthegrass.AmethystAuthenticator")?.appendingPathComponent("shared.sqlite") else {
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
    }
}
