//
//  ImportFormat.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 25.03.25.
//
import SwiftUI
import SwiftData
import AmethystAuthenticatorCore

enum ImportFormat: String, CaseIterable {
    case apple = "Apple"
    case keepassxc = "KeePassXC (v4)"
}

extension ImportFormat {
    @MainActor
    func process(url: URL, stage: Binding<ImportStage>, importProcess: Binding<Double>, context: ModelContext, options: ImportOptions = ImportOptions()) async -> Result<(imported: Int, failed: [Account]), ImportError> {
        switch self {
        case .apple:
            return processApple(url: url, stage: stage, importProcess: importProcess, context: context, options: options)
        case .keepassxc:
            return await processKeePassCX(url: url, stage: stage, importProcess: importProcess, context: context, options: options)
        }
    }
    
    @MainActor
    private func processKeePassCX(url: URL, stage: Binding<ImportStage>, importProcess: Binding<Double>, context: ModelContext, options: ImportOptions) async -> Result<(imported: Int, failed: [Account]), ImportError> {
        var failed = [Account]()
        var imported = 0
        
        
        stage.wrappedValue = .readFile
        let lines = csvLines(url: url)
        
        stage.wrappedValue = .parseData
        let processedLines = processLines(lines)
        
        stage.wrappedValue = .fetchExistingAccounts
        guard let existingAccounts = fetchExistingAccounts(context: context) else {
            return .failure(.failedAccountFetch)
        }
        
        stage.wrappedValue = .importAccounts
        
        for i in 0..<processedLines.count {
            importProcess.wrappedValue = Double( i + 1 ) / Double( processedLines.count )
            
            if await createAccount(line: processedLines[i]) {
                imported += 1
            }
        }
        
        return .success((imported: imported, failed: failed))
        
        
        func processLines(_ lines: [String]) -> [[String]] {
            lines.map { line in
                line.split(separator: ",").dropFirst().map { part in //drops "Group" parameter
                    let partString = part.dropFirst().dropLast() // remove leading and trailing "
                    return String(partString)
                }
            }
        }
        
        func createAccount(line: [String]) async -> Bool {
            let notes = options.transferNotes ? line[4]: ""
            
            guard let account = try? Account(service: line[3],
                                             username: line[1],
                                             comment: notes,
                                             password: line[2],
                                             allAccounts: existingAccounts,
                                             strength: nil)
            else {
                failed.append(Account(service: line[3], username: line[1], totp: false))
                return false
            }
            
            if options.transferTitle {
                account.setTitle(to: line[0])
            } else if options.fetchServiceData {
                if let title = try? await Account.getTitle(from: account.service) {
                    account.setTitle(to: title)
                }
            }
            if options.fetchServiceData {
                let image = try? await Account.getImage(for: account.service)
                account.setImage(to: image)
            }
            let totp = line[5]
            if !totp.isEmpty, let url = URL(string: totp), var secret = extractTOTPSecret(url: url) {
                while secret.hasSuffix("%3D") {
                    secret = String(secret.dropLast(3))
                }
                account.setTOTPSecret(to: secret)
            }
            context.insert(account)
            return true
        }
    }
    
    private func processApple(url: URL, stage: Binding<ImportStage>, importProcess: Binding<Double>, context: ModelContext, options: ImportOptions) -> Result<(imported: Int, failed: [Account]), ImportError> {
        stage.wrappedValue = .readFile
        return .failure(.failedAccountFetch)
    }
    
    private func csvLines(url: URL) -> [String] {
        var usedEncoding: String.Encoding = .utf8
        do {
            let fileContents = try String(contentsOf: url, usedEncoding: &usedEncoding)
            let parsed = fileContents
                .split(separator: "\n")
                .dropFirst()
                .map {
                    String($0)
                }
            print(parsed)
            
            return parsed
        } catch {
            print("failed to get file: \(error.localizedDescription)")
            return []
        }
    }
    
    private func fetchExistingAccounts(context: ModelContext) -> [Account]? {
        do {
            return try context.fetch(FetchDescriptor<Account>())
        } catch {
            print("Error while fetching accounts for import: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func extractTOTPSecret(url: URL) -> String? {
        guard let res = url.query(percentEncoded: true), let secretPart = res.components(separatedBy: "&").first(where: {$0.hasPrefix("secret=")}) else {
            return nil
        }
        let secret = secretPart.replacingOccurrences(of: "secret=", with: "")
        return secret
    }
}
