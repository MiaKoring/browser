//
//  HistoryView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 04.12.24.
//

import CoreData
import SwiftUI

struct HistoryView: View {
    @State private var days = [HistoryDay]()
    
    var body: some View {
        BackgroundView(shouldRotate: false) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(days) { day in
                            DetailView(title: Text(
                                "\(Date(timeIntervalSinceReferenceDate: day.dayTime).toString(with: "dd.MM.yyyy"))"
                            ), isExpanded: false) {
                                HistoryListView(items: day.sortedItems, proxy: proxy)
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            days = CDHistoryController.fetchAll(sortDescriptors: [
                NSSortDescriptor(keyPath: \HistoryDay.dayTime, ascending: false)
            ])
        }
    }
}
