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

struct CredentialView: View {
    @StateObject var viewController: CredentialProviderViewController
    @State var accountAfterCreation: Account?
    var container: ModelContainer
    
    init(viewController: CredentialProviderViewController) {
        self._viewController = StateObject(wrappedValue: viewController)
        guard let groupDBURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.de.touchthegrass.AmethystAuthenticator")?.appendingPathComponent("shared.sqlite") else {
            fatalError("Couldn't find url for shared group db")
        }
        let configuration = ModelConfiguration(url: groupDBURL)
        do {
            self.container = try ModelContainer(for: Account.self, migrationPlan: AAuthenticatorMigrations.self, configurations: configuration)
        } catch {
            fatalError("Couldn't create Model Container. Failed with: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
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
}
