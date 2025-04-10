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
    
    @State var showImportAlert: Bool = false
    @State var showFileProvider: Bool = false
    @State var fileImportURL: URL?
    @State var error: Error?
    
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
                }
                .padding(.leading, contentViewModel.isPasswordFixed ? 5: 0)
                .padding(.top, contentViewModel.isPasswordFixed ? 5: 0)
                .padding(.horizontal, 3)
                PasswordsContentView()
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
        .sheet(item: $fileImportURL) { url in
            ImportView(url: url)
                .interactiveDismissDisabled()
        }
        .alert("Import Items", isPresented: $showImportAlert) {
            Button("Cancel", role: .cancel) {
                showImportAlert = false
            }
            Button("Import") {
                showFileProvider = true
            }
        }
        .alert("An Error occured", isPresented: .constant(error != nil)) {
            Button("OK", role: .cancel) {
                error = nil
            }
        } message: {
            Text(error?.localizedDescription ?? "")
        }
        .fileImporter(isPresented: $showFileProvider, allowedContentTypes: [.init(filenameExtension: "csv") ?? .spreadsheet]) { result in
            switch result {
            case .success(let url):
                url.startAccessingSecurityScopedResource()
                fileImportURL = url
            case .failure(let error):
                self.error = error
            }
        }
    }
}

