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
}
