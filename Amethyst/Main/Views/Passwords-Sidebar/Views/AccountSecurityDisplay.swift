//
//  AccountSecurityDisplay.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 10.03.25.
//

import SwiftUI
import AmethystAuthenticatorCore
import SwiftData

struct AccountSecurityDisplay: View {
    let strength: Double
    let totp: Bool
    var body: some View {
        HStack {
            Spacer()
            VStack {
                if strength == 1 {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.green)
                    Text("Strong Password")
                    if !totp {
                        Text("Activate 2-Factor-Authentication for best security")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    } else {
                        Text("Great, your account should be pretty secure")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }
                } else if strength > 0.7  {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.title)
                        .foregroundStyle(.yellow)
                    Text("Okay Password")
                    Text("Not optimal, improve it like that:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    StrongPasswordText()
                } else if strength > 0.4 {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.title)
                        .foregroundStyle(.orange)
                    Text("Weak Password")
                    Text("Improve your Password Security:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    StrongPasswordText()
                } else if strength > 0 {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.red)
                    Text("Very Weak Password")
                    Text("Your password can be cracked near instantly, change it to protect your account:")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    StrongPasswordText()
                } else if strength <= 0 {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title)
                        .foregroundStyle(.red)
                    Text("Worst Possible Password")
                    Text("Your password is in the most used ones, you should change it immediately:")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    StrongPasswordText()
                }
            }
            Spacer()
        }
    }
}

struct StrongPasswordText: View {
    var body: some View {
        Text("Strongest passwords combine length (16+ characters), varied character types, avoid common patterns/personal info, and are unique for each account.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
}
