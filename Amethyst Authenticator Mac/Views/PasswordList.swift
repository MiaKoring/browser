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
    @State var showAccountCreation: Bool = false
    
    var displayedAccounts: [Account] {
        accounts
            .filter({ account in
                passesFilter(account)
            })
            .sorted(by: { sortFilter.shouldPrecede(lhs: $0, rhs: $1, ascending: sortDirectionAcending) })
    }
    
    var body: some View {
        List(displayedAccounts) { account in
            NavigationLink {
                AccountDetail(account: account, showDeleted: $showDeleted)
            } label: {
                if showTOTP {
                    TOTPDisplay(account: account)
                } else {
                    AccountDisplay(account: account, showDeleted: showDeleted)
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText)
        .navigationTitle(!showDeleted ? !showTOTP ? Text("Passwords"): Text("Codes"): Text("Trash"))
        .toolbar {
#if DEBUG
            if showDeleted {
                ToolbarItem(placement: .primaryAction) {
                    Button("Delete All", role: .destructive) {
                        for account in accounts {
                            account.delete()
                        }
                    }
                }
            }
#endif
            ToolbarItem(placement: .primaryAction) {
                SelectionMenu(sortDirectionAcending: $sortDirectionAcending, sortFilter: $sortFilter)
            }
            if !showDeleted && !showTOTP {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAccountCreation = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            } else if showDeleted {
                ToolbarItem(placement: .primaryAction) {
                    Button(role: .destructive) {
                        showClearConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
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
    
    func passesFilter(_ account: Account) -> Bool {
        let passesDeletedFilter = showDeleted ? (account.deletedAt != nil) : (account.deletedAt == nil)
        
        let passesSearchFilter = searchText.isEmpty ||
                                account.username.localizedCaseInsensitiveContains(searchText) ||
                                account.service.localizedCaseInsensitiveContains(searchText) ||
                                account.title?.localizedCaseInsensitiveContains(searchText) ?? false
        
        let passesTOTPFilter = !showTOTP ||
                                account.totp
        
        return passesDeletedFilter && passesSearchFilter && passesTOTPFilter
    }
}
