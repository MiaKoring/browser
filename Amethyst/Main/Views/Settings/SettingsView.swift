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
    @StateObject var fileDownloader = SetupStep.DownloadIndexView.FileDownloader()
    @State var useMacos26upDesign = !UDKey.useOldDesign.boolValue
    @State var translucency: Double = UDKey.tranclucency.doubleValue <= 0 ? 0.4 : UDKey.tranclucency.doubleValue
    var body: some View {
        ZStack {
            HostingWindowFinder(callback: { window in
                if let window {
                    if let id = window.identifier {
                        self.appViewModel.currentlyActiveWindowId = id.rawValue
                        //self.appViewModel.displayedWindows.insert(id.rawValue)
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
                            UDKey.useOldDesign.boolValue = !useMacos26upDesign
                            appViewModel.useMacOS26Design = useMacos26upDesign
                        }
                    Slider(value: $translucency, in: 0.1...0.9) {
                        Text("Opacity while floating: \(translucency)")
                    } onEditingChanged: { isEditing in
                        if !isEditing {
                            UDKey.tranclucency.doubleValue = translucency
                        }
                    }
                } label: {
                    Label("Design", systemImage: "paintbrush.pointed")
                }
                Tab {
                    ProductivitySettings()
                } label: {
                    Label("Productivity", systemImage: "chart.bar")
                }
                Tab {
                    SearchEngineSelectionView()
                } label: {
                    Label("Search Engine", systemImage: "globe")
                }
                Tab {
                    SearchSuggestion()
                        .environmentObject(fileDownloader)
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
        @State var current: SetupStep = .downloadIndex
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
                            if current != .downloadIndex {
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
    
    struct ShortcutEditView: View {
        @State var manager: ShortcutFeatureManager
        @State var showTemporary = false
        
        var body: some View {
            List {
                HStack {
                    Text("Shortcut")
                        .frame(width: 60, alignment: .leading)
                    Divider()
                    Text("Destination")
                    Spacer()
                    Button {
                        showTemporary = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(showTemporary)
                }
                .foregroundStyle(.secondary)
                if showTemporary {
                    ShortcutRow(manager: manager, shortcut: "", destination: "") {
                        self.showTemporary = false
                    }
                }
                ForEach(manager.registered.keys.sorted()) { key in
                    ShortcutRow(manager: manager, shortcut: key, destination: manager.registered[key]!)
                }
            }
        }
        struct ShortcutRow: View {
            let manager: ShortcutFeatureManager
            @State var shortcut: String
            @State var destination: String
            let oldShortcut: String
            let oldDestination: String
            let onPersist: (() -> Void)?
            
            init(manager: ShortcutFeatureManager, shortcut: String, destination: String, onPersist: (() -> Void)? = nil) {
                self.manager = manager
                self._shortcut = State(initialValue: shortcut)
                self._destination = State(initialValue: destination)
                self.oldShortcut = shortcut
                self.oldDestination = destination
                self.onPersist = onPersist
            }
            
            var body: some View {
                HStack {
                    TextField("", text: $shortcut)
                        .frame(width: 60)
                    Divider()
                    TextField("", text: $destination)
                    Button("Save") {
                        if shortcut != oldShortcut {
                            manager.remove(key: oldShortcut)
                        }
                        manager.set(destination, for: shortcut)
                        onPersist?()
                    }
                    .disabled(shortcut.isEmpty || destination.isEmpty || (shortcut == oldShortcut && destination == oldDestination))
                    Button {
                        manager.remove(key: oldShortcut)
                        onPersist?()
                    } label: {
                        Image(systemName: "minus")
                    }
                }
            }
        }
    }
    
    struct ProductivitySettings: View {
        @State private var selection = ProductivityView.bangs
        var body: some View {
            HStack {
                ForEach(ProductivityView.allCases, id: \.rawValue) { feature in
                    feature.button(selection: $selection)
                }
            }
            switch selection {
                case .bangs:
                    ShortcutEditView(manager: BangManager.shared)
                case .commands:
                    ShortcutEditView(manager: CommandsManager.shared)
            }
        }
        
        private enum ProductivityView: String, CaseIterable {
            case bangs = "Bang Queries"
            case commands = "Commands"
            
            @ViewBuilder
            func button(selection: Binding<Self>) -> some View {
                if #available(macOS 26, *) {
                    Button(rawValue) {
                        selection.wrappedValue = self
                    }
                    .if(selection.wrappedValue == self) { view in
                        view.buttonStyle(.glassProminent)
                    }
                } else {
                    Button(rawValue) {
                        selection.wrappedValue = self
                    }
                    .if(selection.wrappedValue == self) { view in
                        view.buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
}
