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
        \(markjs)
        
        var amethystBrowserMarkInstance = new AmethystBrowserMark(document.querySelector("body"));
        let amethystBrowserMarkHighlights = [];
        let amethystBrowserMarkCurrentIndex = 0;
        
        function amethystBrowserMarkHighlightText(searchTerm, options) {
            amethystBrowserMarkInstance.unmark({"className": "amethystBrowserHighlight"});
            amethystBrowserMarkHighlights = [];
            amethystBrowserMarkInstance.mark(searchTerm, options); 
            return document.querySelectorAll('.amethystHighlight').length;
        }
        
        function amethystBrowserMarkRemoveHighlights() {
            amethystBrowserMarkInstance.unmark({"className": "amethystBrowserHighlight"});
        }

        function amethystBrowserMarkNavigateHighlights(direction) {
            if (highlights.length === 0) {
                highlights = document.querySelectorAll('.amethystBrowserHighlight');
            }
            if (highlights.length === 0) return 0;

            // Entferne vorherige Markierung
            amethystBrowserMarkHighlights[amethystBrowserMarkCurrentIndex]?.classList.remove('amethystBrowserCurrent-highlight');

            // Aktualisiere den Index
            amethystBrowserMarkCurrentIndex += direction;
            if (amethystBrowserMarkCurrentIndex < 0) amethystBrowserMarkCurrentIndex = highlights.length - 1;
            if (amethystBrowserMarkCurrentIndex >= highlights.length) amethystBrowserMarkCurrentIndex = 0;

            // Markiere und scrolle zum aktuellen Treffer
            const current = amethystBrowserMarkHighlights[currentIndex];
            current.classList.add('amethystBrowserCurrent-highlight');
            current.scrollIntoView({ behavior: 'smooth', block: 'center' });
            return amethystBrowserMarkCurrentIndex;
        }
        """
        
        //let markScript = WKUserScript(source: markjs, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        let userScript = WKUserScript(source: jsString, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        //webView?.configuration.userContentController.addUserScript(markScript)
        webView?.configuration.userContentController.addUserScript(userScript)
    }
    
    func injectCSSGlobally() {
        let cssString = """
        .amethystBrowserHighlight {
            background-color: yellow;
            
            color: black;
        }
        .amethystBrowserCurrent-highlight {
            background-color: orange;
        }
        """
        let jsCode = """
        var amethystBrowserHighlightStyle = document.createElement('style');
        amethystBrowserHighlightStyle.type = 'text/css';
        amethystBrowserHighlightStyle.innerHTML = `\(cssString)`;
        document.head.appendChild(amethystBrowserHighlightStyle);
        """
        let userScript = WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView?.configuration.userContentController.addUserScript(userScript)
    }
    
    func navigateHighlight(forward: Bool, completion: @escaping(Any?, (any Error)?) -> Void) {
        let direction = forward ? 1 : -1
        let jsCode = "amethystBrowserMarkNavigateHighlights(\(direction));"
        webView?.evaluateJavaScript(jsCode) { result, error in
            completion(result, error)
        }
    }
    func removeHighlights() {
        let jsCode = """
        amethystBrowserMarkRemoveHighlights();
        """
        webView?.evaluateJavaScript(jsCode) { result, error in
            if let error = error {
                print("Error while removing higlighting: \(error)")
            }
        }
    }
    func highlight(searchTerm: String, caseSensitive: Bool = false, completion: @escaping(Any?, (any Error)?) -> Void) {
        let jsCode = """
        var amethystBrowserMarkHightlightOptions = {
            "element": "span",
            "className": "amethystBrowserHighlight",
            "caseSensitive": \(caseSensitive ? "true": "false"),
        };
        amethystBrowserMarkHighlightText('\(searchTerm)', amethystBrowserMarkHightlightOptions);
        """
        webView?.evaluateJavaScript(jsCode) { result, error in
            completion(result, error)
        }
    }
    
    func injectAutofillCode() {
        let userScript = WKUserScript(source: credentialAutofillJS, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView?.configuration.userContentController.addUserScript(userScript)
    }
}
