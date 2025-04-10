//
//  ContentView.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//
import Combine
import SwiftData
import SwiftUI
import WebKit


extension ContentView: View, TabOpener {
    
    
    var body: some View {
        GeometryReader { reader in
            BackgroundView {
                ZStack {
                    HostingWindowFinder(callback: { window in
                        if let window {
                            if let id = window.identifier {
                                self.appViewModel.currentlyActiveWindowId = id.rawValue
                                self.appViewModel.displayedWindows.insert(id.rawValue)
                                self.window = window
                            }
                        }
                    })
                    if appViewModel.highlightedWindow == contentViewModel.id {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 5)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    VStack {
                        HStack {
                            Rectangle()
                                .fill(.clear)
                                .frame(width: 20, height: 20)
                                .contentShape(Rectangle())
                                .onHover { hovering in
                                    showMacosWindowIconsAreaHovered = hovering
                                }
                            Spacer()
                        }
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        if contentViewModel.isSidebarFixed {
                            HStack {
                                Sidebar()
                                    .frame(maxWidth: sidebarWidth)
                                    .overlay(alignment: .trailing) {
                                        SidebarResizer(sidebarWidth: $sidebarWidth)
                                    }
                                if contentViewModel.tabs.isEmpty {
                                    Spacer()
                                }
                            }
                        }
                        ZStack {
                            ForEach(contentViewModel.tabs, id: \.self) { tab in
                                WebView(tabID: tab.id, webViewModel: tab.webViewModel)
                            }
                        }
                        if contentViewModel.isPasswordFixed {
                            HStack {
                                if contentViewModel.tabs.isEmpty {
                                    Spacer()
                                }
                                PasswordSidebar()
                                    .frame(maxWidth: passwordsWidth)
                                    .overlay(alignment: .leading) {
                                        SidebarResizer(sidebarWidth: $passwordsWidth, trailing: true)
                                    }
                            }
                        }
                    }
                    if contentViewModel.showInlineSearch, let tab = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab}) {
                        VStack {
                            HStack {
                                Spacer()
                                DocumentSearchView(webViewModel: tab.webViewModel, text: contentViewModel.lastInlineQuery)
                                    .environmentObject(contentViewModel)
                                    .frame(maxWidth: 270)
                                    .padding(30)
                            }
                            Spacer()
                        }
                    }
                    HStack {
                        if contentViewModel.isSidebarShown && !contentViewModel.isSidebarFixed {
                            Sidebar()
                                .transition(.move(edge: .leading))
                        }
                        Spacer()
                        if contentViewModel.isPasswordShown && !contentViewModel.isPasswordFixed {
                            PasswordSidebar()
                                .transition(.move(edge: .trailing))
                        }
                    }
                    if (showMacosWindowIconsAreaHovered || macosWindowIconsHovered) && !contentViewModel.isSidebarShown && !contentViewModel.isSidebarFixed {
                        
                        VStack {
                            HStack {
                                MacOSButtons()
                                    .padding(10)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(.regularMaterial)
                                            .background(Color.myPurple.opacity(0.2))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .onHover { hovering in
                                        macosWindowIconsHovered = hovering
                                    }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
            }
            .onChange(of: contentViewModel.triggerNewTab) {
                showInputBar = true
            }
            .onChange(of: contentViewModel.tabs) {
                if contentViewModel.tabs.isEmpty {
                    contentViewModel.isSidebarShown = true
                }
            }
            .onChange(of: contentViewModel.triggerRestoredHistory) {
                showRestoredHistory.toggle()
                print("triggered")
            }
            .onAppear() {
                onAppear()
            }
            .sheet(isPresented: $showInputBar) {
                InputBar(text: $inputBarText, showInputBar: $showInputBar) { text in
                    handleInputBarSubmit(text: text)
                    inputBarText = ""
                    showInputBar = false
                }
                .frame(maxWidth: max(550, min(reader.size.width / 2, 800)))
            }
            .onChange(of: contentViewModel.currentTab) {
                if contentViewModel.currentTab != nil {
                    contentViewModel.isLoaded = true
                }
            }
            .onChange(of: contentViewModel.showHistory) {
                showHistory = contentViewModel.showHistory
            }
            .onChange(of: appViewModel.showMeiliSetup) {
                showMeiliSetup = appViewModel.showMeiliSetup
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(
                self,
                name: NSWindow.didBecomeMainNotification,
                object: nil
            )
        }
        .environment(contentViewModel)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .sheet(isPresented: $showRestoredHistory) {
            RestoredHistory()
                .environment(contentViewModel)
                .frame(width: 350, height: 400)
        }
        .sheet(isPresented: $showHistory) {
            contentViewModel.showHistory = false
        } content: {
            HistoryView()
                .frame(width: 400, height: 500)
        }
        .sheet(isPresented: $showMeiliSetup) {
            appViewModel.showMeiliSetup = false
        } content: {
            MeiliSetup()
                .frame(width: 700, height: 400)
                .interactiveDismissDisabled()
        }
        .onChange(of: appViewModel.currentlyActiveWindowId) {
            print(appViewModel.currentlyActiveWindowId)
        }
        .onAppear {
            print("downloadedItems: \(downloadedItems)")
        }
    }
    
}


#Preview {
    ContentView()
        .environment(AppViewModel())
}

