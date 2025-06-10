//
//  DownloadButtonView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.02.25.
//

import SwiftUI

struct DownloadOverviewButton: View {
    @Environment(AppViewModel.self) var appViewModel
    @Environment(\.colorScheme) var appearance
    @State var playAnimation: Bool = false
    @Binding var isHovered: Bool
    
    var body: some View {
        Image(systemName: "arrow.down.app")
            .font(.title)
            .foregroundStyle(.gray.mix(with: .mainColorMix, by: 0.3))
            .padding(5)
            .background(true: .regularMaterial, false: .quinary, with: appearance == .dark)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(-2)
            .activeIndicator(isActive: !(appViewModel.downloadManager?.activeDownloads.isEmpty ?? true))
            .onHover { isHovered in
                if isHovered { playAnimation.toggle() }
                self.isHovered = isHovered
            }
            .symbolEffect(.wiggle.byLayer, value: playAnimation)
    }
}
