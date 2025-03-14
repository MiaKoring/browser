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
    var showDeleted = false
    @State var showClearConfirmation: Bool = false
    
    var body: some View {
        List(searchText.isEmpty ?
             accounts.filter({showDeleted ? ($0.deletedAt != nil): ($0.deletedAt == nil)})
            .sorted(by: { sortFilter.shouldPrecede(lhs: $0, rhs: $1, ascending: sortDirectionAcending) }):
                accounts.filter({
                (
                    $0.username.contains(searchText) ||
                    $0.service.contains(searchText)
                ) &&
                showDeleted ? ($0.deletedAt != nil): ($0.deletedAt == nil)
            })
            .sorted(by: { sortFilter.shouldPrecede(lhs: $0, rhs: $1, ascending: sortDirectionAcending) })
        ) { account in
            NavigationLink {
                AccountDetail(account: account, showDeleted: showDeleted)
            } label: {
                AccountDisplay(account: account, showDeleted: showDeleted)
            }
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                SelectionMenu(sortDirectionAcending: $sortDirectionAcending, sortFilter: $sortFilter)
            }
            if !showDeleted {
                ToolbarItem(placement: .navigation) {
                    NavigationLink {
                        AccountDetailEdit(account: Account(service: "", username: "", totp: false), create: true, accountAfterCreation: $accountAfterCreation)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            } else {
                ToolbarItem(placement: .navigation) {
                    Button(role: .destructive) {
                        showClearConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .fullScreenCover(item: $accountAfterCreation) { account in
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
                AccountDetail(account: account)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
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
                        Label("Descending", systemImage: sortDirectionAcending ? "arrow.up": "checkmark")
                    }
                    Button {
                        sortDirectionAcending = true
                    } label: {
                        Label("Descending", systemImage: !sortDirectionAcending ? "arrow.down": "checkmark")
                    }
                }
                Section {
                    Button {
                        sortFilter = .edited
                    } label: {
                        Label("Date Edited", systemImage: sortFilter == .edited ? "checkmark": "pencil.line")
                    }
                    Button {
                        sortFilter = .created
                    } label: {
                        Label("Date Created", systemImage: sortFilter == .created ? "checkmark": "plus.circle")
                    }
                    Button {
                        sortFilter = .website
                    } label: {
                        Label("Website", systemImage: sortFilter == .website ? "checkmark": "safari")
                    }
                    Button {
                        sortFilter = .title
                    } label: {
                        Label("Title", systemImage: sortFilter == .title ? "checkmark": "textformat")
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
            }
        }
    }
}
