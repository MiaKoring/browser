//
//  HistoryListView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 04.12.24.
//

import SwiftUI


struct HistoryListView: View {
    @Environment(ContentViewModel.self) var contentViewModel
    @Environment(AppViewModel.self) var appViewModel
    let items: [HistoryItem]
    let proxy: ScrollViewProxy
    @FocusState var focusedItem: Int?
    @State var shiftPressed: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        LazyVStack {
            ForEach(items, id: \.id) { item in
                Button {
                    openItem(item)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            if let title = item.title {
                                Text(title)
                                    .font(.title2)
                                    .lineLimit(1)
                                Text(item.url?.absoluteString ?? "")
                                    .font(.caption)
                                    .lineLimit(1)
                            } else {
                                Text(item.url?.absoluteString ?? "")
                                    .font(.title2)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background() {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                    }
                }
                .buttonStyle(.plain)
                .focused($focusedItem, equals: item.id)
            }
        }
        .onChange(of: focusedItem) {
            if let focusedItem {
                withAnimation(.linear) {
                    proxy.scrollTo(focusedItem, anchor: .center)
                }
            }
        }
        .onKeyPress(phases: [.down, .up]) { event in
            if event.modifiers == .shift {
                shiftPressed = event.phase == .down
                return .ignored
            }
            return .ignored
        }
    }
    
    func openItem(_ item: HistoryItem) {
        guard let url = item.url else { return }
        let vm = WebViewModel(contentViewModel: contentViewModel, appViewModel: appViewModel)
        vm.load(urlString: url.absoluteString)
        let tab = ATab(webViewModel: vm)
        contentViewModel.tabs.append(tab)
        if !shiftPressed {
            contentViewModel.currentTab = tab.id
            dismiss()
        }
    }
}
