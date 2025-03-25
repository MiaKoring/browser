//
//  View.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 25.03.25.
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
        }else {
            self
        }
    }
}
