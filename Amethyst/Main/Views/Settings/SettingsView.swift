//
//  SettingsView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 13.12.24.
//

import SwiftUI
import AppKit

struct SettingsView: View {
    @Environment(AppViewModel.self) var appViewModel
    @State var useMacos26upDesign = UDKey.useMacOS26upDesign.boolValue
    var body: some View {
        ZStack {
            HostingWindowFinder(callback: { window in
                if let window {
                    if let id = window.identifier {
                        self.appViewModel.currentlyActiveWindowId = id.rawValue
                        self.appViewModel.displayedWindows.insert(id.rawValue)
                    }
                }
            })
            TabView {
                Tab {
                    KeyBindsView()
                } label: {
                    Label("Key Bindings", systemImage: "keyboard")
                }
                Tab {
                    Toggle("Use New Design", isOn: $useMacos26upDesign)
                        .toggleStyle(.switch)
                        .onChange(of: useMacos26upDesign) {
                            UDKey.useMacOS26upDesign.boolValue = useMacos26upDesign
                        }
                } label: {
                    Label("Design", systemImage: "paintbrush.pointed")
                }
                Tab {
                    SearchEngineSelectionView()
                } label: {
                    Label("Search Engine", systemImage: "globe")
                }
                Tab {
                    SearchSuggestion()
                } label: {
                    Label("Search Suggestions", systemImage: "sparkle.magnifyingglass")
                }
                Tab {
                    SidebarOrientation()
                } label: {
                    Label("SidebarOrientation", systemImage: "sidebar.left")
                }
                Tab {
                    IgnoredErrorsView()
                } label: {
                    Label("Ignored Errors", systemImage: "exclamationmark.octagon")
                }
            }
        }
    }
    
    struct SearchSuggestion: View {
        @State var current: SetupStep = .whatIs
        var body: some View {
            BackgroundView(shouldRotate: false) {
                VStack {
                    ZStack {
                        ForEach(SetupStep.allCases) { step in
                            step.view(current: $current)
                                .frame(width: 680, height: 380)
                                .if (step != current) { view in
                                    view.hidden()
                                }
                                .padding(.top, 10)
                        }
                        HStack {
                            if current != .whatIs {
                                Button {
                                    current = current.previous
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.title)
                                        .padding(.leading, 5)
                                }
                                .buttonStyle(.borderless)
                            }
                            Spacer()
                            if current != .checkMeiliRunning && current != .welcome {
                                Button {
                                    current = current.next
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .font(.title)
                                        .padding(.trailing, 5)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                    .frame(height: 450)
                }
                .background() {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.thinMaterial)
                }
                .padding(10)
            }
        }
    }
}
