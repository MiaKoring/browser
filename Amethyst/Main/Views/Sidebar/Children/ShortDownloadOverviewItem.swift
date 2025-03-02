//
//  ShortDownloadOverviewItem.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 02.03.25.
//

import SwiftUI

struct ShortDownloadOverviewItem: View {
    let item: DownloadItem
    @State var isHovered: Bool = false
    var body: some View {
        HStack {
            item.icon
                .frame(maxWidth: 50, maxHeight: 50)
                .if(item.progress != nil) { view in
                    view.overlay(alignment: .bottom) {
                        ProgressView(value: item.progress?.value)
                            .progressViewStyle(.linear)
                            .padding(.horizontal, 5)
                    }
                }
            Text(item.name)
                .lineLimit(1)
            Spacer()
        }
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            if let url = item.url {
                NSWorkspace.shared.open(url)
            }
        }
        .if(isHovered) { view in
            view.background(.regularMaterial)
        }
        .contextMenu {
            Button("Show in Finder") {
                if let url = item.url {
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                }
            }
        }
    }
}
