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
    
    var body: some View {
        NavigationSplitView {
            LazyVGrid(columns: [.init(spacing: 20), .init(spacing: 20)]) {
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
                        .frame(width: 70, height: 50)
                        .padding(.horizontal)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(tab.color)
                                .overlay {
                                    if tab == selectedTab {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(style: .init(lineWidth: 3))
                                            .fill(tab.color.mix(with: .secondary, by: 0.4))
                                    }
                                }
                        }
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                }
            }
            .padding()
            Spacer()
            .navigationSplitViewColumnWidth(230)
        } content: {
            selectedTab.view(selectedAccount: $selectedAccount)
        } detail: {
            ContentUnavailableView("No Item Selected", systemImage: "key.2.on.ring.fill")
        }
    }
}

#Preview {
    HomeView()
}
