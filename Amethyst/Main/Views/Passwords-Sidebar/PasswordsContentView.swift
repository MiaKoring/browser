//
//  PasswordsContentView.swift
//  Amethyst Project
//
//  Created by Mia Koring on 10.04.25.
//

import SwiftUI
import SwiftData
import LocalAuthentication
import AmethystAuthenticatorCore

struct PasswordsContentView: View {
    @State var isAuthenticated = false
    var context: ModelContext
    @State var timer: Timer?
    
    var body: some View {
        ZStack {
            if isAuthenticated {
                PasswordList(context: context)
            } else {
                ObscuringView(isAuthenticated: $isAuthenticated, timer: $timer)
            }
        }
        .onAppear() {
            isAuthenticated = UDKey.lastAuthTime.intValue + 60 * 30 > Int(Date.now.timeIntervalSinceReferenceDate)
            if isAuthenticated {
                timer = Timer.scheduledTimer(withTimeInterval: Double(UDKey.lastAuthTime.intValue + 60 * 30) - Date.now.timeIntervalSinceReferenceDate, repeats: false) { timer in
                    DispatchQueue.main.async {
                        isAuthenticated = false
                        timer.invalidate()
                    }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    struct ObscuringView: View {
        @Binding var isAuthenticated: Bool
        @State var tryCode = false
        @Binding var timer: Timer?
        var body: some View {
            MeshGradient(width: 2, height: 2, points: [
                [0, 0], [1, 0],
                [0, 1], [1, 1]
            ], colors: [.reverse, .myPurple, .myPurple, .reverse])
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay {
                Button {
                    guard !isAuthenticated else { return }
                    if tryCode {
                        authenticate(withPasscode: true)
                    } else {
                        authenticate()
                    }
                } label: {
                    VStack {
                        Text("Unlock")
                            .font(.title2)
                            .bold()
                        Text("\(UDKey.triggerPasswordsAuth.shortcut.modifier.contains(.command) ? "⌘": "")\(UDKey.triggerPasswordsAuth.shortcut.modifier.contains(.shift) ? "⇧": "")\(UDKey.triggerPasswordsAuth.shortcut.modifier.contains(.option) ? "⌥": "")\(UDKey.triggerPasswordsAuth.shortcut.modifier.contains(.control) ? "⌃": "")\("\(UDKey.triggerPasswordsAuth.shortcut.key.character)".uppercased())")
                            .foregroundStyle(.secondary)
                            .font(.title2)
                    }
                }
                .buttonStyle(.plain)
                .keyboardShortcut(UDKey.triggerPasswordsAuth.keyboardShortcut)
            }
        }
        func authenticate(withPasscode: Bool = false) {
            let context = LAContext()
            var error: NSError?
            let reason = "You need to unlock to access your credentials"
            
            guard !withPasscode else {
                authenticateWithPasscode()
                return
            }
            // check whether biometric authentication is possible
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    guard authenticationError == nil else {
                        tryCode = true
                        authenticateWithPasscode()
                        return
                    }
                    DispatchQueue.main.async {
                        if success {
                            handleSuccess()
                        } else {
                            tryCode = true
                            authenticateWithPasscode()
                        }
                    }
                }
            } else {
                tryCode = true
                authenticateWithPasscode()
            }
            
            func authenticateWithPasscode() {
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { completed, authenticationError in
                    DispatchQueue.main.async {
                        if completed {
                            handleSuccess()
                        }
                    }
                }
            }
            
            func handleSuccess() {
                isAuthenticated = true
                UDKey.lastAuthTime.intValue = Int(Date.now.timeIntervalSinceReferenceDate)
                tryCode = false
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: Double(UDKey.lastAuthTime.intValue + 60 * 30) - Date.now.timeIntervalSinceReferenceDate, repeats: false) { timer in
                    DispatchQueue.main.async {
                        isAuthenticated = false
                        timer.invalidate()
                    }
                }
            }
        }
    }
}
