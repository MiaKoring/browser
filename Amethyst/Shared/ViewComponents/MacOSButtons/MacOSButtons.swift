//
//  MacOSButtons.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//
import SwiftUI

struct MacOSButtons: View {
    @State var isHovered: Bool = false
    @Environment(ContentViewModel.self) var contentViewModel
    @Environment(AppViewModel.self) var appViewModel
    @Environment(\.dismissWindow) var dismissWindow
    
    var body: some View {
        HStack {
            if let window = NSApplication.shared.windows.first(where: {$0.identifier?.rawValue == contentViewModel.id}) {
                Image(systemName: isHovered ? "xmark.circle.fill": "circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .onTapGesture {
                        contentViewModel.blockNotification = true //to block notification didBecomeMain in ContentView
                        self.appViewModel.displayedWindows.remove(window.identifier?.rawValue ?? "")
                        dismissWindow()
                    }
                if !window.isZoomed {
                    Image(systemName: isHovered ? "minus.circle.fill": "circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            window.performMiniaturize(nil)
                        }
                } else {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.8))
                }
                
                Image(systemName: isHovered ? window.isZoomed ? "arrow.down.forward.and.arrow.up.backward.circle.fill" :"arrow.up.backward.and.arrow.down.forward.circle.fill": "circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                    .onTapGesture {
                        window.toggleFullScreen(self)
                    }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
