//
//  SettingsView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 13.12.24.
//

import SwiftUI
import AppKit

struct SettingsView: View {
    @State var current: SetupStep = .whatIs
    var body: some View {
        TabView {
            Tab {
                KeyBindsView()
            } label: {
                Label("Key Bindings", systemImage: "keyboard")
            }
            Tab {
                SearchEngineSelectionView()
            } label: {
                Label("Search Engine", systemImage: "globe")
            }
            Tab {
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
            } label: {
                Label("Search Suggestions", systemImage: "sparkle.magnifyingglass")
            }
            Tab {
                IgnoredErrorsView()
            } label: {
                Label("Ignored Errors", systemImage: "exclamationmark.octagon")
            }
        }
    }
}
