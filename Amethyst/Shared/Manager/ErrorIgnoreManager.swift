//
//  ErrorIgnoreManager.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 07.02.25.
//
import Foundation

struct ErrorIgnoreManager {
    public static func addIgnoredURLError (_ error: Error) {
        var current = Set(IgnoredError.ignoredURLErrors.all)
        current.insert(error.localizedDescription)
        IgnoredError.ignoredURLErrors.all = Array(current)
    }
    
    public static func addIgnoredURLError (_ description: String) {
        var current = Set(IgnoredError.ignoredURLErrors.all)
        current.insert(description)
        IgnoredError.ignoredURLErrors.all = Array(current)
    }
    
    public static func isURLErrorIgnored (_ error: Error) -> Bool {
        return IgnoredError.ignoredURLErrors.all.contains(error.localizedDescription)
    }
    
    public static func removeIgnoredURLError (_ description: String) {
        var current = IgnoredError.ignoredURLErrors.all
        current.removeAll(where: {$0 == description})
        IgnoredError.ignoredURLErrors.all = current
    }
    
    public static func clearIgnoredURLErrors() {
        IgnoredError.ignoredURLErrors.all = []
    }
}
