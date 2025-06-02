//
//  DownloadButtonViewModel.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.02.25.
//

import SwiftUI

struct DownloadOverviewButton {
    @Environment(AppViewModel.self) var appViewModel
    @Environment(ContentViewModel.self) var contentViewModel
    @Environment(\.colorScheme) var appearance
    @State var playAnimation: Bool = false
    @Binding var isHovered: Bool
}
