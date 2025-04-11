//
//  PasswordSidebar.swift
//  Amethyst Project
//
//  Created by Mia Koring on 10.04.25.
//

import SwiftUI
import SwiftData
import AmethystAuthenticatorCore

struct PasswordSidebar: View {
    @Environment(ContentViewModel.self) var contentViewModel
    @Environment(AppViewModel.self) var appViewModel
    @Environment(\.colorScheme) var appearance
    @State var isSideBarButtonHovered: Bool = false

    @State var error: Error?
    @State var isPlusButtonHovered: Bool = false
    @State var showAccountCreationSheet: Bool = false
    @State var currentIdentifier: String?
    
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
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "sidebar.right")
                        .sidebarTopButton(hovered: $isSideBarButtonHovered, appearance: appearance) {
                            contentViewModel.isPasswordFixed.toggle()
                            contentViewModel.isPasswordShown = false
                        }
                    Spacer()
                    Image(systemName: "plus")
                        .sidebarTopButton(hovered: $isPlusButtonHovered) {
                            prepareCreationSheet()
                        }
                }
                .padding(.leading, contentViewModel.isPasswordFixed ? 5: 0)
                .padding(.top, contentViewModel.isPasswordFixed ? 5: 0)
                .padding(.horizontal, 3)
                PasswordsContentView(context: ModelContext(container))
            }
        }
        .frame(maxHeight: .infinity)
        .frame(maxWidth: contentViewModel.isPasswordFixed ? .infinity: 300)
        .padding(5)
        .background {
            HStack {
                if contentViewModel.isPasswordFixed {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                        .background(appearance == .light ? .white.opacity(0.5): .clear)
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(appearance == .dark ? .myPurple.mix(with: .white, by: 0.1): Color.test)
                }
            }
            .overlay {
                if appearance == .light {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 1)
                        .fill(Color.gray)
                        .shadow(radius: 5)
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 1)
                        .fill(.ultraThickMaterial)
                        .shadow(radius: 5)
                }
            }
        }
        .padding(contentViewModel.isPasswordFixed ? 0: 8)
        .alert("An Error occured", isPresented: .constant(error != nil)) {
            Button("OK", role: .cancel) {
                error = nil
            }
        } message: {
            Text(error?.localizedDescription ?? "")
        }
        .sheet(item: $currentIdentifier ) { identifier in
            AccountDetailEdit(service: identifier, context: ModelContext(container)) {
                showAccountCreationSheet = false
                currentIdentifier = nil
            }
        }
        .modelContainer(container)
        
    }
    
    
    func prepareCreationSheet() {
        guard let tabID = contentViewModel.currentTab, let tab = contentViewModel.tabs.first(where: {$0.id == tabID }), let currentURL = tab.webViewModel.currentURL else {
           currentIdentifier = nil
            return
        }
        let identifier = IdentifierHandler.getIdentifiers(urlString: currentURL.absoluteString).sorted(by: {$0.count > $1.count }).first
        currentIdentifier = identifier
        showAccountCreationSheet = true
    }
}
