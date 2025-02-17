//
//  ShortDownloadOverview.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.02.25.
//

import SwiftUI

extension ShortDownloadOverview: View {
    var body: some View {
        VStack(alignment: .leading) {
            if !displayedItems.isEmpty {
                ForEach(displayedItems, id: \.name) { item in
                    HStack {
                        item.icon
                            .frame(maxWidth: 50, maxHeight: 50)
                            .if(item.progress != nil) { view in
                                view.overlay(alignment: .bottom) {
                                    ProgressView(value: item.progress?.value)
                                        .progressViewStyle(.linear)
                                        .padding(.horizontal, 5)
                                }
                            }
                        Text(item.name)
                            .lineLimit(1)
                        Spacer()
                    }
                    .onTapGesture {
                        if let url = item.url {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
            }
        }
        .onAppear {
            updateDisplayedItems()
        }
    }
}

