//
//  Tabs.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 15.03.25.
//

import SwiftUI
import SwiftData
import AmethystAuthenticatorCore

enum TabCase: String, CaseIterable {
    case passwords = "Passwords"
    case oneTimeCodes = "Codes"
    case trash = "Trash"
}
extension TabCase {
    var imageName: String {
        switch self {
        case .passwords:
            "key"
        case .oneTimeCodes:
            "key.viewfinder"
        case .trash:
            "trash"
        }
    }
    
    private var fetchDescriptor: FetchDescriptor<Account> {
        switch self {
        case .passwords:
            FetchDescriptor<Account>(predicate: #Predicate { $0.deletedAt == nil })
        case .oneTimeCodes:
            FetchDescriptor<Account>(predicate: #Predicate { $0.totp })
        case .trash:
            FetchDescriptor<Account>(predicate: #Predicate { $0.deletedAt != nil })
        }
    }
    
    var countView: some View {
        struct CountView: View {
            @Query var accounts: [Account]
            var tabCase: TabCase
            
            init(tabCase: TabCase) {
                self._accounts = Query(tabCase.fetchDescriptor, animation: .easeInOut)
                self.tabCase = tabCase
            }
            var body: some View {
                Text("\(accounts.count)")
            }
        }
        return CountView(tabCase: self)
    }
    
    var color: Color {
        switch self {
        case .passwords:
                .blue
        case .oneTimeCodes:
                .orange
        case .trash:
                .red
        }
    }
    
    @ViewBuilder func view(selectedAccount: Binding<Account?>) -> some View {
        switch self {
        case .passwords:
            PasswordList(selectedAccount: selectedAccount)
        case .oneTimeCodes:
            VStack {
                TOTPDurationDisplay()
                PasswordList(selectedAccount: selectedAccount, showTOTP: true)
            }
        case .trash:
            PasswordList(selectedAccount: selectedAccount, showDeleted: true)
        }
    }
}
