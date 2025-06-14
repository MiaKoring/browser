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
    @Environment(\.modelContext) var context
    
    @State var error: Error?
    @State var showAccountCreationSheet: Bool = false
    @State var currentIdentifier: String?
    @State var sortData = PasswordSortData()
    
    
    
    var body: some View {
        ZStack {
            VStack {
                contentViewModel.sidebarOrientation.passwordsTopRow(sortData: $sortData, prepareCreationSheet: prepareCreationSheet)
                .addTopRowPadding(isFixed: contentViewModel.isPasswordFixed)
                .padding(.horizontal, 3)
                PasswordsContentView(context: context)
                    .padding(.top)
                    .environment(sortData)
            }
        }
        .decideSidebarStyling(isFixed: contentViewModel.isPasswordFixed, appearance: appearance, useMacos26Desing: appViewModel.useMacOS26Design)
        .alert("An Error occured", isPresented: .constant(error != nil)) {
            Button("OK", role: .cancel) {
                error = nil
            }
        } message: {
            Text(error?.localizedDescription ?? "")
        }
        .sheet(item: $currentIdentifier ) { identifier in
            AccountDetailEdit(service: identifier, context: context) {
                showAccountCreationSheet = false
                currentIdentifier = nil
            }
        }
        .sheet(isPresented: $showAccountCreationSheet) {
            AccountDetailEdit(service: "", context: context) {
                showAccountCreationSheet = false
                currentIdentifier = nil
            }
        }
    }
    
    func prepareCreationSheet() {
        guard let tabID = contentViewModel.currentTab, let tab = contentViewModel.tabs.first(where: {$0.id == tabID }), let currentURL = tab.webViewModel.currentURL else {
            showAccountCreationSheet = true
            return
        }
        let identifier = IdentifierHandler.getIdentifiers(urlString: currentURL.absoluteString).sorted(by: {$0.count > $1.count }).first
        currentIdentifier = identifier
    }
    
}
