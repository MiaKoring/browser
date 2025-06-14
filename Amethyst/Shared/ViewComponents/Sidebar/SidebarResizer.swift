//
//  Resizer.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 01.12.24.
//

import SwiftUI

struct SidebarResizer: View {
    @Environment(AppViewModel.self) var appViewModel
    @Binding var sidebarWidth: CGFloat
    var trailing: Bool = false
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
                        sidebarWidth = max(245, min(trailing ? sidebarWidth + changed: sidebarWidth - changed, 400))
                    }
                    .onEnded { _ in
                        NSCursor.arrow.set()
                        if trailing {
                            UDKey.trailingFixedSidebarWidth.doubleValue = sidebarWidth
                        } else {
                            UDKey.leadingFixedSidebarWidth.doubleValue = sidebarWidth
                        }
                    }
            )
            .onHover { hovering in
                if hovering {
                    NSCursor.frameResize(position: .right, directions: .all).set()
                } else {
                    NSCursor.arrow.set()
                }
            }
            .applyDesign(for: appViewModel.useMacOS26Design) { view in view } old: { view in
                view
                    .offset(x: trailing ? -10: 10)
            }
    }
}
