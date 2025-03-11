//
//  HomeView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.03.25.
//

import SwiftUI
import AmethystAuthenticatorCore

struct HomeViewIpad: View {
    @State var selectedAccount: Account?
    @State var displayedContent: DisplayedContent = .passwords
    var body: some View {
        NavigationSplitView {
            Button("Passwords") {
                displayedContent = .passwords
            }
        } content: {
            if displayedContent == .passwords {
                PasswordList(selectedAccount: $selectedAccount)
            } else {
                Text("select")
            }
        } detail: {
            if displayedContent == .passwords, let selectedAccount {
                Text(selectedAccount.service)
            }
        }
    }
}

enum DisplayedContent {
    case passwords
    case deleted
    case totp
    case security
}

#Preview {
    HomeView()
}
