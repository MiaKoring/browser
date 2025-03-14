//
//  HomeView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.03.25.
//

import SwiftUI
import AmethystAuthenticatorCore

struct HomeView: View {
    @State var selectedAccount: Account?
    @State var displayedContent: DisplayedContent = .passwords
    
    var body: some View {
        NavigationStack {
            NavigationLink {
                PasswordList(selectedAccount: $selectedAccount)
                    .navigationTitle("Passwords")
            } label: {
                Text("Passwords")
            }
            NavigationLink {
                PasswordList(selectedAccount: $selectedAccount, showDeleted: true)
                    .navigationTitle("Trash")
            } label: {
                Text("Deleted")
            }
        }
    }
}
