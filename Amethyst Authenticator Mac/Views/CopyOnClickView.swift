//
//  CopyOnClickView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 24.03.25.
//

import SwiftUI

struct CopyOnClickView: View {
    @State var obfuscated: Bool = false
    @State var resetToDisplayTimer: Timer?
    @State var isHovered: Bool = false
    @State var showCopiedLabel: Bool = false
    var text: String
    var shouldObfuscate: Bool = false
    
    init(text: String, shouldObfuscate: Bool) {
        self.obfuscated = shouldObfuscate
        self.text = text
        self.shouldObfuscate = shouldObfuscate
    }
    
    var body: some View {
        HStack {
            Spacer()
            if #available(macOS 26.0, *) {
                Button {
                    copyAndDeobfuscate()
                } label: {
                    Text(!obfuscated ? text: Array(repeating: "•", count: text.count).joined())
                        .fontWeight(!obfuscated ? .regular: .heavy)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.bordered)
                .tint(showCopiedLabel ? .green: .secondary)
            } else {
                if !showCopiedLabel {
                    Text(!obfuscated ? text: Array(repeating: "•", count: text.count).joined())
                        .fontWeight(!obfuscated ? .regular: .heavy)
                        .foregroundStyle(.secondary)
                        .padding(3)
                        .onTapGesture {
                            copyAndDeobfuscate()
                        }
                } else {
                    Label("Copied", systemImage: "square.on.square")
                        .padding(3)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.tertiary)
                        }
                }
            }
        }
            .contentShape(Rectangle())
            .onHover { hovering in
                guard shouldObfuscate else { return }
                if !hovering {
                    obfuscated = true
                }
                isHovered = hovering
            }
    }
    private func copyAndDeobfuscate() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        withAnimation(.linear(duration: 0.15)) {
            showCopiedLabel = true
        }
        obfuscated = false
        resetToDisplayTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { timer in
            if !isHovered && shouldObfuscate {
                obfuscated = true
            }
            withAnimation(.linear(duration: 0.15)) {
                showCopiedLabel = false
            }
            timer.invalidate()
        }
    }
}
