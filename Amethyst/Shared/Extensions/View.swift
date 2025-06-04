//
//  View.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 07.12.24.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        _ `if`: (Self) -> Content
    ) -> some View {
        if condition {
            `if`(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func background<T, F>(`true`: T, `false`: F, with condition: Bool) -> some View where T : ShapeStyle, F : ShapeStyle{
        if condition {
            self.background(`true`)
        } else {
            self.background(`false`)
        }
    }
    
    @ViewBuilder
    func makeSidebar(isFixed: Bool, appearance: ColorScheme) -> some View {
        self
            .frame(maxHeight: .infinity)
            .frame(maxWidth: isFixed ? .infinity: 300)
            .padding(5)
            .background {
                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(appearance == .dark ? .myPurple.mix(with: .white, by: 0.1): Color.test)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 1)
                        .fill(true: Color.gray, false: .ultraThickMaterial, with: appearance == .light)
                        .shadow(radius: 5)
                }
            }
            .padding(isFixed ? 0: 8)
    }
    
    @ViewBuilder
    func addTopRowPadding(isFixed: Bool) -> some View {
        self
            .padding(.leading, isFixed ? 5: 0)
            .padding(.top, isFixed ? 5: 0)
    }
}
