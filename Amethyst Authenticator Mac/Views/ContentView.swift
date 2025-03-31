//
//  ContentView.swift
//  Amethyst Authenticator
//
//  Created by Mia Koring on 07.03.25.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @State var isAuthenticated = false
    @State var tryCode = false
    @State var timer: Timer?
    @State var isCanceled = false
    var body: some View {
        ZStack {
            if isAuthenticated {
                HomeView()
            }
            if !isAuthenticated {
                MeshGradient(width: 2, height: 2, points: [
                    [0, 0], [1, 0],
                    [0, 1], [1, 1]
                ], colors: [.reverse, .amethystPurple, .amethystPurple, .reverse])
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
                    authenticateWithPasscode()
                    return
                }
                if success {
                    isAuthenticated = true
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

#Preview {
    ContentView()
}
