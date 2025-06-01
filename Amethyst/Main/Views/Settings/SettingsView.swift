//
//  SettingsView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 13.12.24.
//

import SwiftUI
import AppKit

struct SettingsView: View {
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
                IgnoredErrorsView()
            } label: {
                Label("Ignored Errors", systemImage: "exclamationmark.octagon")
            }
        }
    }
}
