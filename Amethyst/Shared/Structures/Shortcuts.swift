//
//  Shortcuts.swift
//  Amethyst Project
//
//  Created by Mia Koring on 11.06.25.
//
import SwiftUI

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
        lhs.key.character == rhs.key.character && lhs.modifier.symmetricDifference(rhs.modifier).isEmpty
    }
}
