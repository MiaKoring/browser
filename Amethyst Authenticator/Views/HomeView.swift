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
    @State var recievedURL: URL? = nil
    @State var showSelector: Bool = false
    @State var showAccountList: Bool = false
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        TabView() {
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
            showSelector = true
        }
        .alert("Add OTP to existing Account?", isPresented: $showSelector) {
            Button ("Yes") {
                
            }
            Button("Create New") {
                
            }
            Button("Cancel", role: .cancel) {
                showSelector = false
                recievedURL = nil
            }
        }
    }
}
