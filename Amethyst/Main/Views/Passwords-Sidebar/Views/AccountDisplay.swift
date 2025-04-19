//
//  AccountDisplay.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.03.25.
//

import SwiftUI
import SwiftData
import AmethystAuthenticatorCore

import AuthenticationServices

struct AccountDisplay: View {
    let account: Account
    var context: ModelContext
    @State var showPopup: Bool = false
    @State var isHovered: Bool = false
    var interactionDisabled: Bool = false
    @State var isEditButtonHovered: Bool = false
    @State var edit: Bool = false
    @State var isTotpButtonHovered: Bool = false
    @State var highlightTOTPCopy: Bool = false
    var body: some View {
        HStack {
            ZStack {
                if let data = account.image, let uiImage = NSImage(data: data) {
                    Image(nsImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.tertiary.opacity(0.5))
                        .frame(width: 40, height: 40)
                        .overlay {
                            {
                                if let title = account.title, !title.isEmpty {
                                    Text("\(title.first?.uppercased() ?? "")")
                                } else if let url = URL(string: account.service) {
                                    Text(url.host()?.first?.uppercased() ?? account.service.first?.uppercased() ?? "")
                                } else {
                                    Text(account.service.first?.uppercased() ?? "")
                                }
                            }()
                                .font(.title)
                        }
                }
            }
            .padding(.trailing, 5)
            VStack(alignment: .leading) {
                if let title = account.title, !title.isEmpty {
                    Text(title)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .bold()
                } else {
                    Text(account.service)
                        .bold()
                }
                Text(account.username)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isHovered {
                HStack {
                    if account.totp {
                        Button {
                            withAnimation {
                                highlightTOTPCopy = true
                            }
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(account.getCurrentTOTPCode() ?? "", forType: .string)
                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                                withAnimation {
                                    highlightTOTPCopy = false
                                }
                                timer.invalidate()
                            }
                        } label: {
                            Image(systemName: highlightTOTPCopy ? "checkmark.circle.fill": "key.viewfinder")
                                .font(.title2)
                                .foregroundStyle(.gray.opacity(0.8))
                                .background(isTotpButtonHovered && !highlightTOTPCopy ? .gray.opacity(0.2): .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                        .buttonStyle(.plain)
                        .onHover { hovering in
                            isTotpButtonHovered = hovering
                        }
                    }
                    Button {
                        edit = true
                    } label: {
                        Image(systemName: "pencil.circle\(isEditButtonHovered ? ".fill": "")")
                            .font(.title2)
                            .foregroundStyle(.gray.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        isEditButtonHovered = hovering
                    }
                }
            }
        }
        .contextMenu {
            if !interactionDisabled {
                Button("Delete", role: .destructive) {
                    showPopup = true
                }
            }
        }
        .confirmationDialog("Are you sure you want to delete this Account? It will be restorable for 30 days.", isPresented: $showPopup, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                account.delete()
            }
        }
        .onHover { hovering in
            isHovered = hovering
        }
        .sheet(isPresented: $edit) {
            AccountDetailEdit(account: account, create: false, accountAfterCreation: nil, context: context) {
                edit = false
            }
        }
    }
}
