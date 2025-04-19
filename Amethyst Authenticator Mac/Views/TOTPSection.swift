//
//  TOTPSection.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 11.03.25.
//
import SwiftUI
import AmethystAuthenticatorCore

struct TOTPSection: View, TOTPUser {
    @Bindable var account: Account
    @Binding var deleteAction: DeleteAction?
    @State var totpTimer: Timer?
    @Binding var totpCode: String?
    @State var showAddVerificationCodeAlert: Bool = false
    var editable: Bool = true
    
    var body: some View {
        HStack {
            Text("Verification Code")
            Spacer()
            Menu {
                Button("Copy Verification Code") {
                    NSPasteboard.general.setString(account.getCurrentTOTPCode() ?? "", forType: .string)
                }
            } label: {
                Text(totpCode ?? "--- ---")
                    .monospaced()
                    .bold()
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText(value: Double((totpCode ?? "000 000").replacingOccurrences(of: " ", with: "")) ?? 0))
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
        }
        .alert("Add Verification Code", isPresented: $showAddVerificationCodeAlert) {
            TOTPInputView() { key in
                account.setTOTPSecret(to: key.replacingOccurrences(of: " ", with: ""))
                showAddVerificationCodeAlert = false
            }
            Button("Cancel", role: .cancel) {
                showAddVerificationCodeAlert = false
            }
        }
        .onAppear() {
            if account.totp {
                handleTOTPonAppear()
            }
        }
        if account.totp && editable {
            Button("Delete Verification Code", role: .destructive) {
                deleteAction = .code
            }
        } else if editable {
            Button("Setup Verification Code") {
                showAddVerificationCodeAlert = true
            }
        }
    }
    
    func handleTOTPonAppear() {
        let code = getCurrentTOTP()
        totpCode = code
        totpTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if AccountDetail.getRemainingTOTPTime() == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        let code = getCurrentTOTP()
                        totpCode = code
                    }
                }
            }
        }
    }
    
    func getCurrentTOTP() -> String {
        guard var code  = account.getCurrentTOTPCode() else {
            return "Error"
        }
        code.insert(" ", at: code.index(code.startIndex, offsetBy: 3))
        return code
    }
}
