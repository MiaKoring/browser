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
    @Environment(\.modelContext) var context
    var showDeleted: Bool = false
    @State var showPopup: Bool = false
    var body: some View {
        HStack {
            ZStack {
                if let data = account.image, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                } else {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.tertiary)
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.trailing, 5)
            VStack(alignment: .leading) {
                if let title = account.title, !title.isEmpty {
                    Text(title)
                        .bold()
                } else {
                    Text(account.service)
                        .bold()
                }
                Text(account.username)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .contextMenu {
            if showDeleted {
                Button("Restore", role: .cancel) {
                    account.restore()
                }
            }
            Button("Delete", role: .destructive) {
                showPopup = true
            }
        }
        .confirmationDialog(showDeleted ? "Deleting this account will remove all corresponding data permanently. You can't undo this action.": "Are you sure you want to delete this Account? It will be restorable for 30 days.", isPresented: $showPopup, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                guard !showDeleted else {
                    account.deleteCorrespondingKeychainData()
                    context.delete(account)
                    return
                }
                account.delete()
            }
        }
    }
}
