//
//  SearchViewModel.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 03.12.24.
//
import SwiftUI

struct DocumentSearchView: View {
    @Environment(ContentViewModel.self) var contentViewModel
    @ObservedObject var webViewModel: WebViewModel
    @State var text: String
    @State var count: Int?
    @State var pos: Int = 0
    @FocusState var textFieldFocused: Bool
    @State var caseSensitive: Bool = false
    
    var body: some View {
        HStack(spacing: 5) {
            TextField("Search", text: $text)
                .textFieldStyle(.plain)
                .font(.title2)
                .focused($textFieldFocused)
                .onSubmit(submitted)
                .onKeyPress(.escape) {
                    contentViewModel.showInlineSearch = false
                    return .handled
                }
                .onKeyPress(action: handleKeyPress)
            Image(systemName: "textformat.size")
                .bold()
                .frame(width: 20, height: 20)
                .if(caseSensitive) { view in
                    view
                        .background() {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.thinMaterial)
                        }
                }
                .contentShape(RoundedRectangle(cornerRadius: 5))
                .onTapGesture {
                    withAnimation(.linear(duration: 0.1)) {
                        caseSensitive.toggle()
                    }
                }
            
            CountDisplay(count: count, pos: pos)
            NavigationButton(forward: true, handlePress: handleNavigationEvent)
            NavigationButton(forward: false, handlePress: handleNavigationEvent)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.myPurple)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(lineWidth: 2)
                        .foregroundStyle(.thickMaterial)
                }
        }
        .onAppear() { textFieldFocused = true }
        .onDisappear() { webViewModel.removeHighlights() }
    }
    
    private func submitted() {
        webViewModel.highlight(searchTerm: text, caseSensitive: caseSensitive) { result, error in
            count = result as? Int
        }
        contentViewModel.lastInlineQuery = text
        pos = 0
    }
    
    private func handleKeyPress(_ event: KeyPress) -> KeyPress.Result {
        if event.key == .tab && event.modifiers.isEmpty {
            webViewModel.navigateHighlight(forward: true) { result, _ in
                pos = result as? Int ?? 0
            }
            return .handled
        }
        if event.key == KeyEquivalent("\u{19}") && event.modifiers == .shift {
            webViewModel.navigateHighlight(forward: false) { result, _ in
                pos = result as? Int ?? 0
            }
            return .handled
        }
        return .ignored
    }
    
    private func handleNavigationEvent(_ forward: Bool) {
        webViewModel.navigateHighlight(forward: forward) { result, _ in
            pos = result as? Int ?? 0
        }
    }
    
    private struct CountDisplay: View {
        let count: Int?
        let pos: Int
        var body: some View {
            if let count {
                Text("\(count > 0 ? pos + 1: pos)/\(count)")
            } else {
                Text("0/?")
            }
        }
    }
    
    private struct NavigationButton: View {
        let forward: Bool
        let handlePress: (Bool) -> Void
        var body: some View {
            Button {
                handlePress(forward)
            } label: {
                Image(systemName: "chevron.\(forward ? "down": "up")")
                    .bold()
                    .frame(width: 20, height: 20)
                    .background() {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.thinMaterial)
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 5))
            }
            .buttonStyle(.plain)
        }
    }
}
