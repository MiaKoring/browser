//
//  KeyBindsRow.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 13.12.24.
//

import SwiftUI

struct KeyBindsRow: View {
    let keybind: UDKey
    @State var text = ""
    @FocusState var textFieldFocused
    @State var redForeground: Bool = false
    @Binding var triggerRecompute: Bool
    
    var body: some View {
        HStack {
            Text(keybind.shortcutName)
            Spacer()
            TextField("Keys", text: $text)
                .background() {
                    KeyEventBlocker(text: $text, isFocused: $textFieldFocused)
                }
                .frame(width: 50)
                .focused($textFieldFocused)
                .foregroundStyle(redForeground ? .red: .primary)
        }
        .onAppear(perform: mapModifierToSymbol)
        .onLoseFocus(textFieldFocused, onTextFieldLoseFocus)
        .onChange(of: triggerRecompute, evalRedHighlight)
    }
    private func appear() {
        text = ""
        redForeground = KeybindsGroup.allCases.contains(where: { group in
            group.children.contains(where: { $0.shortcut == keybind.shortcut && $0.rawValue != keybind.rawValue})
        })
    }
    
    private func onTextFieldLoseFocus() {
        if let key = text.last {
            var eventModifiers: EventModifiers = []
            for modifier in text.dropLast() {
                eventModifiers.insert(EventModifiers(stringRepresentation: String(modifier)))
            }
            let shortcut = Shortcut(key: KeyEquivalent(key), modifier: eventModifiers)
            redForeground = KeybindsGroup.allCases.contains(where: { group in
                group.children.contains(where: {$0.shortcut == shortcut && $0.rawValue != keybind.rawValue})
            })
            keybind.shortcut = shortcut
        }
        triggerRecompute.toggle()
    }
    
    private func evalRedHighlight() {
        redForeground = KeybindsGroup.allCases.contains(where: { group in
            group.children.contains(where: {$0.shortcut == keybind.shortcut && $0.rawValue != keybind.rawValue})
        })
    }
    
    private func mapModifierToSymbol() {
        text = "\(keybind.shortcut.modifier.contains(.command) ? "⌘": "")\(keybind.shortcut.modifier.contains(.shift) ? "⇧": "")\(keybind.shortcut.modifier.contains(.option) ? "⌥": "")\(keybind.shortcut.modifier.contains(.control) ? "⌃": "")\("\(keybind.shortcut.key.character)".uppercased())"
    }
}

extension EventModifiers {
    public init(stringRepresentation: String) {
        switch stringRepresentation {
        case "⌘": self = .command
        case "⇧": self = .shift
        case "⌥": self = .option
        case "⌃": self = .control
        default: self = .all
        }
    }
}
