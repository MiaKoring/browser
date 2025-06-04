//
//  UDKey.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//
import SwiftUI

enum UDKey: String, CaseIterable, UserDefaultWrapper {
    case dontAnimateBackground
    case searchEngine
    case wasSetupOnce
    case lastAuthTime
    
    case newWindowShortcut
    case toggleSidebarShortcut
    case toggleSidebarFixedShortcut
    case togglePasswordsShortcut
    case togglePasswordsFixedShortcut
    case openSearchbarShortcut
    case openInlineSearchShortcut
    case goBackShortcut
    case goForwardShortcut
    case reloadShortcut
    case reloadFromSourceShortcut
    case previousTabShortcut
    case nextTabShortcut
    case closeCurrentTabShortcut
    case showHistoryShortcut
    case zoomInShortcut
    case zoomOutShortcut
    case resetZoomShortcut
    case triggerPasswordsAuth
    case sidebarOrientation
}

extension UDKey {
    var shortcut: Shortcut {
        get {
            guard let data = self.data else { return self.defaultShortcut }
            return (try? JSONDecoder().decode(Shortcut.self, from: data)) ?? self.defaultShortcut
        }
        nonmutating set {
            do {
                let encoded = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(encoded, forKey: self.key)
            } catch {
                print("Error encoding shortcut: \(error)")
            }
        }
    }
    
    var defaultShortcut: Shortcut {
        switch self {
        case .newWindowShortcut:
            Shortcut(key: "n", modifier: .command)
        case .toggleSidebarShortcut:
            Shortcut(key: "e", modifier: .command)
        case .toggleSidebarFixedShortcut:
            Shortcut(key: "e", modifier: [.command, .shift])
        case .togglePasswordsShortcut:
            Shortcut(key: "p", modifier: .command)
        case .togglePasswordsFixedShortcut:
            Shortcut(key: "p", modifier: [.command, .shift])
        case .openSearchbarShortcut:
            Shortcut(key: "t", modifier: .command)
        case .openInlineSearchShortcut:
            Shortcut(key: "f", modifier: .command)
        case .goBackShortcut:
            Shortcut(key: "ö", modifier: .command)
        case .goForwardShortcut:
            Shortcut(key: "ä", modifier: .command)
        case .reloadShortcut:
            Shortcut(key: "r", modifier: .command)
        case .reloadFromSourceShortcut:
            Shortcut(key: "r", modifier: [.command, .shift])
        case .previousTabShortcut:
            Shortcut(key: "w", modifier: [.command, .shift])
        case .nextTabShortcut:
            Shortcut(key: "s", modifier: [.command, .shift])
        case .closeCurrentTabShortcut:
            Shortcut(key: "c", modifier: .option)
        case .showHistoryShortcut:
            Shortcut(key: "y", modifier: .command)
        case .zoomInShortcut:
            Shortcut(key: "+", modifier: .command)
        case .zoomOutShortcut:
            Shortcut(key: "-", modifier: .command)
        case .resetZoomShortcut:
            Shortcut(key: "0", modifier: .command)
        case .triggerPasswordsAuth:
            Shortcut(key: "u", modifier: .command)
        default:
            Shortcut(key: " ", modifier: [])
        }
    }
    
    var keyboardShortcut: KeyboardShortcut {
        KeyboardShortcut(self.shortcut.key, modifiers: self.shortcut.modifier)
    }
    
    var shortcutName: String {
        switch self {
        case .newWindowShortcut: "Open New Window"
        case .toggleSidebarShortcut: "Toggle Sidebar"
        case .toggleSidebarFixedShortcut: "Fix Sidebar"
        case .togglePasswordsShortcut: "Toggle Password Sidebar"
        case .togglePasswordsFixedShortcut: "Fix Password Sidebar"
        case .openSearchbarShortcut: "Open Searchbar"
        case .openInlineSearchShortcut: "Document Search"
        case .goBackShortcut: "Go Back"
        case .goForwardShortcut: "Go Forward"
        case .reloadShortcut: "Reload"
        case .reloadFromSourceShortcut: "Reload from Source"
        case .previousTabShortcut: "Previous Tab"
        case .nextTabShortcut: "Next Tab"
        case .closeCurrentTabShortcut: "Close Current Tab"
        case .showHistoryShortcut: "Show History"
        case .zoomInShortcut: "Zoom In"
        case .zoomOutShortcut: "Zoom Out"
        case .resetZoomShortcut: "Reset Zoom"
        case .triggerPasswordsAuth: "Authenticate yourself"
        default: ""
        }
    }
}

struct Shortcut: Codable, Equatable {
    let key: KeyEquivalent
    let modifier: EventModifiers
    
    enum CodingKeys: String, CodingKey {
        case key
        case modifier
    }
    
    init(key: KeyEquivalent, modifier: EventModifiers) {
        self.key = key
        self.modifier = modifier
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = KeyEquivalent(try container.decode(String.self, forKey: .key).first ?? Character(" "))
        let val = try container.decode(Int.self, forKey: .modifier)
        modifier = EventModifiers(rawValue: val)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(key.character), forKey: .key)
        try container.encode(modifier.rawValue, forKey: .modifier)
    }
    
    static func ==(lhs: Shortcut, rhs: Shortcut) -> Bool {
        lhs.key.character == rhs.key.character && lhs.modifier == rhs.modifier
    }
}
