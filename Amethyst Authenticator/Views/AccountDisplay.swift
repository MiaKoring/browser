//
//  AccountDisplay.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.03.25.
//

import SwiftUI
import SwiftData
import AmethystAuthenticatorCore

struct AccountDisplay: View {
    let account: Account
    @Environment(\.modelContext) var context
    var body: some View {
        HStack {
            if let data = account.image, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.tertiary)
                    .frame(width: 30, height: 30)
            }
            VStack(alignment: .leading) {
                if let title = account.title {
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
            Button("Delete") {
                context.delete(account)
            }
        }
    }
}
