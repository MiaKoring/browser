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
    func background<T, F>(`true`: T, `false`: F, with condition: Bool) -> some View where T : ShapeStyle, F : ShapeStyle {
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
    
    func onLoseFocus(_ state: Bool, _ execute: @escaping () -> Void) -> some View {
        self.onChange(of: state) {
            if !state {
                execute()
            }
        }
    }
    
    func onGetFocus(_ state: Bool, _ execute: @escaping () -> Void) -> some View {
        self.onChange(of: state) {
            if state {
                execute()
            }
        }
    }
    
    @ViewBuilder
    func activeIndicator<S>(isActive: Bool, _ fill: S = .blue) -> some View where S : ShapeStyle {
        self.overlay(alignment: .topTrailing) {
            if isActive {
                Circle()
                    .fill(fill)
                    .frame(width: 8)
                    .offset(x: -3, y: 3)
            }
        }
    }
    
    @ViewBuilder
    func placeBottomLeading() -> some View {
        VStack {
            Spacer()
            HStack {
                self
                Spacer()
            }
        }
    }
}

