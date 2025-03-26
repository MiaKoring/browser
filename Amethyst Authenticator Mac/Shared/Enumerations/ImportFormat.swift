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
            return await processApple(url: url, stage: stage, importProcess: importProcess, context: context, options: options)
        case .keepassxc:
            return await processKeePassCX(url: url, stage: stage, importProcess: importProcess, context: context, options: options)
        }
    }
    
    @MainActor
    private func processKeePassCX(url: URL, stage: Binding<ImportStage>, importProcess: Binding<Double>, context: ModelContext, options: ImportOptions) async -> Result<(imported: Int, failed: [Account]), ImportError> {
        var failed = [Account]()
        var imported = 0
        
        stage.wrappedValue = .fetchExistingAccounts
        guard let existingAccounts = fetchExistingAccounts(context: context) else {
            return .failure(.failedAccountFetch)
        }
        
        stage.wrappedValue = .parseData
        switch getCSV(url: url) {
        case .success(let data):
            stage.wrappedValue = .importAccounts
            for index in data.startIndex..<data.endIndex {
                importProcess.wrappedValue = Double( index + 1 ) / Double( data.endIndex )
                
                switch await create(line: data[index]) {
                case .success(let bool):
                    if bool {
                        imported += 1
                    }
                case .failure(let error):
                    return .failure(error)
                }
            }
        case .failure(let error):
            return.failure(error)
        }
        /*
        if lines.first != #""Group","Title","Username","Password","URL","Notes","TOTP","Icon","Last Modified","Created""# {
            return .failure(.formatMatch)
        }*/
        
        return .success((imported: imported, failed: failed))
        
        func create(line: [String: String]) async -> Result<Bool, ImportError> {
            guard let notes = options.transferNotes ? line["Notes"]: "",
                  let service = line["URL"],
                  let username = line["Username"],
                  let password = line["Password"],
                  let totp = line["TOTP"],
                  let title = line["Title"]
            else {
                return .failure(.formatMatch)
            }
            
            
            return await createAccount(notes: notes, service: service, username: username, password: password, totp: totp, title: title, existingAccounts: existingAccounts, options: options, failed: &failed, context: context)
        }
    }
    
    @MainActor
    private func processApple(url: URL, stage: Binding<ImportStage>, importProcess: Binding<Double>, context: ModelContext, options: ImportOptions) async -> Result<(imported: Int, failed: [Account]), ImportError> {
        var failed = [Account]()
        var imported = 0
        
        stage.wrappedValue = .fetchExistingAccounts
        guard let existingAccounts = fetchExistingAccounts(context: context) else {
            return .failure(.failedAccountFetch)
        }
        
        stage.wrappedValue = .parseData
        switch getCSV(url: url) {
        case .success(let data):
            stage.wrappedValue = .importAccounts
            for index in data.startIndex..<data.endIndex {
                importProcess.wrappedValue = Double( index + 1 ) / Double( data.endIndex )
                
                switch await create(line: data[index]) {
                case .success(let bool):
                    if bool {
                        imported += 1
                    }
                case .failure(let error):
                    return .failure(error)
                }
            }
        case .failure(let error):
            return.failure(error)
        }
        
        return .success((imported: imported, failed: failed))
        
        func create(line: [String: String]) async -> Result<Bool, ImportError> {
            guard let notes = options.transferNotes ? line["Notes"]: "",
                  let service = line["URL"],
                  let username = line["Username"],
                  let password = line["Password"],
                  let totp = line["OTPAuth"],
                  let title = line["Title"]
            else {
                return .failure(.formatMatch)
            }
            
            
            return await createAccount(notes: notes, service: service, username: username, password: password, totp: totp, title: title, existingAccounts: existingAccounts, options: options, failed: &failed, context: context)
        }
    }
    
    @MainActor
    private func createAccount(notes: String,
                               service: String,
                               username: String,
                               password: String,
                               totp: String,
                               title: String,
                               existingAccounts: [Account],
                               options: ImportOptions,
                               failed: inout [Account],
                               context: ModelContext
    ) async -> Result<Bool, ImportError> {
        guard let account = try? Account(service: service,
                                         username: username,
                                         comment: notes,
                                         password: password,
                                         allAccounts: existingAccounts,
                                         strength: nil)
        else {
            failed.append(Account(service: service, username: username, totp: false))
            return .success(false)
        }
        
        if options.transferTitle {
            account.setTitle(to: title)
        } else if options.fetchServiceData, let host = URL(string: account.service)?.host(), let title = try? await Account.getTitle(from: host) {
            account.setTitle(to: title.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        if options.fetchServiceData,
           let host = URL(string: account.service)?.host(),
           let image = try? await Account.getImage(for: host) {
            account.setImage(to: image)
        }
        account.strength = AccountDetail.evaluatePasswordStrength(password: password)
    
        if !totp.isEmpty, let url = URL(string: totp), var secret = extractTOTPSecret(url: url) {
            while secret.hasSuffix("%3D") {
                secret = String(secret.dropLast(3))
            }
            account.setTOTPSecret(to: secret)
        }
        context.insert(account)
        return .success(true)
    }
    
    private func getCSV(url: URL) -> Result<[[String: String]], ImportError> {
        do {
            let csv = try CSV<Named>(url: url)
            return .success(csv.rows)
        } catch let parseError as CSVParseError {
            return.failure(.parseError(parseError))
        } catch {
            return .failure(.anyParseError(error))
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
