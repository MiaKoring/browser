//
//  AccountDetailEdit.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 10.03.25.
//


import SwiftUI
import AmethystAuthenticatorCore
import SwiftData

extension AccountDetailEdit: View {
    var body: some View {
        Form {
            Section {
                HeaderSection(account: account, title: $title, username: $username)
            }
            PasswordSection(account: account, deleteAction: $deleteAction, password: $password, create: create)
            
            if !create {
                Section {
                    TOTPSection(account: account, deleteAction: $deleteAction, totpCode: $totpCode)
                }
                WebsiteSection(account: account)
            }
            
            Button(account.deletedAt != nil ? "Restore Account": "Delete Account" , role: account.deletedAt != nil ? .cancel: .destructive) {
                handleDeletionAndRestoration()
            }
        }
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
            ToolbarItem(placement: .navigation) {
                Button {
                    if !create {
                        save()
                        return
                    }
                    let strength = AccountDetail.evaluatePasswordStrength(password: password)
                    do {
                        try context.transaction {
                            let newAccount = try Account(service: title, username: username, comment: "", password: password, allAccounts: accounts, strength: strength)
                            Task {
                                let title = try? await Account.getTitle(from: newAccount.service)
                                let image = try? await Account.getImage(for: newAccount.service)
                                newAccount.setImage(to: image)
                                if let title {
                                    newAccount.setTitle(to: title )
                                }
                            }
                            context.insert(newAccount)
                            accountAfterCreation?.wrappedValue = newAccount
                        }
                    } catch {
                        if let error = error as? AAuthenticationError {
                            self.error = error
                        } else {
                            print(error)
                        }
                    }
                    dismiss()
                } label: {
                    Text(create ? "Create": "Save")
                }
                .disabled(create && (title.hasPrefix(".") || title.hasSuffix(".") || !title.contains(".") || username.isEmpty || password.isEmpty))
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
                    Text("Password")
                    Spacer()
                    TextField("Password", text: $password)
                        .multilineTextAlignment(.trailing)
                }
                if password.isEmpty {
                    Button("Generate Password") {
                        var pw = ""
                        let generator = PasswordGenerator()
                        
                        repeat {
                            pw = generator.generatePassword()
                        } while !generator.isValidPassword(pw)
                        
                        password = pw
                    }
                    Button("Generator without Special Characters") {
                        var pw = ""
                        let generator = PasswordGenerator()
                        
                        repeat {
                            pw = generator.generatePassword(insertSegments: false)
                        } while !generator.isValidPassword(pw)
                        
                        password = pw
                    }
                }
                Button("Delete Password", role: .destructive) {
                    deleteAction = .password
                }
                .disabled(create || account.password == nil)
            }
            .onAppear() {
                if !create {
                    if let password = account.password, account.strength == nil, !password.isEmpty {
                        account.strength = AccountDetail.evaluatePasswordStrength(password: password)
                    }
                }
            }
        }
    }
    
    struct WebsiteSection: View {
        @Bindable var account: Account
        var body: some View {
            Section {
                HStack {
                    Text("Website")
                    Spacer()
                    Text("\(account.service)\(account.aliases.count > 0 ? " and \(account.aliases.count) more": "")")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}


#Preview {
    @Previewable @State var account: Account?
    NavigationStack {
        VStack {
            if let account {
                AccountDetail(account: account)
            } else {
                Text("no account")
                    .task {
                        guard let acc = try? Account(service: "google.com", username: "koring.mia@gmail.com", comment: "TestComment", password: "abR4tz-Aleops-uIekar", allAccounts: [], strength: nil) else {
                            print("failed to create account")
                            return
                        }
                        await acc.setTitle(to: (try? Account.getTitle(from: acc.service)) ?? "failed")
                        acc.aliases.append("accounts.google.com")
                        
                        if let password = acc.password {
                            acc.strength = AccountDetail.evaluatePasswordStrength(password: password)
                        }
                        acc.setTOTPSecret(to: "JBSWY3DPEHPK3PXP")
                        Task {
                            let image = try? await Account.getImage(for: acc.service)
                            let title = try? await Account.getTitle(from: acc.service)
                            acc.setImage(to: image)
                            acc.setTitle(to: title ?? acc.service)
                        }
                        account = acc
                    }
            }
        }
    }
}
