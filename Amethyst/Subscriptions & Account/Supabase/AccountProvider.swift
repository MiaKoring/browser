//
//  AClerk.swift
//  Amethyst Project
//
//  Created by Mia Koring on 20.07.25.
//

import SwiftUI
import Supabase
import OSLog
import Combine

@Observable
@MainActor
class AccountProvider {
    static var shared = AccountProvider()
    private static var logger = Logger(subsystem: AmethystApp.subSystem, category: "AccountProvider")
    
    private let client: SupabaseClient
    
    private(set) var userID: String?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        self.client = SupabaseClient(supabaseURL: URL(string:"https://oqcjsrbsbqyjmxnpmend.supabase.co")!, supabaseKey: "sb_publishable_-O31rsd5yDlDoI4I4rgddw_FMz_YZ_w")
        
        Task {
            for await state in self.client.auth.authStateChanges {
                self.handleAuthStateChange(event: state.event, session: state.session)
            }
        }
    }
    
    func getAccessToken() async -> String? {
        let session = try? await self.client.auth.session
        return session?.accessToken
    }
    
    func userID() async -> String? {
        return try? await client.auth.session.user.id.uuidString
    }
    
    func signup(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
    }
    
    func login(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }
    
    func handleAuthStateChange(event: AuthChangeEvent, session: Session?) {
        switch event {
        case .signedIn, .tokenRefreshed, .initialSession:
            guard let newUserID = session?.user.id.uuidString else { return }
            
            if self.userID != newUserID {
                self.userID = newUserID
                Self.logger.info("User session restored/signed in. UserID: \(newUserID)")
                
                Subscriptions.login(newUserID)
            }
            
        case .signedOut:
            if self.userID != nil {
                self.userID = nil
                Self.logger.info("User signed out. Resetting RevenueCat.")
                Subscriptions.logout()
            }
            
        default:
            break
        }
    }
}

extension AccountProvider {
    static func getUserID() async -> String? {
        await Self.shared.userID()
    }
    
    static func login(email: String, password: String) async throws {
        try await Self.shared.login(email: email, password: password)
    }
}
