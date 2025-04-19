//
//  MostUsedPasswordChecker.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 10.03.25.
//

import Foundation

class PasswordChecker {
    private var commonPasswords: Set<String> = []
    
    init() {
        loadCommonPasswords()
    }
    
    private func loadCommonPasswords() {
        // Suche nach der Datei im Bundle
        if let fileURL = Bundle.main.url(forResource: "mostCommonPasswords", withExtension: "txt") {
            do {
                let passwordsContent = try String(contentsOf: fileURL, encoding: .utf8)
                let passwords = passwordsContent.components(separatedBy: .newlines)
                
                // In ein Set umwandeln für schnelle Suche (O(1) Komplexität)
                commonPasswords = Set(passwords.filter { !$0.isEmpty })
                print("Erfolgreich \(commonPasswords.count) Passwörter geladen")
            } catch {
                print("Fehler beim Laden der Passwortdatei: \(error)")
            }
        } else {
            print("Passwortdatei nicht gefunden")
        }
    }
    
    /// Überprüft, ob das Passwort in der Liste der häufigen Passwörter ist
    /// - Parameter password: Zu überprüfendes Passwort
    /// - Returns: True wenn das Passwort zu häufig ist, false wenn es sicher erscheint
    func isCommonPassword(_ password: String) -> Bool {
        return commonPasswords.contains(password) || commonPasswords.contains(password.lowercased())
    }
    
    /// Erweiterte Passwortprüfung mit Stärkebewertung
    /// - Parameter password: Zu überprüfendes Passwort
    /// - Returns: Tuple mit Informationen zur Passwortstärke und ob es häufig ist
    func checkPassword(_ password: String) -> Double {
        let isCommon = isCommonPassword(password)
        let strength = calculateStrength(password)
        
        print(isCommon)
        
        return isCommon ? -1.0: strength
    }
    
    private func calculateStrength(_ password: String) -> Double {
        var score = 0.0
        
        if password.count >= 8 {
            score += 1
        }
        if password.count >= 12 {
            score += 1
        }
        if password.count >= 16 {
            score += 0.5
        }
        
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasDigit = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecialChar = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        
        if hasUppercase { score += 1 }
        if hasLowercase { score += 1 }
        if hasDigit { score += 1 }
        if hasSpecialChar { score += 1.5 }
        
        let hasThreeConsecutiveChars = password.range(of: "(.)\\1{2,}", options: .regularExpression) != nil
        if hasThreeConsecutiveChars { score -= 1 }
        
        return min(max(score / 7.0, 0.0), 1.0)
    }
}
