//
//  URLDisplayViewModel.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//

import SwiftUI
import SwiftData

struct URLDisplay: TabOpener {
    @Environment(ContentViewModel.self) var contentViewModel
    @Environment(AppViewModel.self) var appViewModel: AppViewModel
    @Environment(\.modelContext) var context: ModelContext
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.colorScheme) var appearance
    @State var showTextField: Bool = false
    @State var text: String = ""
    @State var url: String = ""
    @FocusState var urlTextFieldFocused: Bool
}
