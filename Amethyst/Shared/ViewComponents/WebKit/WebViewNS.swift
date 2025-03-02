//
//  WebView.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import SwiftUI
import WebKit
import CryptoTokenKit

struct WebViewNS: NSViewRepresentable {
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "webauthn", let body = message.body as? [String: Any] else { return }
            
            authenticateWithSecurityKey { result in
                DispatchQueue.main.async {
                    let script = "window.customWebAuthn.complete(\(result));"
                    message.webView?.evaluateJavaScript(script)
                }
            }
        }
        
        func authenticateWithSecurityKey(completion: @escaping (String) -> Void) {
           /* let session = TKSmartCardSession()
            session.begin() { error in
                guard error == nil else {
                    completion("\"Error: \(error!.localizedDescription)\"")
                    return
                }
                
                // Suche nach FIDO2-kompatiblen Kartenlesern (YubiKey, SoloKey etc.)
                guard let reader = session.readers.first else {
                    completion("\"Error: No FIDO2 security key detected\"")
                    return
                }
                
                let card = reader.smartCard
                card.beginSession() { error in
                    guard error == nil else {
                        completion("\"Error: \(error!.localizedDescription)\"")
                        return
                    }
                    
                    // Hier würdest du mit dem FIDO2-Token kommunizieren
                    completion("\"Success: Security Key authenticated\"")
                }
            }*/
            print("called")
        }
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    @ObservedObject var viewModel: WebViewModel
    
    func makeNSView(context: Context) -> WKWebView {
        return viewModel.getWebView()
    }
    
    func updateNSView(_ uiView: WKWebView, context: Context) {
        
    }
}

