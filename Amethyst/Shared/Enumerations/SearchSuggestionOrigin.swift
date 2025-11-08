//
//  SearchSuggestionOrigin.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 02.12.24.
//
import SwiftUI

enum SearchSuggestionOrigin {
    case history
    case searchEngine
    case bang
}

extension SearchSuggestionOrigin {
    var image: Image {
        switch self {
            case .searchEngine:
                (SearchEngine(rawValue: UDKey.searchEngine.intValue) ?? .duckduckgo).icon
            case .history, .bang:
                Image("AmethystLogo")
        }
    }
}
