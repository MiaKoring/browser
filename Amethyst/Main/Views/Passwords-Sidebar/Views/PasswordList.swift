//
//  PasswordList.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.03.25.
//

import SwiftUI
import SwiftData
import AmethystAuthenticatorCore

struct PasswordList: View {
    @Environment(ContentViewModel.self) var contentViewModel
    @Environment(PasswordSortData.self) var sortData
    @Query var accounts: [Account]
    @Binding var selectedAccount: Account?
    @State var searchText: String = ""
    var context: ModelContext
    @State var accountAfterCreation: Account?
    @State var showDeleted = false
    @State var showClearConfirmation: Bool = false
    var showTOTP = false
    @State var identifiers = Set<String>()
    @State var showAccountCreation: Bool = false
    @State var currentTabWebViewModel: WebViewModel? = nil
    @State var shouldUpdateLikely: Bool = true
    @State var shouldUpdateRemaining: Bool = true
    @State var updateTimer = Timer()
    
    @State private var likelyAccounts: [Account] = []
    @State private var remainingAccounts: [Account] = []
    
    var body: some View {
        VStack {
            PasswordsSearchBar(text: $searchText)
                .padding(.horizontal, 10)
            ScrollView {
                LazyVStack(alignment: .leading) {
                    Text("most likely")
                        .bold()
                        .foregroundStyle(.secondary)
                    ForEach( likelyAccounts ) { account in
                        AccountDisplay(account: account, context: context)
                            .onTapGesture {
                                if let webView = currentTabWebViewModel?.webView {
                                    webView.evaluateJavaScript("amethystAutofillCredentials(\"\(account.username)\", \"\(account.password ?? "")\");")
                                    print("called")
                                } else {
                                    print("webView is nil")
                                }
                            }
                    }
                    Text("remaining")
                        .bold()
                        .foregroundStyle(.secondary)
                    ForEach( remainingAccounts ) { account in
                        AccountDisplay(account: account, context: context)
                            .onTapGesture {
                                if let webView = currentTabWebViewModel?.webView {
                                    webView.evaluateJavaScript("amethystAutofillCredentials(\"\(account.username)\", \"\(account.password ?? "")\");")
                                    print("called")
                                } else {
                                    print("webView is nil")
                                }
                            }
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .sheet(isPresented: $showAccountCreation) {
            AccountDetailEdit(account: Account(service: "", username: "", totp: false), create: true, accountAfterCreation: $accountAfterCreation, context: context) {
                showAccountCreation = false
            }
        }
        .confirmationDialog("Are you sure you want to permanently remove all Accounts from the trash? This action will irreversible remove all associated data from all your devices.", isPresented: $showClearConfirmation, titleVisibility: .visible) {
            Button("Remove all", role: .destructive) {
                try? context.transaction {
                    let allAccounts = accounts.filter({$0.deletedAt != nil})
                    for account in allAccounts {
                        account.deleteCorrespondingKeychainData()
                        context.delete(account)
                    }
                }
                
            }
        }
        .onChange(of: contentViewModel.currentTab) {
            setIdentifiersForCurrentTab()
            shouldUpdateLikely = true
        }
        .onChange(of: currentTabWebViewModel?.currentURL) {
            guard let url = currentTabWebViewModel?.currentURL else {
                identifiers = Set<String>()
                return
            }
            identifiers = IdentifierHandler.getIdentifiers(urlString: url.absoluteString)
            shouldUpdateLikely = true
        }
        .onAppear() {
            setIdentifiersForCurrentTab()
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
                updateAccounts(likely: shouldUpdateLikely, remaining: shouldUpdateRemaining)
            }
        }
        .onChange(of: accounts) {
            shouldUpdateLikely = true
            shouldUpdateRemaining = true
        }
        .onChange(of: searchText) {
            shouldUpdateLikely = true
            shouldUpdateRemaining = true
        }
        .onChange(of: sortData.triggerSort) {
            print("Should update")
            shouldUpdateRemaining = true
        }
    }
    
    func updateAccounts(likely: Bool = true, remaining: Bool = true) {
        try? context.transaction {
            if likely {
                likelyAccounts = accounts.filter ({ account in
                    passesFilter(account, isLikely: true)
                })
                shouldUpdateLikely = false
            }
            if remaining {
                remainingAccounts = accounts.filter { account in
                    passesFilter(account)
                }.sorted(by: { sortData.filter.shouldPrecede(lhs: $0, rhs: $1, ascending: sortData.ascending) })
                shouldUpdateRemaining = false
            }
        }
    }
    
    func passesFilter(_ account: Account, isLikely: Bool = false) -> Bool {
        let passesDeletedFilter = showDeleted ? (account.deletedAt != nil) : (account.deletedAt == nil)
        
        let passesSearchFilter = searchText.isEmpty ||
                                account.username.localizedCaseInsensitiveContains(searchText) ||
                                account.service.localizedCaseInsensitiveContains(searchText) ||
                                account.title?.localizedCaseInsensitiveContains(searchText) ?? false
        
        let passesTOTPFilter = !showTOTP ||
                                account.totp
        let notMatchingIdentifier = !identifiers.contains(where: {
            account.aliases.contains($0) || account.service.contains($0)
        })
        
        if !isLikely {
            return passesDeletedFilter && passesSearchFilter && passesTOTPFilter && notMatchingIdentifier
        }
        return passesDeletedFilter && passesSearchFilter && passesTOTPFilter && !notMatchingIdentifier
    }
    
    func setIdentifiersForCurrentTab() {
        guard let currentTabId = contentViewModel.currentTab, let tab = contentViewModel.tabs.first(where: { tab in
            tab.id == currentTabId
        }) else { return }
        currentTabWebViewModel = tab.webViewModel
        guard let webViewModel = currentTabWebViewModel,  let url = webViewModel.currentURL else { return }
        identifiers = IdentifierHandler.getIdentifiers(urlString: url.absoluteString)
    }
}
