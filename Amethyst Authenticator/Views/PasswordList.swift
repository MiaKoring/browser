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
    var body: some View {
        List(searchText.isEmpty ? accounts.filter({$0.deletedAt == nil}): accounts.filter({
            ($0.username.contains(searchText) || $0.service.contains(searchText)) && $0.deletedAt == nil
        })) { account in
            NavigationLink {
                AccountDetail(account: account)
            } label: {
                AccountDisplay(account: account)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                NavigationLink {
                    AccountDetailEdit(account: Account(service: "", username: "", totp: false), create: true, accountAfterCreation: $accountAfterCreation)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .fullScreenCover(item: $accountAfterCreation) { account in
            FullScreenCoverView(account: account)
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
    
    
}
