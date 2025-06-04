//
//  Untitled.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//
import SwiftUI

struct Sidebar: View {
    @Environment(ContentViewModel.self) var contentViewModel
    @Environment(AppViewModel.self) var appViewModel
    @Environment(\.colorScheme) var appearance
    @State var isSideBarButtonHovered: Bool = false
    @State var isNewTabHovered: Bool = false
    @State var isBackHovered: Bool = false
    @State var isForwardHovered: Bool = false
    @State var isReloadHovered: Bool = false
    @State var downloadOverviewButtonIsHovered: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    MacOSButtons()
                        .padding(.trailing)
                        .padding(.leading, 5)
                    Image(systemName: "sidebar.left")
                        .sidebarTopButton(hovered: $isSideBarButtonHovered, appearance: appearance) {
                            contentViewModel.isSidebarFixed.toggle()
                            contentViewModel.isSidebarShown = false
                        }
                    Spacer()
                    Image(systemName: "chevron.left")
                        .sidebarTopButton(hovered: $isBackHovered, appearance: appearance) {
                            if let tab = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab}) {
                                tab.webViewModel.webView?.goBack()
                            }
                        }
                    Image(systemName: "chevron.right")
                        .sidebarTopButton(hovered: $isForwardHovered, appearance: appearance) {
                            if let tab = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab}) {
                                tab.webViewModel.webView?.goForward()
                            }
                        }
                    Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
                        .sidebarTopButton(hovered: $isReloadHovered, appearance: appearance) {
                            if let tab = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab}) {
                                tab.webViewModel.webView?.reload()
                            }
                        }
                }
                .padding(.leading, contentViewModel.isSidebarFixed ? 5: 0)
                .padding(.top, contentViewModel.isSidebarFixed ? 5: 0)
                URLDisplay()
                    .padding(.top)
                    .padding(.horizontal, 3)
                HStack{
                    VStack {
                        Divider()
                    }
                    Button {
                        contentViewModel.tabs = []
                    } label: {
                        Text("clear")
                            .font(.footnote)
                            .foregroundStyle(appearance == .dark ? Color.gray: Color.gray.mix(with: .black, by: 0.4))
                    }
                    .buttonStyle(.plain)
                }
                HStack {
                    Image(systemName: "plus")
                    Text("New Tab")
                    Spacer()
                }
                .allowsHitTesting(false)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background {
                    HStack {
                        if isNewTabHovered {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.mainColorMix.opacity(0.1))
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                        }
                    }
                    .onTapGesture {
                        contentViewModel.triggerNewTab.toggle()
                    }
                    .onHover { hovering in
                        isNewTabHovered = hovering
                    }
                }
                .padding(.horizontal, 3)
                
                ATabView()
                    .padding(-15)
                    .padding(.horizontal, 3)
                if(!AppViewModel.isDefaultBrowser()) {
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
                DownloadOverviewButton(isHovered: .constant(false))
                    .hidden()
                    .padding(.top)
            }
            VStack {
                Spacer()
                HStack {
                    FeedbackButton()
                    Spacer()
                }
            }
            VStack {
                Spacer()
                if downloadOverviewButtonIsHovered {
                    ShortDownloadOverview()
                        .padding(.bottom, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                    .fill(appearance == .dark ? .myPurple.mix(with: .white, by: 0.1): Color.test)
                        }
                        .onHover { hovering in
                            downloadOverviewButtonIsHovered = hovering
                        }
                        .padding(.bottom, -6)
                }
                HStack {
                    Spacer()
                    DownloadOverviewButton(isHovered: $downloadOverviewButtonIsHovered)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .frame(maxWidth: contentViewModel.isSidebarFixed ? .infinity: 300)
        .padding(5)
        .background {
            HStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(appearance == .dark ? .myPurple.mix(with: .white, by: 0.1): Color.test)
            }
            .overlay {
                if appearance == .light {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 1)
                        .fill(Color.gray)
                        .shadow(radius: 5)
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 1)
                        .fill(.ultraThickMaterial)
                        .shadow(radius: 5)
                }
            }
        }
        .padding(contentViewModel.isSidebarFixed ? 0: 8)
    }
}
