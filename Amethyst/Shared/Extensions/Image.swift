//
//  Image.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 17.12.24.
//

import SwiftUI

extension Image {
    func sidebarTopButton(hovered: Binding<Bool>, appearance: ColorScheme = .dark, onTap: @escaping () -> Void) -> some View {
        self
            .font(.title2)
            .foregroundStyle(appearance == .dark ? Color.gray: Color.gray.mix(with: .black, by: 0.4))
            .padding(3)
            .background() {
                if !hovered.wrappedValue {
                    Color.clear
                } else {
                    Color.white.opacity(0.1)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            .onHover { hovering in
                withAnimation(.linear(duration: 0.07)) {
                    hovered.wrappedValue = hovering
                }
            }
            .onTapGesture {
                onTap()
            }
    }
    
    func sizeRef(_ view: @escaping () -> some View) -> some View {
        view()
            .hidden()
            .overlay {
                self
                    .resizable()
                    .scaledToFit()
            }
    }
    
    func setupImageStyle() -> some View {
        self
            .resizable()
            .scaledToFit()
            .shadow(color: .myPurple, radius: 10)
            .padding(.horizontal, 30)
    }
}
