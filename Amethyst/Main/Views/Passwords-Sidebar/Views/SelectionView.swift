//
//  SelectionView.swift
//  Amethyst Project
//
//  Created by Mia Koring on 04.06.25.
//

import SwiftUI

struct SelectionMenu: View {
    @Binding var sortDirectionAcending: Bool
    @Binding var sortFilter: SortFilter
    @Binding var triggerSort: Bool
    var body: some View {
        Menu {
            Section {
                Button {
                    sortDirectionAcending = false
                    triggerSort.toggle()
                } label: {
                    HStack {
                        Image(systemName: sortDirectionAcending ? "arrow.up": "checkmark")
                        Text("Descending")
                    }
                }
                Button {
                    sortDirectionAcending = true
                    triggerSort.toggle()
                } label: {
                    HStack {
                        Image(systemName: !sortDirectionAcending ? "arrow.down": "checkmark")
                        Text("Ascending")
                    }
                }
            }
            Section {
                Button {
                    sortFilter = .edited
                    triggerSort.toggle()
                } label: {
                    HStack {
                        Image(systemName: sortFilter == .edited ? "checkmark": "pencil.line")
                        Text("Date Edited")
                    }
                }
                Button {
                    sortFilter = .created
                    triggerSort.toggle()
                } label: {
                    HStack {
                        Image(systemName: sortFilter == .created ? "checkmark": "plus.circle")
                        Text("Date Created")
                    }
                }
                Button {
                    sortFilter = .website
                    triggerSort.toggle()
                } label: {
                    HStack {
                        Image(systemName: sortFilter == .website ? "checkmark": "safari")
                        Text("Website")
                    }
                }
                Button {
                    sortFilter = .title
                    triggerSort.toggle()
                } label: {
                    HStack {
                        Image(systemName: sortFilter == .title ? "checkmark": "textformat")
                        Text("Title")
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 5, height: 5)
                        .offset(x: 3, y: 2)
                        
                }
                .foregroundStyle(.secondary)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
