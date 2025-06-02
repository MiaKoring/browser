//
//  FeedbackButton.swift
//  Amethyst Project
//
//  Created by Mia Koring on 02.06.25.
//

import SwiftUI

struct FeedbackButton: View {
    @Environment(AppViewModel.self) var appViewModel
    @Environment(ContentViewModel.self) var contentViewModel
    @Environment(\.colorScheme) var appearance
    @State var playAnimation: Bool = false
    @State var isHovered = false
    
    var body: some View {
        Button {
            let tab = ATab(webViewModel: .init(contentViewModel: contentViewModel, appViewModel: appViewModel))
            tab.webViewModel.load(urlString: "https://amethyst.featurebase.app")
            contentViewModel.tabs.append(tab)
            contentViewModel.currentTab = tab.id
        } label: {
            Image(systemName: "bubble.left.and.bubble.right")
                .sizeRef { Image(systemName: "arrow.down.app").font(.title) }
                .fontWeight(.semibold)
                .foregroundStyle(.gray.mix(with: .mainColorMix, by: 0.3))
                .symbolEffect(.wiggle.down.byLayer, value: playAnimation)
                .padding(5)
                .background(true: .regularMaterial, false: .quinary, with: appearance == .dark)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(-2)
                .onHover { isHovered in
                    if isHovered {
                        playAnimation.toggle()
                    }
                    self.isHovered = isHovered
                }
        }
        .buttonStyle(.plain)
    }
}
