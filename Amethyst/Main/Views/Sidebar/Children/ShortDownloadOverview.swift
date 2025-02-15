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
                        Text(item.name)
                    }
                }
            }
        }
        .onAppear {
            updateDisplayedItems()
        }
    }
}
