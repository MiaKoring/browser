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
    @State var showTOTPSetup: Bool = false
    @State var showSelector: Bool = false
    @State var showAccountList: Bool = false
    @Environment(\.modelContext) var context
    
    var body: some View {
        PasswordList(selectedAccount: $selectedAccount)
    }
}

#Preview {
    HomeView()
}
