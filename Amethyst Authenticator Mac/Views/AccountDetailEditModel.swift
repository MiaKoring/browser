//
//  Untitled.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 11.03.25.
//

import SwiftUI
import AmethystAuthenticatorCore
import SwiftData

struct AccountDetailEdit {
    @Bindable var account: Account
    @Query var accounts: [Account]
    @State var username: String
    @State var password: String
    @State var title: String
    @State var deleteAction: DeleteAction?
    @Environment(\.modelContext) var context
    @State var error: AAuthenticationError? = nil
    @State var totpCode: String?
    @Environment(\.dismiss) var dismiss
    @State var create: Bool
    var accountAfterCreation: Binding<Account?>?
    
    init(account: Account, create: Bool = false, accountAfterCreation: Binding<Account?>? = nil) {
        self.account = account
        self.username = account.username
        if !create {
            self.password = account.password ?? ""
        } else {
            self.password = ""
        }
        self.title = account.title ?? ""
        self.create = create
        self.accountAfterCreation = accountAfterCreation
    }
    
    func save() {
        if account.title != title {
            account.setTitle(to: title)
        }
        if !password.isEmpty {
            let strength = AccountDetail.evaluatePasswordStrength(password: password)
            account.strength = strength
            account.setPassword(to: password)
        } else {
            if account.password != nil {
                account.setPassword(to: nil)
            }
        }
        if account.username != username && !username.isEmpty {
            do {
                try account.setUsername(to: username, allAccounts: accounts, context: context)
            } catch {
                if let error = error as? AAuthenticationError {
                    self.error = error
                } else {
                    print(error)
                }
                return
            }
        }
        dismiss()
    }
    
    func handleDeletionAndRestoration() {
        if account.deletedAt != nil {
            account.restore()
        } else {
            deleteAction = .account
        }
    }
    
    
    func executeDeletion() {
        switch deleteAction {
        case .code:
            account.removeTOTPSecret()
            totpCode = "--- ---"
        case .password:
            account.setPassword(to: nil)
            password = ""
        case .passkey:
            //TODO: Add passkey support
            break
        case .account:
            account.delete()
        case nil:
            break
        }
        deleteAction = nil
    }
    
}
