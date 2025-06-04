//
//  Shape.swift
//  Amethyst Project
//
//  Created by Mia Koring on 04.06.25.
//

import SwiftUI

extension Shape {
    @ViewBuilder
    func fill<T, F>(`true`: T, `false`: F, with condition: Bool) -> some View where T : ShapeStyle, F : ShapeStyle{
        if condition {
            self.fill(`true`)
        } else {
            self.fill(`false`)
        }
    }
}
