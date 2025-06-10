//
//  Untitled.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//
import SwiftUI

struct Sidebar: View {
    @Environment(ContentViewModel.self) var contentViewModel
    @Environment(\.colorScheme) var appearance
    var body: some View {
        ZStack {
            VStack {
                contentViewModel.sidebarOrientation.tabTopRow()
                .addTopRowPadding(isFixed: contentViewModel.isSidebarFixed)
                URLDisplay()
                    .padding(.top)
                    .padding(.horizontal, 3)
                ClearDivider()
                NewTabButton()
                .padding(.horizontal, 3)
                ATabView()
                    .padding(-15)
                    .padding(.horizontal, 3)
                    .safeAreaInset(edge: .bottom) {
                        DownloadOverview()
                    }
                if(!AppViewModel.isDefaultBrowser()) { SetDefaultBrowserButton() }
            }
            FeedbackButton()
                .placeBottomLeading()
        }
        .makeSidebar(isFixed: contentViewModel.isSidebarFixed, appearance: appearance)
    }
    
    struct ClearDivider: View {
        @Environment(ContentViewModel.self) var contentViewModel
        @Environment(\.colorScheme) var appearance
        var body: some View {
            HStack {
                VStack { Divider() }
                Button { contentViewModel.tabs = [] } label: {
                    Text("clear")
                        .font(.footnote)
                        .foregroundStyle(appearance == .dark ? Color.gray: Color.gray.mix(with: .black, by: 0.4))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private struct NewTabButton: View {
        @Environment(ContentViewModel.self) var contentViewModel
        @State var isNewTabHovered: Bool = false
        var body: some View {
            Button { contentViewModel.triggerNewTab.toggle() } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("New Tab")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(true: .mainColorMix.opacity(0.1), false: .ultraThinMaterial, with: isNewTabHovered)
                }
            }
            .buttonStyle(.plain)
            .onHover { hovering in isNewTabHovered = hovering }
            
        }
    }
    
    private struct SetDefaultBrowserButton: View {
        var body: some View {
            Button("Set as default Browser") {
                Task {
                    do {
                        try await NSWorkspace.shared.setDefaultApplication(at: Bundle.main.bundleURL, toOpenURLsWithScheme: "http")
                    } catch {
                        print(error)
                    }
                }
            }
            .buttonStyle(.borderless)
            .padding(.bottom, 10)
        }
    }
    
    private struct DownloadOverview: View {
        @State var downloadOverviewButtonIsHovered: Bool = false
        @Environment(\.colorScheme) var appearance
        var body: some View {
            VStack(alignment: .trailing){
                if downloadOverviewButtonIsHovered {
                    ShortDownloadOverview()
                        .padding(.bottom, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(appearance == .dark ? .myPurple.mix(with: .white, by: 0.1): Color.test)
                        }
                        .onHover { hovering in downloadOverviewButtonIsHovered = hovering }
                        .padding(.bottom, -6)
                }
                DownloadOverviewButton(isHovered: $downloadOverviewButtonIsHovered)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}
