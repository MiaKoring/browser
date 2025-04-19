//
//  PasswordsSearchBar.swift
//  Amethyst Project
//
//  Created by Mia Koring on 16.04.25.
//

import SwiftUI

struct PasswordsSearchBar: View {
    @Binding var text: String
    @Environment(\.colorScheme) var appearance
    var body: some View {
        VStack {
            TextField("Search", text: $text)
                .textFieldStyle(.plain)
        }
        .padding(10)
        .background() {
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .background(.mainColorMix.opacity(appearance == .dark ? 0.2: 0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .foregroundStyle(.mainColorMix.opacity(0.5))
    }
}
