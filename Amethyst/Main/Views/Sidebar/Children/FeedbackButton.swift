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
        DownloadOverviewButton(isHovered: .constant(false)).hidden().overlay {
            if appearance == .dark {
                Button {
                    let tab = ATab(webViewModel: .init(contentViewModel: contentViewModel, appViewModel: appViewModel))
                    tab.webViewModel.load(urlString: "https://amethyst.featurebase.app")
                    contentViewModel.tabs.append(tab)
                    contentViewModel.currentTab = tab.id
                } label: {
                    Rectangle()
                        .hidden()
                        .overlay {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .resizable()
                                .scaledToFit()
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray.mix(with: .mainColorMix, by: 0.3))
                                .symbolEffect(.wiggle.down.byLayer, value: playAnimation)
                        }
                        .padding(5)
                        .background(.regularMaterial)
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
            } else {
                Button {
                    let tab = ATab(webViewModel: .init(contentViewModel: contentViewModel, appViewModel: appViewModel))
                    tab.webViewModel.load(urlString: "https://amethyst.featurebase.app")
                    contentViewModel.tabs.append(tab)
                    contentViewModel.currentTab = tab.id
                } label: {
                    Rectangle()
                        .hidden()
                        .overlay {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .resizable()
                                .scaledToFit()
                                .fontWeight(.semibold)
                                .bold()
                                .foregroundStyle(.gray.mix(with: .mainColorMix, by: 0.3))
                                .onHover { isHovered in
                                    if isHovered {
                                        playAnimation.toggle()
                                    }
                                    self.isHovered = isHovered
                                }
                                .symbolEffect(.wiggle.down.byLayer, value: playAnimation)
                        }
                        .padding(5)
                        .background(.regularMaterial)
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
    }
}
