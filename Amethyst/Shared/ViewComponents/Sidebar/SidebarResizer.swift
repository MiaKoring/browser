//
//  Resizer.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 01.12.24.
//

import SwiftUI

struct SidebarResizer: View {
    @Binding var sidebarWidth: CGFloat
    var body: some View {
        Rectangle()
            .fill(.clear)
            .frame(width: 10)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        NSCursor.frameResize(position: .right, directions: .all).set()
                        let changed = value.startLocation.x - value.location.x
                        sidebarWidth = max(220, min(sidebarWidth - changed, 400))
                    }
                    .onEnded { _ in
                        NSCursor.arrow.set()
                    }
            )
            .onHover { hovering in
                if hovering {
                    NSCursor.frameResize(position: .right, directions: .all).set()
                } else {
                    NSCursor.arrow.set()
                }
            }
            .offset(x: 10)
    }
}
