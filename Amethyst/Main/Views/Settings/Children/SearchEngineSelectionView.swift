//
//  SearchEngineSelectionView.swift
//  Amethyst Project
//
//  Created by Mia Koring on 01.06.25.
//
import SwiftUI

struct SearchEngineSelectionView: View {
    @State var selectedSearchEngine: SearchEngine = SearchEngine(rawValue: UDKey.searchEngine.intValue) ?? .duckduckgo
    @State var options = SearchEngine.allCases.shuffled()
    var maxHeight: CGFloat = 80
    var body: some View {
        ForEach (options) { engine in
            Button {
                UDKey.searchEngine.intValue = engine.rawValue
                selectedSearchEngine = engine
            } label: {
                Image(engine.logoName).resizable().scaledToFit().frame(maxHeight: maxHeight)
            }
            .if(selectedSearchEngine == engine) { view in
                view.overlay(alignment: .topTrailing) {
                    Image(systemName: "checkmark.seal.fill")
                        .offset(x: 15)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
