//
//  IdentifierHandler.swift
//  Amethyst Project
//
//  Created by Mia Koring on 11.04.25.
//
import Foundation

struct IdentifierHandler {
    private static func removeSubdomain(from host: String) -> String? {
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
    
    static func getIdentifiers(urlString: String) -> Set<String> {
        var urlSet = Set<String>()
        guard let identifier = URL(string: urlString)?.host() else {
            return urlSet
        }
        urlSet.insert(identifier)
        guard let subdomainless = removeSubdomain(from: identifier) else {
            return urlSet
        }
        urlSet.insert(subdomainless)
        return urlSet
    }
}
