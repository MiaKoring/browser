//
//  ShortDownloadOverviewItem.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 02.03.25.
//

import SwiftUI

struct ShortDownloadOverviewItem: View {
    @Binding var item: DownloadItem
    @State var isHovered: Bool = false
    @Environment(AppViewModel.self) var appViewModel
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
                .foregroundStyle(item.info != nil ? item.info?.task.state == .running || item.info?.task.state == .completed ? .primary: Color.red: .primary)
            Spacer()
            if item.progress != nil && item.info?.task.state == .running {
                Button {
                    guard let downloadManager = appViewModel.downloadManager, let task = item.info?.task
                    else {
                        return
                    }
                    downloadManager.activeDownloads.removeValue(forKey: task)
                    task.cancel()
                    
                    
                } label: {
                    Image(systemName: "xmark.circle")
                }
                .foregroundStyle(.gray)
                .buttonStyle(.plain)
                .padding(.trailing, 10)
            }
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

