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
            if let data = account.image, let uiImage = NSImage(data: data) {
                Image(nsImage: uiImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.secondary)
                    .frame(width: 40, height: 40)
            }
            VStack(alignment: .leading) {
                if editable {
                    HStack {
                        if title.isEmpty {
                            Text("Website")
                                .bold()
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 3)
                        } else {
                            Text("Website")
                                .bold()
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 3)
                                .hidden()
                        }
                        Spacer()
                    }
                    .overlay {
                        TextEditor(text: $title)
                            .lineLimit(1)
                            .textEditorStyle(.plain)
                            .font(.title3)
                            .bold()
                    }
                } else {
                    Text(title)
                        .font(.title3)
                        .bold()
                }
                if let edited = account.editedAt {
                    Text("Last modified at \(edited.formatted(date: .numeric, time: .omitted))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        HStack {
            if editable {
                TextField("User Name", text: $username)
                    .multilineTextAlignment(.trailing)
                    .disabled(!editable)
            } else {
                HStack {
                    Text("Username")
                    CopyOnClickView(text: username, shouldObfuscate: false)
                }
            }
        }
    }
}
