//
//  MainBackground.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import SwiftUI

struct BackgroundView<C: View>: View {
    let content: C
    let background: AngularGradient
    let shouldRotate: Bool
    @State var rotation: Double = 0
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    init(_ background: AngularGradient? = nil, shouldRotate: Bool = true, @ViewBuilder content: () -> C) {
        self.content = content()
        self.background = background ?? AngularGradient(stops:[.init(color: .myPurple, location: 0), .init(color: .myPurple.mix(with: .mainColorMix, by: 0.07), location: 0.5), .init(color: .myPurple, location: 1)], center: .center)
        self.shouldRotate = shouldRotate
    }

    var body: some View {
        ZStack {
            GeometryReader { reader in
                background
                    .rotationEffect(.degrees(rotation))
                    .onAppear() {
                        if !UDKey.dontAnimateBackground.boolValue && !reduceMotion && shouldRotate {
                            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                                rotation = 360
                            }
                        }
                    }
                    .frame(width: max(reader.size.width, reader.size.height) * 2, height: max(reader.size.width, reader.size.height) * 2)
                    .offset(x: -1 * max(reader.size.width, reader.size.height) / 2, y: -1 * max(reader.size.width, reader.size.height) / 2)
            }

            content
        }
    }
}

#Preview {
    BackgroundView(nil, shouldRotate: true) {
        Text("Test")
    }
}
