//
//  AccountDetailEdit.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 10.03.25.
//


import SwiftUI
import AmethystAuthenticatorCore
import SwiftData
import KeychainAccess


extension AccountDetailEdit: View {
    var body: some View {
        Form {
            Section {
                HeaderSection(account: account, title: $title, username: $username)
            }
            PasswordSection(account: account, deleteAction: $deleteAction, password: $password, create: create)
            
            if !create {
                TOTPSection(account: account, deleteAction: $deleteAction)
                WebsiteSection(account: account)
                Button(account.deletedAt != nil ? "Restore Account": "Delete Account" , role: account.deletedAt != nil ? .cancel: .destructive) {
                    handleDeletionAndRestoration()
                }
            }
        }
        .formStyle(.grouped)
        .alert("Are you sure you want to delete \(deleteAction?.rawValue ?? "Empty")", isPresented: .constant(deleteAction != nil)) {
            Button("Delete", role: .destructive) {
                executeDeletion()
            }
            Button("Cancel", role: .cancel) {
                deleteAction = nil
            }
        } message: {
            Text(deleteAction == .account ? "It will be restorable for 30 days": "This will irreversible remove the \(deleteAction?.rawValue ?? "Empty")")
        }
        .alert(error?.localizedDescription ?? "Empty", isPresented: .constant(error != nil)) {
            Button("OK", role: .cancel) {
                error = nil
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                   confirmAction()
                } label: {
                    Text(create ? "Create": "Save")
                }
                .disabled(confirmationActionDisabled)
            }
        }
    }

    
    struct PasswordSection: View {
        @Bindable var account: Account
        @Binding var deleteAction: DeleteAction?
        @Binding var password: String
        let create: Bool
        
        var body: some View {
            Section {
                HStack {
                    TextField("Password", text: $password)
                        .multilineTextAlignment(.trailing)
                }
                if password.isEmpty {
                    Button("Generate Password") { generatePassword() }
                    Button("Generator without Special Characters") { generatePassword(insertSegments: false) }
                }
                Button("Delete Password", role: .destructive) { deleteAction = .password }
                .disabled(create || account.password == nil)
            }
            .onAppear() {
                if !create {
                    if let password = account.password, account.strength == nil, !password.isEmpty {
                        account.strength = AuthenticatorHelper.evaluatePasswordStrength(password: password)
                    }
                }
            }
        }
        
        func generatePassword(insertSegments: Bool = true) {
            var pw = ""
            let generator = PasswordGenerator()
            
            repeat {
                pw = generator.generatePassword(insertSegments: insertSegments)
            } while !generator.isValidPassword(pw)
            
            password = pw
        }
    }
    
    struct WebsiteSection: View {
        @Bindable var account: Account
        var body: some View {
            Section {
                HStack {
                    Text("Website")
                    Spacer()
                    Menu {
                        Button("Open Website") {
                            guard let url = URL(string: "https://\(account.service)") else { return }
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        Text("\(account.service)\(account.aliases.count > 0 ? " and \(account.aliases.count) more": "")")
                            .foregroundStyle(.secondary)
                    }
                    .menuStyle(.button)
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
