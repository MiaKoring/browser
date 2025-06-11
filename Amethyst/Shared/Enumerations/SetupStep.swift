//  MeiliSetupStep.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 06.12.24.
//


import SwiftUI
import CryptoKit
import MeiliSearch
import OSLog

enum SetupStep: Int, CaseIterable {
    case welcome
    case searchEngine
    case sidebarOrientation
    case whatIs
    case installMeili
    case setupAutomator
    case setupAutomator1
    case setupLoginItems
    case checkMeiliRunning
}

extension SetupStep: Identifiable {
    var id: Int {
        self.rawValue
    }
    
    var next: SetupStep {
        SetupStep(rawValue: self.rawValue + 1) ?? .checkMeiliRunning
    }
     
    var previous: SetupStep {
        SetupStep(rawValue: self.rawValue - 1) ?? .whatIs
    }
}

extension SetupStep {
    @ViewBuilder
    func view(current: Binding<SetupStep>) -> some View {
        switch self {
        case .welcome:
            WelcomeScreen(current: current)
        case .searchEngine:
            VStack {
                Text("Choose your websearch engine")
                    .font(.title)
                    .padding(.bottom, 15)
                SearchEngineSelectionView(maxHeight: 55)
            }
        case .sidebarOrientation:
            SidebarOrientation()
        case .whatIs:
            WhatIsMeili()
        case .installMeili:
            InstallMeili()
        case .setupAutomator:
            SetupAutomator()
        case .setupAutomator1:
            SetupAutomator1()
        case .setupLoginItems:
            
        case .checkMeiliRunning:
            CheckMeiliRunning()
        }
        
    }
    
    private struct CheckMeiliRunning: View {
        @State var state: String = ""
        @Environment(\.dismiss) var dismiss
        @Environment(AppViewModel.self) var appViewModel
        static var logger = Logger(subsystem: AmethystApp.subSystem, category: "SetupStep")
        var body: some View {
            VStack {
                Text("Check Setup")
                    .font(.title)
                Text("Now lets check Meilisearch is running correctly real quick!")
                Button {
                    SwiftUI.Task {
                        guard let url = URL(string: "http://localhost:7700/indexes") else { return }
                        var request = URLRequest(url: url)
                        request.httpMethod = "GET"
                        guard let key = KeyChainManager.getValue(for: .meiliMasterKey) else {
                            state = "Key missing in keychain. please start from copying again"
                            return
                        }
                        request.addValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
                        do {
                            let res = try await URLSession.shared.data(for: request)
                            guard let response = res.1 as? HTTPURLResponse else {
                                return
                            }
                            if response.statusCode == 200 {
                                state = "Success!"
                            } else {
                                state = "An error occured. Please try setup again."
                            }
                        } catch {
                            state = "Meilisearch seems not to be running. Please try starting your Automator-App."
                        }
                    }
                } label: {
                    Text("check")
                }
                .buttonStyle(.borderless)
                Text(state)
                    .bold()
                    .foregroundStyle(state == "Success!" ? .green: .red)
                if state == "Success!" {
                    Button {
                        do {
                            appViewModel.meili = try MeiliSearch(host: "http://localhost:7700", apiKey: KeyChainManager.getValue(for: .meiliMasterKey))
                            UDKey.wasSetupOnce.boolValue = true
                        } catch {
                            Self.logger.error("An Error occured while setting up Meilisearch connection: \(error)")
                        }
                        dismiss()
                    } label: {
                        Text("Finish Setup")
                            .font(.title2)
                            .bold()
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }
    private struct WhatIsMeili: View {
        var body: some View {
            VStack {
                Text("Meilisearch")
                    .font(.title)
                Image("MeiliSearchExplanation1")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: .myPurple, radius: 10)
                    .padding(.horizontal, 30)
                Text("Meilisearch is a trusted, open-source search engine that powers Amethyst’s fast and accurate search suggestions—all while keeping your privacy intact. Your search history never leaves your device, and suggestions improve over time as Amethyst adapts to your preferences, completely offline")
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
        }
    }
    
    private struct InstallMeili: View {
        var body: some View {
            VStack {
                Text("Install Meilisearch")
                    .font(.title)
                Text("To install Meilisearch paste and execute the command below in the Terminal at a destination you like. Do NOT run it afterwards like it will tell you. Just ignore it. Remember the path where Meilisearch is located.")
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                Text("curl -L https://install.meilisearch.com | sh")
                    .textSelection(.enabled)
                    .padding(10)
                    .background() {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.gray.mix(with: .black, by: 0.7))
                    }
                Button {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString("curl -L https://install.meilisearch.com | sh", forType: .string)
                } label: {
                    Text("Copy")
                }
                .buttonStyle(.borderless)
                Button {
                    let automatorPath = "/System/Applications/Utilities/Terminal.app"
                    NSWorkspace.shared.open(URL(fileURLWithPath: automatorPath))
                } label: {
                    Text("Open Terminal")
                }
                .buttonStyle(.borderless)
                .padding(.bottom, 10)
            }
        }
    }
    
    private struct SetupAutomator: View {
        var body: some View {
            VStack {
                Text("Setup Meilisearch")
                    .font(.title)
                Image("AutomatorApp")
                    .setupImageStyle()
                Text("To automatically start meilisearch, click \"Copy\", then click \"Open Automator\", click \"New Document\" and choose \"Application\".")
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                HStack {
                    Button {
                        var key = ""
                        if let generated = KeyChainManager.getValue(for: .meiliMasterKey) {
                            key = generated
                        } else {
                            guard let masterKey = KeyChainManager.generateSecureKey(length: 16) else {
                                return
                            }
                            KeyChainManager.setValue(masterKey, for: .meiliMasterKey)
                            key = masterKey
                        }
                        let content =
"""
cd "Absolute-Path-to-meilisearch-folder"
./meilisearch --master-key="\(key)" &
disown
"""
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(content, forType: .string)
                    } label: {
                        Text("Copy")
                    }
                    .buttonStyle(.borderless)
                    .padding(.bottom, 10)
                    Button {
                        let automatorPath = "/System/Applications/Automator.app"
                        NSWorkspace.shared.open(URL(fileURLWithPath: automatorPath))
                    } label: {
                        Text("Open Automator")
                    }
                    .buttonStyle(.borderless)
                    .padding(.bottom, 10)
                }
                
            }
        }
    }
    
    private struct SetupAutomator1: View {
        var body: some View {
            VStack {
                Text("Setup Meilisearch")
                    .font(.title)
                Image("chooseShellScript")
                    .setupImageStyle()
                Text("Now search for \"run\" and drag \"Run Shell Script\" to the right. Then replace \"cat\" in the textfield with the contents you copied before. Replace \"Absolute-Path-to-meilisearch-folder\" with the path to where you installed meilisearch. Make sure to use the absolute path. \nRight: /Users/miakoring/Documents/Meili | Wrong: ~/Documents/Meili. \nRun the script once, by clicking the button in the top-right. Now you're ready. Save the application, make sure to choose File Format \"Application\"")
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
        }
    }
    
    private struct SetupLoginItems: View {
        var body: some View {
            VStack {
                Text("Setup Login Item")
                    .font(.title)
                Image("LoginItems")
                    .setupImageStyle()
                Text("Congratulations! You're almost there! The last step ist to configure your Automator-App to open at login. For that click on \"Open Login-Items\". That Button will bring you directly in the Settings to the Login Items. There just click on the plus, like marked in the image above and add you Automator App!")
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                Button {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Text("Open Login-Items")
                }
                .buttonStyle(.borderless)
                .padding(.bottom, 10)
            }
        }
    }
}
