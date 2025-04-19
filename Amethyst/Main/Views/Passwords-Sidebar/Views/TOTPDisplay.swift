//
//  TOTPDisplay.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 15.03.25.

import SwiftUI
import SwiftData
import AmethystAuthenticatorCore


struct TOTPDisplay: View, TOTPUser {
    let account: Account
    var context: ModelContext
    @State var totpCode: String?
    @State var totpTimer: Timer?
    @State var copiedTimper: Timer?
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ZStack {
                    if let data = account.image, let uiImage = NSImage(data: data) {
                        Image(nsImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    } else {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.tertiary)
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.trailing, 5)
                VStack(alignment: .leading) {
                    if let title = account.title {
                        Text(title)
                            .bold()
                    } else {
                        Text(account.service)
                            .bold()
                    }
                    Text(account.username)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 5)
            if let timer = copiedTimper, timer.isValid {
                Text("Copied")
                    .font(.title2)
                    .monospaced()
                    .padding(5)
                    .background() {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.tertiary)
                    }
            } else {
                Text(totpCode ?? "--- ---")
                    .font(.title)
                    .monospaced()
                    .contentTransition(.numericText(value: Double((totpCode ?? "000 000").replacingOccurrences(of: " ", with: "")) ?? 0))
                    .bold()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let totpCode {
                            NSPasteboard.general.setString(totpCode, forType: .string)
                            copiedTimper = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                                timer.invalidate()
                                copiedTimper = nil
                            }
                        }
                    }
            }
        }
        .contextMenu {
            NavigationLink {
                AccountDetail(account: account, showDeleted: .constant(false), context: context)
            } label: {
                Text("Show Account")
            }
        }
        .onAppear() {
            handleTOTPonAppear()
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

