//
//  AccountDetail.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.03.25.
//

import SwiftUI
import SwiftData
import AmethystAuthenticatorCore

struct AccountDetailRegular: View, TOTPUser {
  
    let account: Account
    @State var showPassword = false
    @State var totpTimer: Timer?
    @State var totpCode: String?
    @Environment(\.dismiss) var dismiss
    var showDeleted: Binding<Bool>?
    @State var showPopup: Bool = false
    @Environment(\.modelContext) var context
    
    init(account: Account, showDeleted: Binding<Bool>? = nil) {
        self.account = account
        self.showDeleted = showDeleted
    }
    
    var body: some View {
        Form {
            Section {
                HeaderSection(account: account, title: .constant(account.title ?? account.service), username: .constant(account.username), editable: false)
                HStack {
                    Text("Password")
                    Spacer()
                    Menu {
                        Button("Copy Password") {
                            UIPasteboard.general.string = account.password
                        }
                        .onAppear() {
                            showPassword = true
                        }
                    } label: {
                        if let password = account.password {
                            Text(showPassword ? password: Array(repeating: "•", count: password.count).joined())
                                .monospaced()
                                .fontWeight(showPassword ? .regular: .heavy)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .menuStyle(.button)
                    .buttonStyle(.plain)
                }
                if account.totp {
                    TOTPSection(account: account, deleteAction: .constant(nil), totpCode: $totpCode, editable: false)
                }
                HStack {
                    Text("Website")
                    Spacer()
                    Menu {
                        Button("Open Website") {
                            guard let url = URL(string: "https://\(account.service)") else { return }
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("\(account.service)\(account.aliases.count > 0 ? " and \(account.aliases.count) more": "")")
                            .foregroundStyle(.secondary)
                    }
                    .menuStyle(.button)
                    .buttonStyle(.plain)
                }
            }
            
            if let strength = account.strength, account.password != nil, !(showDeleted?.wrappedValue ?? false) {
                Section("Security") {
                    AccountSecurityDisplay(strength: strength, totp: account.totp)
                }
            }
            if showDeleted?.wrappedValue ?? false {
                Section {
                    Button("Restore", role: .cancel) {
                        account.restore()
                        showDeleted?.wrappedValue = false
                    }
                    Button("Delete permanently", role: .destructive) {
                        showPopup = true
                    }
                }
            }
        }
        .onAppear() {
            if let password = account.password, account.strength == nil, !password.isEmpty {
                account.strength = AccountDetail.evaluatePasswordStrength(password: password)
            }
        }
        .confirmationDialog("Deleting this account will remove all corresponding data permanently. You can't undo this action.", isPresented: $showPopup, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                account.deleteCorrespondingKeychainData()
                context.delete(account)
                dismiss()
                return
            }
        }
        
    }
}

struct AccountDetail: View {
    let account: Account
    @State var showDeleted: Bool = false
    
    var body: some View {
        AccountDetailRegular(account: account, showDeleted: $showDeleted)
        .toolbar {
            if !showDeleted {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AccountDetailEdit(account: account) 
                    } label: {
                        Text("Edit")
                    }
                }
            }
        }
    }
    
    static func evaluatePasswordStrength(password: String) -> Double {
        let checker = PasswordChecker()
        return checker.checkPassword(password)
    }
    
    static func getRemainingTOTPTime() -> Int {
        let timeStep: TimeInterval = 30
        let currentTime = Date.now.timeIntervalSince1970
        let elapsedTime = currentTime.truncatingRemainder(dividingBy: timeStep)
        return Int((timeStep - elapsedTime).rounded(.toNearestOrEven))
    }
}

#Preview {
    @Previewable @State var account: Account?
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
