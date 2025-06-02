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
            Divider()
            if !displayedItems.isEmpty {
                ForEach($displayedItems, id: \.self) { item in
                    ShortDownloadOverviewItem(item: item)
                }
            }
        }
        .onAppear {
            updateDisplayedItems()
        }
    }
}

