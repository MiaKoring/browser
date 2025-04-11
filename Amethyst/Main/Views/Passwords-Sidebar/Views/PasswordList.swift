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
    @Query var accounts: [Account]
    @Binding var selectedAccount: Account?
    @State var searchText: String = ""
    var context: ModelContext
    @State var accountAfterCreation: Account?
    @State var sortDirectionAcending: Bool = true
    @State var sortFilter: SortFilter = .title
    @State var showDeleted = false
    @State var showClearConfirmation: Bool = false
    var showTOTP = false
    @State var identifiers = Set<String>()
    @State var showAccountCreation: Bool = false
    @State var currentTabWebViewModel: WebViewModel? = nil
    
    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 10)
            ScrollView {
                
                LazyVStack(alignment: .leading) {
                    Text("most likely")
                        .bold()
                        .foregroundStyle(.secondary)
                    ForEach( accounts.filter { account in
                        passesFilter(account, isLikely: true)
                    }) { account in
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
                    ForEach(accounts
                        .filter({ account in
                            passesFilter(account)
                        })
                            .sorted(by: { sortFilter.shouldPrecede(lhs: $0, rhs: $1, ascending: sortDirectionAcending) })
                    ) { account in
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
        }
        .onChange(of: currentTabWebViewModel?.currentURL) {
            guard let url = currentTabWebViewModel?.currentURL else {
                identifiers = Set<String>()
                return
            }
            identifiers = IdentifierHandler.getIdentifiers(urlString: url.absoluteString)
        }
        .onAppear() {
            setIdentifiersForCurrentTab()
        }
    }
    
    struct SelectionMenu: View {
        @Binding var sortDirectionAcending: Bool
        @Binding var sortFilter: SortFilter
        var body: some View {
            Menu {
                Section {
                    Button {
                        sortDirectionAcending = false
                    } label: {
                        HStack {
                            Image(systemName: sortDirectionAcending ? "arrow.up": "checkmark")
                            Text("Descending")
                        }
                    }
                    Button {
                        sortDirectionAcending = true
                    } label: {
                        HStack {
                            Image(systemName: !sortDirectionAcending ? "arrow.down": "checkmark")
                            Text("Ascending")
                        }
                    }
                }
                Section {
                    Button {
                        sortFilter = .edited
                    } label: {
                        HStack {
                            Image(systemName: sortFilter == .edited ? "checkmark": "pencil.line")
                            Text("Date Edited")
                        }
                    }
                    Button {
                        sortFilter = .created
                    } label: {
                        HStack {
                            Image(systemName: sortFilter == .created ? "checkmark": "plus.circle")
                            Text("Date Created")
                        }
                    }
                    Button {
                        sortFilter = .website
                    } label: {
                        HStack {
                            Image(systemName: sortFilter == .website ? "checkmark": "safari")
                            Text("Website")
                        }
                    }
                    Button {
                        sortFilter = .title
                    } label: {
                        HStack {
                            Image(systemName: sortFilter == .title ? "checkmark": "textformat")
                            Text("Title")
                        }
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
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
