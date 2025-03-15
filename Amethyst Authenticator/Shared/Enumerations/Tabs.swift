//
//  Tabs.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 15.03.25.
//

import SwiftUI
import AmethystAuthenticatorCore

enum TabCase: CaseIterable {
    case passwords
    case oneTimeCodes
    case trash
    case settings
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
        case .settings:
           "gear"
        }
    }
    
    @ViewBuilder func view(selectedAccount: Binding<Account?>) -> some View {
        switch self {
        case .passwords:
            PasswordList(selectedAccount: selectedAccount)
        case .oneTimeCodes:
            PasswordList(selectedAccount: selectedAccount, showTOTP: true)
                .overlay(alignment: .bottom) {
                    TOTPDurationDisplay()
                }
        case .trash:
            PasswordList(selectedAccount: selectedAccount, showDeleted: true)
        case .settings:
            Text("upcoming")
        }
    }
}
