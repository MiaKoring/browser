//
//  HeaderSection.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 11.03.25.
//
import SwiftUI
import AmethystAuthenticatorCore

struct HeaderSection: View {
    @Bindable var account: Account
    @Binding var title: String
    @Binding var username: String
    var editable = true
    
    var body: some View {
        HStack {
            if let data = account.image, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.secondary)
                    .frame(width: 40, height: 40)
            }
            VStack(alignment: .leading) {
                TextField(!account.service.isEmpty ? account.service: "Website", text: $title)
                    .font(.title3)
                    .bold()
                    .disabled(!editable)
                if let edited = account.editedAt {
                    Text("Last modified at \(edited.formatted(date: .numeric, time: .omitted))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        HStack {
            Text("User Name")
            Spacer()
            if editable {
                TextField("User Name", text: $username)
                    .multilineTextAlignment(.trailing)
                    .disabled(!editable)
            } else {
                Menu {
                    Button("Copy Username") {
                        UIPasteboard.general.string = account.username
                    }
                } label: {
                    Text(username)
                        .foregroundStyle(.secondary)
                }
                .menuStyle(.button)
                .buttonStyle(.plain)
            }
        }
    }
}
