//
//  PlansView.swift
//  Amethyst Project
//
//  Created by Mia Koring on 20.07.25.
//

import SwiftUI
import RevenueCat

struct Plans: View {
    @Environment(AppViewModel.self) var appViewModel
    
    @State var plusPackages = [Package]()
    @State var proPackages = [Package]()
    
    @State var entitlements = [String]()
    @State var timer: Timer?
    
    var body: some View {
        VStack {
            HStack {
                FeatureList(packages: plusPackages)
                FeatureList(packages: proPackages)
            }
            if appViewModel.runsInAppStoreSandbox {
                Text("This is not a release Version. Purchases may not be available to you.")
            }
            Text(entitlements.description)
        }
        .onAppear {
            Purchases.shared.getOfferings { (offerings, error) in
                if let offerings {
                    buildPackages(offerings.all)
                }
            }
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                Task {
                    await updateEntitlements()
                }
            }
        }
    }
    
    @MainActor
    func updateEntitlements() async {
        guard let info = try? await Purchases.shared.customerInfo() else { return }
        entitlements = Array(info.entitlements.active.keys)
    }
    
    private func buildPackages(_ offerings: [String : Offering]) {
        offerings.forEach { (key, offering) in
            print(key)
            if key.localizedCaseInsensitiveContains("pro") {
                offering.availablePackages.forEach { package in
                    proPackages.append(package)
                }
            } else {
                offering.availablePackages.forEach { package in
                    plusPackages.append(package)
                }
            }
        }
    }
}

struct FeatureList: View {
    let packages: [Package]
    
    @State var dispatched: (() -> Void)?
    @State var showLoginSheet: Bool = false
    @Environment(AccountProvider.self) var accProvider
    
    var body: some View {
        VStack {
            ForEach(packages, id: \.id) { package in
                Button {
                    executeOrLogin {
                        Task {
                            try? await Purchases.shared.purchase(package: package)
                        }
                    }
                } label: {
                    HStack {
                        Text(package.storeProduct.localizedTitle)
                        Text(package.storeProduct.localizedPriceString)
                    }
                }
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView {
                dispatched?()
                showLoginSheet = false
                dispatched = nil
            }
        }
    }
    
    func executeOrLogin(_ body: @escaping () -> Void) {
        print("userID: \(Purchases.shared.appUserID)")
        guard accProvider.userID == nil else {
            body()
            return
        }
        dispatched = body
        showLoginSheet = true
    }
}

struct LoginView: View {
    let onSuccess: () -> Void
    
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        TextField("Email", text: $email)
        SecureField("Password", text: $password)
        Button("Submit") {
            Task {
                do {
                    try await AccountProvider.login(email: email, password: password)
                    try? await Task.sleep(for: .milliseconds(300))
                    onSuccess()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
