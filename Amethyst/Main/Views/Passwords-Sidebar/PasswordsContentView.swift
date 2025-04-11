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
    @State var tryCode = false
    @State var timer: Timer?
    @State var isCanceled = false
    var context: ModelContext
    
    var body: some View {
        ZStack {
            if isAuthenticated {
                HomeView(context: context)
            }
            if !isAuthenticated {
                MeshGradient(width: 2, height: 2, points: [
                    [0, 0], [1, 0],
                    [0, 1], [1, 1]
                ], colors: [.reverse, .myPurple, .myPurple, .reverse])
                .ignoresSafeArea()
                .overlay {
                    Button("Unlock") {
                        guard !isAuthenticated else { return }
                        if tryCode {
                            authenticate(withPasscode: true)
                        } else {
                            authenticate()
                        }
                    }
                }
            }
        }
        .onAppear() {
            isAuthenticated = UDKey.lastAuthTime.intValue + 60 * 30 > Int(Date.now.timeIntervalSinceReferenceDate)
            NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: nil, queue: .main) { _ in
                timer = Timer.scheduledTimer(withTimeInterval: 15*60, repeats: false) { timer in
                    isAuthenticated = false
                    tryCode = false
                    timer.invalidate()
                }
            }
            
            NotificationCenter.default.addObserver(forName: NSWindow.didBecomeKeyNotification, object: nil, queue: .main) { _ in
                timer?.invalidate()
                timer = nil
                guard !isAuthenticated, !isCanceled else { return }
                if tryCode {
                    authenticate(withPasscode: true)
                } else {
                    authenticate()
                }
            }
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
                if authenticationError?.localizedDescription == "Authentication canceled." {
                    isCanceled = true
                }
                guard authenticationError == nil else {
                    tryCode = true
                    UDKey.lastAuthTime.intValue = Int(Date.now.timeIntervalSinceReferenceDate)
                    authenticateWithPasscode()
                    return
                }
                if success {
                    isAuthenticated = true
                    UDKey.lastAuthTime.intValue = Int(Date.now.timeIntervalSinceReferenceDate)
                    timer?.invalidate()
                    timer = nil
                    tryCode = false
                } else {
                    tryCode = true
                    authenticateWithPasscode()
                }
            }
        } else {
            tryCode = true
            authenticateWithPasscode()
        }
        
        func authenticateWithPasscode() {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { completed, authenticationError in
                if completed {
                    isAuthenticated = true
                    UDKey.lastAuthTime.intValue = Int(Date.now.timeIntervalSinceReferenceDate)
                    tryCode = false
                    timer?.invalidate()
                    timer = nil
                }
                if authenticationError?.localizedDescription == "Authentication canceled." {
                    isCanceled = true
                }
            }
        }
    }
}
