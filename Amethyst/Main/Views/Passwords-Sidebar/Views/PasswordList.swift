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
    @Environment(\.modelContext) var context
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
                        AccountDisplay(account: account)
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
                        AccountDisplay(account: account)
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .sheet(isPresented: $showAccountCreation) {
            AccountDetailEdit(account: Account(service: "", username: "", totp: false), create: true, accountAfterCreation: $accountAfterCreation) {
                showAccountCreation = false
            }
        }
        .sheet(item: $accountAfterCreation) { account in
            FullScreenCoverView(account: account)
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
            identifiers = getIdentifiers(urlString: url.absoluteString)
        }
        .onAppear() {
            setIdentifiersForCurrentTab()
        }
    }
    
    struct FullScreenCoverView: View {
        @Bindable var account: Account
        @Environment(\.dismiss) var dismiss
        var body: some View {
            NavigationStack {
                AccountDetail(account: account, showDeleted: .constant(false))
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "chevron.left")
                                        .bold()
                                    Text("Back")
                                }
                            }
                        }
                    }
            }
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
    
    private func removeSubdomain(from host: String) -> String? {
        let components = host.components(separatedBy: ".")
        
        guard components.count >= 3 else {
            return host
        }
        
        let knownTLDs = [
            "ac.at",
            "ac.be",
            "ac.cn",
            "ac.il",
            "ac.in",
            "ac.jp",
            "ac.kr",
            "ac.nz",
            "ac.th",
            "ac.uk",
            "ac.za",
            "co.at",
            "co.il",
            "co.in",
            "co.jp",
            "co.kr",
            "co.nz",
            "co.th",
            "co.uk",
            "co.za",
            "com.ar",
            "com.au",
            "com.br",
            "com.cn",
            "com.co",
            "com.hk",
            "com.mx",
            "com.my",
            "com.ph",
            "com.sg",
            "com.tr",
            "com.tw",
            "edu.au",
            "edu.cn",
            "edu.hk",
            "edu.sg",
            "edu.tw",
            "gov.au",
            "gov.cn",
            "gov.hk",
            "gov.sg",
            "gov.tw",
            "gov.uk",
            "gov.za",
            "id.au",
            "net.au",
            "net.cn",
            "net.hk",
            "net.il",
            "net.in",
            "net.nz",
            "net.sg",
            "net.uk",
            "net.za",
            "org.au",
            "org.cn",
            "org.hk",
            "org.il",
            "org.in",
            "org.nz",
            "org.sg",
            "org.tw",
            "org.uk",
            "org.za"
        ]
        let lastTwoComponents = components[components.count-2] + "." + components[components.count-1]
        
        if knownTLDs.contains(lastTwoComponents) && components.count >= 4 {
            return components[components.count-3] + "." + lastTwoComponents
        } else {
            return components[components.count-2] + "." + components[components.count-1]
        }
    }
    
    func getIdentifiers(urlString: String) -> Set<String> {
        var urlSet = Set<String>()
        guard let identifier = URL(string: urlString)?.host() else {
            return urlSet
        }
        urlSet.insert(identifier)
        guard let subdomainless = removeSubdomain(from: identifier) else {
            return urlSet
        }
        urlSet.insert(subdomainless)
        return urlSet
    }
    
    func setIdentifiersForCurrentTab() {
        guard let currentTabId = contentViewModel.currentTab, let tab = contentViewModel.tabs.first(where: { tab in
            tab.id == currentTabId
        }) else { return }
        currentTabWebViewModel = tab.webViewModel
        guard let webViewModel = currentTabWebViewModel,  let url = webViewModel.currentURL else { return }
        identifiers = getIdentifiers(urlString: url.absoluteString)
    }
}
