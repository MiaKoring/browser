//
//  RegexExtensions.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import Foundation
extension Regexpr {
    var regex: Regex<Substring> {
        return switch self {
        case .url:
            /https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,}\b(?:[-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)/
        case .urlWithoutProtocol:
            /(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,}\b(?:[-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)/
        case .ip:
            /^https?:\/\/(?:[0-9]{1,3}\.){3}[0-9]{1,3}(?::[0-9]+)?(?:\/\S*)?$/
        case .ipWithoutProtocol:
            /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}(?::[0-9]+)?(?:\/\S*)?$/
        case .localhost:
            /^https?:\/\/localhost(?::[0-9]+)(?:\/\S*)?$/
        case .localhostWithoutProtocol:
            /^localhost(?::[0-9]+)(?:\/\S*)?$/
        }
    }
}

