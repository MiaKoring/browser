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
                            if appearance == .dark {
                                UnevenRoundedRectangle(cornerRadii: .init(topLeading: 15, bottomLeading: 15, bottomTrailing: 5, topTrailing: 15))
                                    .fill(.thinMaterial)
                            } else {
                                UnevenRoundedRectangle(cornerRadii: .init(topLeading: 15, bottomLeading: 15, bottomTrailing: 5, topTrailing: 15))
                                    .fill(.quinary)
                            }
                            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 15, bottomLeading: 15, bottomTrailing: 5, topTrailing: 15))
                                .stroke(style: .init(lineWidth: 1))
                                .fill(.ultraThinMaterial)
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
            if appearance == .dark {
                Image(systemName: "arrow.down.app")
                    .font(.title)
                    .foregroundStyle(.gray.mix(with: .mainColorMix, by: 0.3))
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
            } else {
                Image(systemName: "arrow.down.app")
                    .font(.title)
                    .foregroundStyle(.gray.mix(with: .mainColorMix, by: 0.3))
                    .padding(5)
                    .background(.quinary)
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
}
