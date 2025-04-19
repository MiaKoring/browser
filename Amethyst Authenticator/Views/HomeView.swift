//
//  HomeView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.03.25.
//

import SwiftUI
import SwiftData
import AmethystAuthenticatorCore

struct HomeView: View {
    @State var selectedAccount: Account?
    @State var showTOTPSetup: Bool = false
    @State var showSelector: Bool = false
    @Binding var isAuthenticated: Bool
    @State var recievedCode: String? = nil
    @State var accountListTOTPCode: String? = nil
    @State var newAccountTOTPCode: String? = nil
    @State var accountAfterCreation: Account? = nil
    
    var body: some View {
        TabView {
            ForEach(TabCase.allCases, id: \.hashValue) { tab in
                Tab {
                    NavigationStack {
                        tab.view(selectedAccount: $selectedAccount)
                    }
                } label: {
                    Image(systemName: tab.imageName)
                }
            }
        }
        .onOpenURL { url in
            recievedCode = extractTOTPSecret(url: url)
            if isAuthenticated {
                showSelector = true
            }
        }
        .onChange(of: isAuthenticated) {
            if isAuthenticated && recievedCode != nil {
                showSelector = true
            }
        }
        .alert("Add OTP to existing Account?", isPresented: $showSelector) {
            Button ("Yes") {
                accountListTOTPCode = recievedCode
                recievedCode = nil
            }
            Button("Create New") {
                newAccountTOTPCode = recievedCode
                recievedCode = nil
            }
            Button("Cancel", role: .cancel) {
                showSelector = false
                recievedCode = nil
            }
        }
        .sheet(item: $accountListTOTPCode) { code in
            AccountList(totpSecret: code)
        }
        .sheet(item: $newAccountTOTPCode) { code in
            NavigationStack {
                AccountDetailEdit(account: Account(service: "", username: "", totp: false), create: true, accountAfterCreation: $accountAfterCreation, createWithCode: code, showCancelButton: true)
            }
        }
        .sheet(item: $accountAfterCreation) { account in
            NavigationStack {
                AccountDetail(account: account, showCancelButton: true)
            }
        }
        
    }
    
    func extractTOTPSecret(url: URL) -> String? {
        guard let res = url.query(percentEncoded: true), let secretPart = res.components(separatedBy: "&").first(where: {$0.hasPrefix("secret=")}) else {
            return nil
        }
        let secret = secretPart.replacingOccurrences(of: "secret=", with: "")
        return secret
    }
    
    struct AccountList: View {
        @Query(filter: #Predicate<Account>{ $0.totp == false && $0.deletedAt == nil }) var accounts: [Account]
        let totpSecret: String
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            NavigationStack {
                List(accounts) { account in
                    AccountDisplay(account: account)
                        .onTapGesture {
                            account.setTOTPSecret(to: totpSecret)
                            dismiss()
                        }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    
}
