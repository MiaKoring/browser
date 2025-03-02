//
//  SearchScripts.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 04.12.24.
//
import WebKit

extension WebViewModel {
    func injectJavaScript() {
        let jsString = """
        var markInstance = new Mark(document.querySelector("body"));
        let highlights = [];
        let currentIndex = 0;
        
        function highlightText(searchTerm, options) {
            markInstance.unmark({"className": "amethystHighlight"});
            highlights = [];
            markInstance.mark(searchTerm, options); 
            return document.querySelectorAll('.amethystHighlight').length;
        }
        
        function removeHighlights() {
            markInstance.unmark({"className": "amethystHighlight"});
        }

        function navigateHighlights(direction) {
            if (highlights.length === 0) {
                highlights = document.querySelectorAll('.amethystHighlight');
            }
            if (highlights.length === 0) return 0;

            // Entferne vorherige Markierung
            highlights[currentIndex]?.classList.remove('amethystCurrent-highlight');

            // Aktualisiere den Index
            currentIndex += direction;
            if (currentIndex < 0) currentIndex = highlights.length - 1;
            if (currentIndex >= highlights.length) currentIndex = 0;

            // Markiere und scrolle zum aktuellen Treffer
            const current = highlights[currentIndex];
            current.classList.add('amethystCurrent-highlight');
            current.scrollIntoView({ behavior: 'smooth', block: 'center' });
            return currentIndex;
        }
        """
        let markScript = WKUserScript(source: markjs, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        let userScript = WKUserScript(source: jsString, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webView?.configuration.userContentController.addUserScript(markScript)
        webView?.configuration.userContentController.addUserScript(userScript)
    }
    
    func injectCustomWebAuthn() {
        let jsString = """
        window.customWebAuthn = {
          request: async function (options) {
            return new Promise((resolve, reject) => {
              window.webkit.messageHandlers.webauthn.postMessage(options);
              window.customWebAuthn.resolve = resolve;
              window.customWebAuthn.reject = reject;
            });
          },
          complete: function (data) {
            window.customWebAuthn.resolve(data);
          },
          error: function (error) {
            window.customWebAuthn.reject(error);
          },
        };

        // WebAuthn Call überschreiben
        navigator.credentials.create = function (options) {
          return window.customWebAuthn.request(options);
        };

        navigator.credentials.get = function (options) {
          return window.customWebAuthn.request(options);
        };
        """
        
        let webauthnScript = WKUserScript(source: jsString, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webView?.configuration.userContentController.addUserScript(webauthnScript)
    }
    
    func injectCSSGlobally() {
        let cssString = """
        .amethystHighlight {
            background-color: yellow;
            
            color: black;
        }
        .amethystCurrent-highlight {
            background-color: orange;
        }
        """
        let jsCode = """
        var style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = `\(cssString)`;
        document.head.appendChild(style);
        """
        let userScript = WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView?.configuration.userContentController.addUserScript(userScript)
    }
    
    func navigateHighlight(forward: Bool, completion: @escaping(Any?, (any Error)?) -> Void) {
        let direction = forward ? 1 : -1
        let jsCode = "navigateHighlights(\(direction));"
        webView?.evaluateJavaScript(jsCode) { result, error in
            completion(result, error)
        }
    }
    func removeHighlights() {
        let jsCode = """
        removeHighlights();
        """
        webView?.evaluateJavaScript(jsCode) { result, error in
            if let error = error {
                print("Fehler beim Entfernen des Highlightings: \(error)")
            }
        }
    }
    func highlight(searchTerm: String, caseSensitive: Bool = false, completion: @escaping(Any?, (any Error)?) -> Void) {
        let jsCode = """
        var options = {
            "element": "span",
            "className": "amethystHighlight",
            "caseSensitive": \(caseSensitive ? "true": "false"),
        };
        highlightText('\(searchTerm)', options);
        """
        webView?.evaluateJavaScript(jsCode) { result, error in
            completion(result, error)
        }
    }
}
