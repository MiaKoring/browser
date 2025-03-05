//
//  InputBarViewModel.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 03.12.24.
//
import SwiftUI

struct InputBar {
    @Environment(AppViewModel.self) var appViewModel
    @Environment(\.colorScheme) var appearance
    @Binding var text: String
    @Binding var showInputBar: Bool
    @FocusState var inputFocused: Bool
    @State var timer: Timer? = nil
    @State var lastInput: String = ""
    @State var quickSearchResults: [SearchSuggestion] = []
    @State var selectedResult: Int = 0
    let onSubmit: (String) -> Void
}
