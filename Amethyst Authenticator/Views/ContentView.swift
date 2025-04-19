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
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        ZStack {
            if UIDevice.current.userInterfaceIdiom == .pad {
                HomeViewIpad()
            } else {
                HomeView(isAuthenticated: $isAuthenticated)
            }
            if !isAuthenticated {
                MeshGradient(width: 2, height: 2, points: [
                    [0, 0], [1, 0],
                    [0, 1], [1, 1]
                ], colors: [.reverse, .amethystPurple, .amethystPurple, .reverse])
                .ignoresSafeArea()
                .onAppear() {
                    guard !isAuthenticated else { return }
                    if tryCode {
                        authenticate(withPasscode: true)
                    } else {
                        authenticate()
                    }
                }
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase != .active {
                isAuthenticated = false
                return
            }
            if scenePhase == .active && !isAuthenticated {
                authenticate()
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
                print("authentication error: \(authenticationError)")
                guard authenticationError == nil else {
                    tryCode = true
                    authenticateWithPasscode()
                    return
                }
                if success {
                    isAuthenticated = true
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
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
