//
//  CredentialProviderViewController.swift
//  CredentialProvider
//
//  Created by Mia Koring on 12.03.25.
//

import AuthenticationServices
import AmethystAuthenticatorCore
import SwiftUI
import SwiftData

class CredentialProviderViewController: ASCredentialProviderViewController, ObservableObject {
    
    @Published var identifiers: [String] = []
    @Published var type: UIType = .passwordList

    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
    */
    //MARK: - Prepare identifiers for Password UI
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        print(serviceIdentifiers)
        var urlSet = Set<String>()
        serviceIdentifiers.forEach {
            guard let identifier = URL(string: $0.identifier)?.host() else {
                return
            }
            urlSet.insert(identifier)
            guard let subdomainless = removeSubdomain(from: identifier) else {
                return
            }
            print(subdomainless)
            urlSet.insert(subdomainless)
        }
        identifiers = Array(urlSet)
        type = .passwordList
    }
    

    /*
     Implement this method if your extension supports showing credentials in the QuickType bar.
     When the user selects a credential from your app, this method will be called with the
     ASPasswordCredentialIdentity your app has previously saved to the ASCredentialIdentityStore.
     Provide the password by completing the extension request with the associated ASPasswordCredential.
     If using the credential would require showing custom UI for authenticating the user, cancel
     the request with error code ASExtensionError.userInteractionRequired.
     */
    //MARK: - Provide QuickType Suggestions
    //FIX: doesn't work, ASCredentialIdentityStore stays empty
    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        print("requested password credential")
        guard let id = credentialIdentity.recordIdentifier, let uuid = UUID(uuidString: id), let result = fetchAccount(for: uuid) else {
            print("Failed")
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.credentialIdentityNotFound.rawValue))
            return
        }
        let passwordCredential = ASPasswordCredential(user: result.username, password: result.password ?? "")
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: { result in
            print(result)
        })
    }
    
    override func provideCredentialWithoutUserInteraction(for credentialRequest: any ASCredentialRequest) {
        print("requested credentials")
        switch credentialRequest.type {
        case .password:
            guard let id = credentialRequest.credentialIdentity.recordIdentifier,
                  let uuid = UUID(uuidString: id),
                  let result = fetchAccount(for: uuid) else {
                print("failed to provide password without interaction")
                self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.credentialIdentityNotFound.rawValue))
                return
            }
            provideCredential(username: result.username, password: result.password ?? "")
        case .passkeyAssertion:
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.credentialIdentityNotFound.rawValue))
        case .passkeyRegistration:
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.credentialIdentityNotFound.rawValue))
        case .oneTimeCode:
            guard let id = credentialRequest.credentialIdentity.recordIdentifier,
                  let uuid = UUID(uuidString: id),
                  let result = fetchAccount(for: uuid) else {
                print("failed to provide password without interaction")
                self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.userInteractionRequired.rawValue))
                return
            }
            self.extensionContext.completeOneTimeCodeRequest(using: ASOneTimeCodeCredential(code: result.getCurrentTOTPCode() ?? ""))
        @unknown default:
            break
        }
    }

    /*
     Implement this method if provideCredentialWithoutUserInteraction(for:) can fail with
     ASExtensionError.userInteractionRequired. In this case, the system may present your extension's
     UI and call this method. Show appropriate UI for authenticating the user then provide the password
     by completing the extension request with the associated ASPasswordCredential.
     */
    override func prepareInterfaceToProvideCredential(for credentialRequest: any ASCredentialRequest) {
        identifiers = [credentialRequest.credentialIdentity.serviceIdentifier.identifier]
        switch credentialRequest.type {
        case .password:
            type = .passwordList
        case .passkeyAssertion:
            break
        case .passkeyRegistration:
            break
        case .oneTimeCode:
            type = .totpList
        @unknown default:
            break
        }
    }
    
    //MARK: - Prepare identifiers for TOTP UI
    override func prepareOneTimeCodeCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        print(serviceIdentifiers)
        var urlSet = Set<String>()
        serviceIdentifiers.forEach {
            guard let identifier = URL(string: $0.identifier)?.host() else {
                return
            }
            urlSet.insert(identifier)
            guard let subdomainless = removeSubdomain(from: identifier) else {
                return
            }
            print(subdomainless)
            urlSet.insert(subdomainless)
        }
        identifiers = Array(urlSet)
        type = .totpList
    }
    
    //MARK: - Register UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let credentialView = CredentialView(viewController: self)
        let hostingController = UIHostingController(rootView: credentialView)
        
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    func provideCredential(username: String, password: String) {
        let credential = ASPasswordCredential(user: username, password: password)
        self.extensionContext.completeRequest(withSelectedCredential: credential, completionHandler: nil)
    }
    
    private func fetchAccount(for identity: UUID) -> Account? {
        guard let groupDBURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.de.touchthegrass.AmethystAuthenticator")?.appendingPathComponent("shared.sqlite") else {
            fatalError("Couldn't find url for shared group db")
        }
        let configuration = ModelConfiguration(url: groupDBURL)
        do {
            let container = try ModelContainer(for: Account.self, migrationPlan: AAuthenticatorMigrations.self, configurations: configuration)
            let context = ModelContext(container)
            
            let fetchDescriptor = FetchDescriptor<Account>(predicate: #Predicate { $0.id == identity})
            guard let result = try? context.fetch(fetchDescriptor).first else {
                return nil
            }
            return result
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func removeSubdomain(from host: String) -> String? {
        let components = host.components(separatedBy: ".")
        
        guard components.count >= 3 else {
            return host
        }
        
        let knownTLDs = [
            "ac.at",
            "ac.be",
            "ac.cn",
            "ac.il",
            "ac.in",
            "ac.jp",
            "ac.kr",
            "ac.nz",
            "ac.th",
            "ac.uk",
            "ac.za",
            "co.at",
            "co.il",
            "co.in",
            "co.jp",
            "co.kr",
            "co.nz",
            "co.th",
            "co.uk",
            "co.za",
            "com.ar",
            "com.au",
            "com.br",
            "com.cn",
            "com.co",
            "com.hk",
            "com.mx",
            "com.my",
            "com.ph",
            "com.sg",
            "com.tr",
            "com.tw",
            "edu.au",
            "edu.cn",
            "edu.hk",
            "edu.sg",
            "edu.tw",
            "gov.au",
            "gov.cn",
            "gov.hk",
            "gov.sg",
            "gov.tw",
            "gov.uk",
            "gov.za",
            "id.au",
            "net.au",
            "net.cn",
            "net.hk",
            "net.il",
            "net.in",
            "net.nz",
            "net.sg",
            "net.uk",
            "net.za",
            "org.au",
            "org.cn",
            "org.hk",
            "org.il",
            "org.in",
            "org.nz",
            "org.sg",
            "org.tw",
            "org.uk",
            "org.za"
        ]
        let lastTwoComponents = components[components.count-2] + "." + components[components.count-1]
        
        if knownTLDs.contains(lastTwoComponents) && components.count >= 4 {
            return components[components.count-3] + "." + lastTwoComponents
        } else {
            return components[components.count-2] + "." + components[components.count-1]
        }
    }
    
    func cancel() {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.userCanceled.rawValue))
    }

}

enum UIType {
    case passwordList
    case totpList
}

