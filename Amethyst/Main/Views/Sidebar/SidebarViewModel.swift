//
//  Sidebar.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//
import SwiftUI

struct Sidebar {
    @Environment(ContentViewModel.self) var contentViewModel
    @Environment(AppViewModel.self) var appViewModel
    @Environment(\.colorScheme) var appearance
    @State var isSideBarButtonHovered: Bool = false
    @State var isNewTabHovered: Bool = false
    @State var isBackHovered: Bool = false
    @State var isForwardHovered: Bool = false
    @State var isReloadHovered: Bool = false
    
}
