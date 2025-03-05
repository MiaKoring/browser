//
//  InputBar.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import SwiftUI

extension InputBar: View {
    var body: some View {
        VStack {
            TextField("Search or enter URL", text: $text)
                .textFieldStyle(.plain)
                .font(.title)
                .focused($inputFocused)
                .padding()
                .background() {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(selectedResult == 0 ? .myPurple.mix(with: .mainColorMix, by: 0.1).opacity(0.3): .myPurple.mix(with: .mainColorMix, by: 0.07).opacity(0.3))
                }
                .onSubmit {
                    let result = selectedResult
                    let searchResults = quickSearchResults
                    if result == 0 || searchResults.count == 0 || result > searchResults.count {
                        onSubmit(text)
                        return
                    }
                    onSubmit(searchResults[result - 1].urlString)
                }
                .onKeyPress(.escape) {
                    showInputBar = false
                    return .handled
                }
                .onKeyPress { event in
                    if event.key == .tab && event.modifiers.isEmpty {
                        updateSelection(up: false)
                        return .handled
                    }
                    if event.key == KeyEquivalent("\u{19}") && event.modifiers == .shift {
                        updateSelection(up: true)
                        return .handled
                    }
                    return .ignored
                }
                
            if !quickSearchResults.isEmpty {
                VStack {
                    ForEach(quickSearchResults, id: \.id) { result in
                        HStack {
                            Text(result.title)
                                .font(.title3)
                                .padding(5)
                                .lineLimit(1, reservesSpace: true)
                            Text(result.urlString)
                                .font(.title3)
                                .padding(5)
                                .foregroundStyle(.gray)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(10)
                        .background {
                            if (quickSearchResults.firstIndex(where: {$0.id == result.id}) ?? -1) + 1 == selectedResult {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(lineWidth: 2)
                                    .foregroundStyle(.myPurple.mix(with: .mainColorMix, by: 0.15).opacity(0.6))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSubmit(result.urlString)
                        }
                    }
                }
            }
        }
        .padding(10)
        .background() {
            RoundedRectangle(cornerRadius: 10)
                .fill(.myPurple.opacity(0.5))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundStyle(.myPurple.mix(with: .white, by: 0.15).opacity(0.4))
                }
        }
        .onAppear() {
            inputFocused = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
                if lastInput != text && text.count >= 2 {
                    Task {
                        await timerSuggestionFetch()
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var text: String = ""
    VStack {
        Spacer()
        HStack {
            Spacer()
            InputBar(text: $text, showInputBar: .constant(true)) {_ in}
            Spacer()
        }
        Spacer()
    }
    .frame(maxWidth: 1000)
}
