//
//  RevenueCat.swift
//  Amethyst Project
//
//  Created by Mia Koring on 20.07.25.
//
import RevenueCat
import OSLog

struct Subscriptions {
    private static var logger = Logger(subsystem: AmethystApp.subSystem, category: "AccountProvider")
    
    static func setup() {
#if DEBUG
        Purchases.logLevel = .debug
#else
        Purchases.logLevel = .warn
#endif
        Purchases.configure(withAPIKey: "appl_tXMZvZJuNPUSqoVaZAHqDXkSqBG")
        Task {
            if let userID = await AccountProvider.getUserID() {
                _ = try? await Purchases.shared.logIn(userID)
            }
        }
    }
    
    static func logout() {
        Task {
            try? await Purchases.shared.logOut()
        }
    }
    
    static func login(_ id: String) {
        Purchases.shared.logIn(id) { (customerInfo, created, error) in
            if let e = error {
                Self.logger.error("RevenueCat login failed: \(e.localizedDescription)")
            } else {
                Self.logger.info("RevenueCat login successful for user \(id)")
            }
        }
    }
}
