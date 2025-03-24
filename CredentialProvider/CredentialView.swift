//
//  CredentialVire.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 13.03.25.
//
import SwiftUI
import SwiftData
import AuthenticationServices
import AmethystAuthenticatorCore
import LocalAuthentication

struct CredentialView: View {
    @StateObject var viewController: CredentialProviderViewController
    @State var accountAfterCreation: Account?
    var container: ModelContainer
    @State var isAuthenticated: Bool = false
    @State var tryCode: Bool = false
    
    init(viewController: CredentialProviderViewController) {
        self._viewController = StateObject(wrappedValue: viewController)
#if RELEASE
        guard let groupDBURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.de.touchthegrass.AmethystAuthenticator")?.appendingPathComponent("shared.sqlite") else {
            fatalError("Couldn't find url for shared group db")
        }
#elseif DEBUG
        guard let groupDBURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.de.touchthegrass.AmethystAuthenticator.dev")?.appendingPathComponent("shared.sqlite") else {
            fatalError("Couldn't find url for shared group db")
        }
#endif
        let configuration = ModelConfiguration(url: groupDBURL)
        do {
            self.container = try ModelContainer(for: Account.self, migrationPlan: AAuthenticatorMigrations.self, configurations: configuration)
        } catch {
            fatalError("Couldn't create Model Container. Failed with: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                AccountList(identifiers: viewController.identifiers, type: viewController.type) { username, password, domain, id, totp in
                    /*//Currently doesn't work, nothing gets saved
                     Task {
                     do {
                     try await ASCredentialIdentityStore.shared.removeAllCredentialIdentities()
                     let passwordCredentialIdentity = ASPasswordCredentialIdentity(serviceIdentifier: .init(identifier: domain, type: .domain), user: username, recordIdentifier: id.uuidString) as any ASCredentialIdentity
                     let store = ASCredentialIdentityStore.shared
                     if await store.state().isEnabled {
                     try await ASCredentialIdentityStore.shared.saveCredentialIdentities([passwordCredentialIdentity])
                     if totp {
                     print("was called")
                     store.saveCredentialIdentities([ASOneTimeCodeCredentialIdentity(serviceIdentifier: .init(identifier: "https://www.customercontrolpanel.de/index.php", type: .URL), label: username, recordIdentifier: id.uuidString)], completion: { result, error in
                     print("totp was saved:\(result)")
                     print(error?.localizedDescription)
                     DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                     Task {
                     await print(ASCredentialIdentityStore.shared.credentialIdentities(forService: .init(identifier: "https://www.customercontrolpanel.de/index.php", type: .URL), credentialIdentityTypes: .oneTimeCode))
                     }
                     }
                     })
                     
                     } else {
                     print("isn't totp")
                     }
                     } else {
                     print("store is disabled")
                     }
                     
                     } catch {
                     print(error.localizedDescription)
                     }
                     }*/
                    viewController.provideCredential(username: username, password: password)
                } cancel: {
                    viewController.cancel()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            AccountDetailEdit(account: Account(service: "", username: "", totp: false), create: true, accountAfterCreation: $accountAfterCreation)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .fullScreenCover(item: $accountAfterCreation) { account in
                    FullScreenCoverView(account: account)
                }
            }
            .modelContainer(container)
            
            if !isAuthenticated {
                ZStack {
                    MeshGradient(width: 2, height: 2, points: [
                        [0, 0], [1, 0],
                        [0, 1], [1, 1]
                    ], colors: [.reverse, .amethystPurple, .amethystPurple, .reverse])
                    .onViewDidAppear {
                        guard !isAuthenticated else { return }
                        if !tryCode {
                            authenticate()
                        } else {
                            authenticate(withPasscode: true)
                        }
                    }
                    .ignoresSafeArea(.all)
                    Button("Unlock") {
                        guard !isAuthenticated else { return }
                        if !tryCode {
                            authenticate()
                        } else {
                            authenticate(withPasscode: true)
                        }
                    }

                }
            }
        }
    }
    
    struct FullScreenCoverView: View {
        @Bindable var account: Account
        @Environment(\.dismiss) var dismiss
        var body: some View {
            NavigationStack {
                AccountDetail(account: account)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "chevron.left")
                                        .bold()
                                    Text("Back")
                                }
                            }
                        }
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
