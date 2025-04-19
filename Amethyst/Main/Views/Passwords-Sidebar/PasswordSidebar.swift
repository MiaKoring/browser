//
//  PasswordSidebar.swift
//  Amethyst Project
//
//  Created by Mia Koring on 10.04.25.
//

import SwiftUI
import SwiftData
import AmethystAuthenticatorCore

struct PasswordSidebar: View {
    @Environment(ContentViewModel.self) var contentViewModel
    @Environment(AppViewModel.self) var appViewModel
    @Environment(\.colorScheme) var appearance
    @State var isSideBarButtonHovered: Bool = false
    @Environment(\.modelContext) var context

    @State var error: Error?
    @State var isPlusButtonHovered: Bool = false
    @State var showAccountCreationSheet: Bool = false
    @State var currentIdentifier: String?
    @State var sortData = PasswordSortData()
    
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "sidebar.right")
                        .sidebarTopButton(hovered: $isSideBarButtonHovered, appearance: appearance) {
                            contentViewModel.isPasswordFixed.toggle()
                            contentViewModel.isPasswordShown = false
                        }
                    Spacer()
                    Text("Passwords")
                        .foregroundStyle(.secondary)
                    Spacer()
                    SelectionMenu(sortDirectionAcending: $sortData.ascending, sortFilter: $sortData.filter, triggerSort: $sortData.triggerSort)
                        
                    Image(systemName: "plus")
                        .sidebarTopButton(hovered: $isPlusButtonHovered) {
                            prepareCreationSheet()
                        }
                }
                .padding(.leading, contentViewModel.isPasswordFixed ? 5: 0)
                .padding(.top, contentViewModel.isPasswordFixed ? 5: 0)
                .padding(.horizontal, 3)
                PasswordsContentView(context: context)
                    .environment(sortData)
            }
        }
        .frame(maxHeight: .infinity)
        .frame(maxWidth: contentViewModel.isPasswordFixed ? .infinity: 300)
        .padding(5)
        .background {
            HStack {
                if contentViewModel.isPasswordFixed {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.ultraThinMaterial)
                        .background(appearance == .light ? .white.opacity(0.5): .clear)
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(appearance == .dark ? .myPurple.mix(with: .white, by: 0.1): Color.test)
                }
            }
            .overlay {
                if appearance == .light {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 1)
                        .fill(Color.gray)
                        .shadow(radius: 5)
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(lineWidth: 1)
                        .fill(.ultraThickMaterial)
                        .shadow(radius: 5)
                }
            }
        }
        .padding(contentViewModel.isPasswordFixed ? 0: 8)
        .alert("An Error occured", isPresented: .constant(error != nil)) {
            Button("OK", role: .cancel) {
                error = nil
            }
        } message: {
            Text(error?.localizedDescription ?? "")
        }
        .sheet(item: $currentIdentifier ) { identifier in
            AccountDetailEdit(service: identifier, context: context) {
                showAccountCreationSheet = false
                currentIdentifier = nil
            }
        }
        .sheet(isPresented: $showAccountCreationSheet) {
            AccountDetailEdit(service: "", context: context) {
                showAccountCreationSheet = false
                currentIdentifier = nil
            }
        }
        
    }
    
    
    func prepareCreationSheet() {
        guard let tabID = contentViewModel.currentTab, let tab = contentViewModel.tabs.first(where: {$0.id == tabID }), let currentURL = tab.webViewModel.currentURL else {
            showAccountCreationSheet = true
            return
        }
        let identifier = IdentifierHandler.getIdentifiers(urlString: currentURL.absoluteString).sorted(by: {$0.count > $1.count }).first
        currentIdentifier = identifier
    }
    
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
}
