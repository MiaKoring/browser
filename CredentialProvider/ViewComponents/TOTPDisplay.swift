//
//  TOTPDisplay.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 13.03.25.
//

/*
import SwiftUI
import AmethystAuthenticatorCore
import AuthenticationServices

struct TOTPDisplay: View {
    let account: Account
    @State var totpTimer: Timer?
    @State var totpCode: String?
    
    var body: some View {
        HStack {
            ZStack {
                if let data = account.image, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
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
            HStack {
                VStack(alignment: .leading) {
                    if let title = account.title {
                        Text(title)
                            .bold()
                            .lineLimit(1)
                    } else {
                        Text(account.service)
                            .bold()
                            .lineLimit(1)
                    }
                    Text(account.username)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Text(totpCode ?? "--- ---")
                    .monospaced()
                    .bold()
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText(value: Double((totpCode ?? "000 000").replacingOccurrences(of: " ", with: "")) ?? 0))
            }
        }
    }
    
    func handleTOTPonAppear() {
        let code = getCurrentTOTP()
        totpCode = code
        totpTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if TOTPDisplay.getRemainingTOTPTime() == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        let code = getCurrentTOTP()
                        totpCode = code
                    }
                }
            }
        }
    }
    
    static func getRemainingTOTPTime() -> Int {
        let timeStep: TimeInterval = 30
        let currentTime = Date.now.timeIntervalSince1970
        let elapsedTime = currentTime.truncatingRemainder(dividingBy: timeStep)
        return Int((timeStep - elapsedTime).rounded(.toNearestOrEven))
    }
    
    func getCurrentTOTP() -> String {
        guard var code  = account.getCurrentTOTPCode() else {
            return "Error"
        }
        code.insert(" ", at: code.index(code.startIndex, offsetBy: 3))
        return code
    }
}
*/
