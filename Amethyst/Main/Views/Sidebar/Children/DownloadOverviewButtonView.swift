//
//  DownloadButtonView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.02.25.
//

import SwiftUI

extension DownloadOverviewButton: View {
    var body: some View {
        if isHovered {
            HStack {
                Spacer()
                ShortDownloadOverview()
                    .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 15, bottomLeading: 15, bottomTrailing: 5, topTrailing: 15)))
                    .frame(width: 200)
                    .background {
                        ZStack {
                            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 15, bottomLeading: 15, bottomTrailing: 5, topTrailing: 15))
                                .fill(.thinMaterial)
                            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 15, bottomLeading: 15, bottomTrailing: 5, topTrailing: 15))
                                .stroke(style: .init(lineWidth: 2))
                                .fill(.thinMaterial)
                        }
                        
                    }
                    .onHover { hovering in
                        self.isHovered = hovering
                    }
            }
            .padding(.bottom, -6)
        }
        HStack {
            Spacer()
            Image(systemName: "arrow.down.app")
                .font(.title)
                .foregroundStyle(.gray.mix(with: .white, by: 0.3))
                .padding(5)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(-2)
                .overlay(alignment: .topTrailing) {
                    if let downloadManager = appViewModel.downloadManager, !downloadManager.activeDownloads.isEmpty {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8)
                            .offset(x: -3, y: 3)
                    }
                }
                .onHover { isHovered in
                    if isHovered {
                        playAnimation.toggle()
                    }
                    self.isHovered = isHovered
                }
                .symbolEffect(.wiggle.byLayer, value: playAnimation)
        }
    }
}
