//
//  ImportError.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 25.03.25.
//

enum ImportError: Error {
    case failedAccountFetch
    case formatMatch
    case parseError(CSVParseError)
    case anyParseError(Error)
}

extension ImportError {
    var localizedDescription: String {
        switch self {
        case .failedAccountFetch:
            "Failed to fetch existing accounts"
        case .formatMatch:
            "Format doesn't match"
        case .parseError(let cSVParseError):
            "CSVParseError: \(cSVParseError.localizedDescription)"
        case .anyParseError(let error):
            "ParseError: \(error.localizedDescription)"
        }
    }
}
