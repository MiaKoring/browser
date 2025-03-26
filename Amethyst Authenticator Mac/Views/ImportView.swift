//
//  ImportView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 25.03.25.
//
import SwiftUI
import AmethystAuthenticatorCore

struct ImportView: View {
    var url: URL
    @State var showFileImporter: Bool = false
    @State var stage: ImportStage = .waiting
    @State var progress: Double = 0.0
    @State var isRunning = false
    @State var importFormat = ImportFormat.apple
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @State var importError: ImportError?
    @State var failedAccounts: [Account]?
    @State var importedAccounts: Int?
    
    @ObservedObject var options = ImportOptions()
    
    var body: some View {
        ZStack {
            VStack {
                Text("Import Settings")
                    .font(.title2)
                    .bold()
                Form {
                    Picker("CSV Format", selection: $importFormat) {
                        ForEach(ImportFormat.allCases, id: \.self) { format in
                            Button(format.rawValue) {
                                importFormat = format
                            }
                        }
                    }
                    Toggle("Import Notes", isOn: $options.transferNotes)
                    Toggle("Import Title", isOn: $options.transferTitle)
                    Toggle("Fetch Title & Icon", isOn: $options.fetchServiceData)
                }
                .formStyle(.grouped)
                Button("Start Import") {
                    isRunning = true
                }
            }
            .if(isRunning) { view in
                view.hidden()
            }
            if isRunning {
                VStack {
                    switch stage {
                    case .waiting:
                        Text("Waiting for import to begin...")
                    case .readFile:
                        Text("reading file...")
                    case .parseData:
                        Text("parsing data...")
                    case .fetchExistingAccounts:
                        Text("fetching existent accounts...")
                    case .importAccounts:
                        Text("creating accounts...")
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                    case .complete:
                        if let importError {
                            Text("An Error occured")
                            Text(importError.localizedDescription)
                        } else {
                            ImportResultView(importedAccounts: importedAccounts ?? 0, failedAccounts: failedAccounts ?? [])
                            Button("Close") {
                                dismiss()
                            }
                        }
                    }
                }
                .task {
                    let result = await importFormat.process(url: url, stage: $stage, importProcess: $progress, context: context, options: options)
                    switch result {
                    case .success(let result):
                        failedAccounts = result.failed
                        importedAccounts = result.imported
                        stage = .complete
                    case .failure(let error):
                        importError = error
                        print(error.localizedDescription)
                        stage = .complete
                    }
                }
            }
        }
        .padding()
    }
}

struct ImportResultView: View {
    var importedAccounts: Int
    var failedAccounts: [Account]
    var body: some View {
        Text("Imported: \(importedAccounts)")
        Text("Failed: \(failedAccounts.count)")
        List(failedAccounts) { account in
            AccountDisplay(account: account, interactionDisabled: true)
        }
        .listStyle(.plain)
    }
}
