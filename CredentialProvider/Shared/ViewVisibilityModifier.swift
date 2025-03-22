//
//  ViewVisibilityModifier.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 19.03.25.
//
import SwiftUI

struct ViewVisibilityModifier: ViewModifier {
    let onAppeared: () -> Void
    
    func body(content: Content) -> some View {
        content
            .background(ViewVisibilityDetector(onAppeared: onAppeared))
    }
}

struct ViewVisibilityDetector: UIViewRepresentable {
    let onAppeared: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.onAppeared()
        }
    }
}

extension View {
    func onViewDidAppear(perform action: @escaping () -> Void) -> some View {
        self.modifier(ViewVisibilityModifier(onAppeared: action))
    }
}
