//
//  TOTPUser.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 11.03.25.
//
import AmethystAuthenticatorCore
import Foundation

protocol TOTPUser {
    var account: Account { get }
    var totpTimer: Timer? { get set }
    var totpCode: String? { get set }
    func getCurrentTOTP() -> String
}

extension TOTPUser {
    func getCurrentTOTP() -> String {
        guard var code  = account.getCurrentTOTPCode() else {
            return "Error"
        }
        code.insert(" ", at: code.index(code.startIndex, offsetBy: 3))
        return code
    }
}
