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
    @State var selectedTab: TabCase = .passwords
    @Environment(\.modelContext) var context
    @Environment(\.colorScheme) var appearance
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            //LazyVGrid(columns: [.init(spacing: 20), .init(spacing: 20)]) {
            VStack {
                ForEach(TabCase.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: tab.imageName)
                                Spacer()
                                tab.countView
                            }
                            Text(tab.rawValue)
                        }
                        .frame(height: 50)
                        .padding(.horizontal)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(tab.color)
                                .overlay {
                                    if tab == selectedTab {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(style: .init(lineWidth: 3))
                                            .fill(tab.color.mix(with: appearance == .dark ? .secondary : .white.mix(with: .black, by: 0.1), by: 0.4))
                                    }
                                }
                        }
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                }
                Spacer()
            }
            .padding()
            .navigationSplitViewColumnWidth(135)
        } content: {
            selectedTab.view(selectedAccount: $selectedAccount)
        } detail: {
            ContentUnavailableView("No Item Selected", systemImage: "key.2.on.ring.fill")
                .navigationSplitViewColumnWidth(min: 250, ideal: 320)
        }
    }
}

#Preview {
    HomeView()
}
