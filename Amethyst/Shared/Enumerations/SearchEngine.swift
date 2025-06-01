//
//  SearchEngine.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

enum SearchEngine: Int, CaseIterable {
    case duckduckgo
    case google
    case ecosia
    case startpage
}

extension SearchEngine: Identifiable {
    var id: Int { self.rawValue }
    var logoName: String {
        switch self {
        case .duckduckgo:
            "ddgLogo"
        case .google:
            "googleLogo"
        case .ecosia:
            "ecosiaLogo"
        case .startpage:
            "startpageLogo"
        }
    }
}

