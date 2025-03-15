//
//  AccountDisplay.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 12.03.25.
//
import SwiftUI
import AmethystAuthenticatorCore
import AuthenticationServices

struct AccountDisplay: View {
    let account: Account
    let onTap: () -> Void
    var body: some View {
        HStack {
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
                    if let title = account.title {
                        Text(title)
                            .bold()
                            .lineLimit(1)
                    } else {
                        Text(account.service)
                            .bold()
                            .lineLimit(1)
                    }
                    Text(account.username)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
            NavigationLink(destination: AccountDetail(account: account)) {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .font(.title2)
                    .padding(.leading, 10)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 30, height: 30)
        }
        .padding(.trailing, -22)
    }
}
