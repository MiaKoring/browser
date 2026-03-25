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
    func ifMacOS26Available<Content: View>(
        and condition: Bool = true,
        _ content: (Self) -> Content,
    ) -> some View {
        if condition {
            content(self)
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
    func applyDesign<N, O>(for use26Design: Bool, new: @escaping (Self) -> N, old: @escaping (Self) -> O) -> some View where N: View, O: View {
        if #available(macOS 26.0, *), use26Design {
            new(self)
        } else {
            old(self)
        }
    }
    
    @ViewBuilder
    private func makeSidebar(isFixed: Bool, appearance: ColorScheme) -> some View {
        self
            .frame(maxHeight: .infinity)
            .frame(maxWidth: isFixed ? .infinity: 300)
            .padding(5)
            .background {
                HStack {
                    RoundedRectangle(cornerRadius: AmethystApp.windowRound / 2)
                        .fill(appearance == .dark ? .myPurple.mix(with: .white, by: 0.1): Color.test)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: AmethystApp.windowRound / 2)
                        .stroke(lineWidth: 1)
                        .fill(true: Color.gray, false: .ultraThickMaterial, with: appearance == .light)
                        .shadow(radius: 5)
                }
            }
            .padding(isFixed ? 0: 8)
    }
    
    @ViewBuilder @available(macOS 26.0, *)
    private func makeSidebar26(isFixed: Bool) -> some View {
        self
        .frame(maxHeight: .infinity)
        .frame(maxWidth: isFixed ? 400: 300)
        .padding(5)
        .glassEffect(in: RoundedRectangle(cornerRadius: AmethystApp.windowRound / 2))
        .padding(8)
    }
    
    @ViewBuilder
    func decideSidebarStyling(isFixed: Bool, appearance: ColorScheme, useMacos26Desing: Bool) -> some View {
        if #available(macOS 26.0, *), useMacos26Desing {
            self.makeSidebar26(isFixed: isFixed)
        } else {
            self.makeSidebar(isFixed: isFixed, appearance: appearance)
        }
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

