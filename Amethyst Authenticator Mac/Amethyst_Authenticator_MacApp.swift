//
//  Amethyst_Authenticator_MacApp.swift
//  Amethyst Authenticator Mac
//
//  Created by Mia Koring on 09.03.25.
//

import SwiftUI
import AmethystAuthenticatorCore
import SwiftData
import FileProviderUI

@main
struct Amethyst_Authenticator_MacApp: App {
    let container: ModelContainer
    @State var showImportAlert: Bool = false
    @State var showFileProvider: Bool = false
    @State var fileImportURL: URL?
    @State var error: Error?
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
                .sheet(item: $fileImportURL) { url in
                    ImportView(url: url)
                        .interactiveDismissDisabled()
                }
                .alert("Import Items", isPresented: $showImportAlert) {
                    Button("Cancel", role: .cancel) {
                        showImportAlert = false
                    }
                    Button("Import") {
                        showFileProvider = true
                    }
                }
                .alert("An Error occured", isPresented: .constant(error != nil)) {
                    Button("OK", role: .cancel) {
                        error = nil
                    }
                } message: {
                    Text(error?.localizedDescription ?? "")
                }
                .fileImporter(isPresented: $showFileProvider, allowedContentTypes: [.init(filenameExtension: "csv") ?? .spreadsheet]) { result in
                    switch result {
                    case .success(let url):
                        url.startAccessingSecurityScopedResource()
                        fileImportURL = url
                    case .failure(let error):
                        self.error = error
                    }
                }
                .modelContainer(container)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: .importExport) {
                Button("Import Credentials") {
                    showImportAlert = true
                }
            }
        }
    }
}
