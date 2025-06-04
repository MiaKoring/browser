//
//  PasswordList.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.03.25.
//

import SwiftUI
import SwiftData
import AmethystAuthenticatorCore

extension PasswordList: View {
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
                                autofill(username: account.username, password: account.password)
                            }
                    }
                    Text("remaining")
                        .bold()
                        .foregroundStyle(.secondary)
                    ForEach( remainingAccounts ) { account in
                        AccountDisplay(account: account, context: context)
                            .onTapGesture {
                                autofill(username: account.username, password: account.password)
                            }
                    }
                    
                }
                .padding(.horizontal, 10)
            }
        }
        .sheet(isPresented: $showAccountCreation) {
            AccountDetailEdit(account: Account(service: "", username: "", totp: false), create: true, context: context) {
                showAccountCreation = false
            }
        }
        .onAppear() { setIdentifiersForCurrentTab(initial: true) }
        .onChange(of: accounts) { scheduleFilterUpdate() }
        .onChange(of: searchText) { scheduleFilterUpdate(debounceTime: 0.2) }
        .onChange(of: sortData.triggerSort) { scheduleFilterUpdate(debounceTime: 0.1) }
        .onChange(of: contentViewModel.currentTab) { setIdentifiersForCurrentTab() }
        .onChange(of: currentTabWebViewModel?.currentURL) { updateIdentifiersFromURL() }
    }
}
