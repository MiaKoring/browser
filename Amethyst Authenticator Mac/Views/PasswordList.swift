//
//  PasswordList.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.03.25.
//

import SwiftUI
import SwiftData
import AmethystAuthenticatorCore

struct PasswordList: View {
    @Query var accounts: [Account]
    @Binding var selectedAccount: Account?
    @State var searchText: String = ""
    @Environment(\.modelContext) var context
    var body: some View {
        List(searchText.isEmpty ? accounts: accounts.filter({
            $0.username.contains(searchText) || $0.service.contains(searchText)
        })) { account in
            HStack {
                if let data = account.image, let nsImage = NSImage(data: data) {
                    Image(nsImage: nsImage)
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
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    do {
                        let account = try Account(service: "amethystbrowser.de", username: "koring.mia@gmail.com", comment: "Test", password: "Test", allAccounts: accounts, strength: 0.7)
                        Task {
                            if let title = try? await Account.getTitle(from: account.service) {
                                account.setTitle(to: title)
                            }
                            if let image = try? await Account.getImage(for: account.service) {
                                account.setImage(to: image)
                            }
                        }
                        context.insert(account)
                    } catch {
                        print(error.localizedDescription)
                    }
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
   
}
