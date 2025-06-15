//
//  Untitled.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//
import SwiftUI

struct Sidebar: View {
    @Environment(AppViewModel.self) var appViewModel
    @Environment(ContentViewModel.self) var contentViewModel
    @Environment(\.colorScheme) var appearance
    var body: some View {
        ZStack {
            VStack {
                contentViewModel.sidebarOrientation.tabTopRow()
                    .if(!appViewModel.useMacOS26Design) { view in
                        view
                            .addTopRowPadding(isFixed: contentViewModel.isSidebarFixed)
                    }
                    .if(appViewModel.useMacOS26Design) { view in
                        view
                            .padding(.bottom, -10)
                    }
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
        .decideSidebarStyling(isFixed: contentViewModel.isSidebarFixed, appearance: appearance, useMacos26Desing: appViewModel.useMacOS26Design)
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
        @Environment(AppViewModel.self) var appViewModel
        @State var downloadOverviewButtonIsHovered: Bool = false
        @Environment(\.colorScheme) var appearance
        var body: some View {
            VStack(alignment: .trailing){
                if downloadOverviewButtonIsHovered {
                    ShortDownloadOverview()
                        .transition(.move(edge: .bottom))
                        .padding(.bottom, 10)
                        .background {
                            if #available(macOS 26.0, *), appViewModel.useMacOS26Design {
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .blur(radius: 5)
                            } else {
                                Rectangle()
                                    .fill(appearance == .dark ? .myPurple.mix(with: .white, by: 0.1): Color.test)
                            }
                        }
                        .onHover { hovering in downloadOverviewButtonIsHovered = hovering }
                        .padding(.bottom, -6)
                        .ifMacOS26Available(and: appViewModel.useMacOS26Design) { view in
                            view
                                .padding(.horizontal, -5)
                        }
                }
                DownloadOverviewButton(isHovered: $downloadOverviewButtonIsHovered)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}
