//
//  PasswordList.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 12.03.25.
//

import SwiftUI
import SwiftData
import AmethystAuthenticatorCore

struct AccountList: View {
    @Query(FetchDescriptor<Account>(predicate: #Predicate { $0.deletedAt == nil })) var accounts: [Account]
    var identifiers: [String]
    var type: UIType
    var provideCredentials: (String, String, String, UUID, Bool) -> Void
    var cancel: () -> Void
    @Environment(\.modelContext) var context
  
    var body: some View {
        VStack(alignment: .leading) {
            Button {
                cancel()
            } label: {
                Text("Cancel")
                    .font(.title3)
            }
            .padding()
            List {
                Section("Most likely") {
                    ForEach(accounts.filter { account in
                        identifiers.contains(account.service) ||
                        identifiers.contains(where: {
                            account.aliases.contains($0)
                        })
                    }, id: \.id) { account in
                        if type == .passwordList {
                            AccountDisplay(account: account)
                                .onTapGesture {
                                    let service = account.service
                                    provideCredentials(account.username, account.password ?? "", service, account.id, account.totp)
                                }
                        } else if type == .totpList {
                            
                        }
                    }
                }
                Section("All Passwords") {
                    ForEach(accounts, id: \.id) { account in
                        AccountDisplay(account: account)
                            .onTapGesture {
                                let service = identifiers.sorted(by: {$0.count > $1.count}).first ?? account.service
                                provideCredentials(account.username, account.password ?? "", service, account.id, account.totp)
                            }
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding(.trailing)
#if DEBUG
        .onAppear() {
            if accounts.isEmpty {
                let accounts = [Account(service: "google.com", username: "koring.mia@gmail.com", totp: false), Account(service: "google.com", username: "miakoring@gmail.com", totp: false), Account(service: "amethystbrowser.de", username: "koring.mia@gmail.com", totp: false)]
                for account in accounts {
                    context.insert(account)
                }
            }
        }
        #endif
    }
}
