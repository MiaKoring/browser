//
//  IgnoredErrorsView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 07.02.25.
//

import SwiftUI

struct IgnoredErrorsView: View {
    @State var ignoredErrors = [String]()
    @State var selectedErrors = [String]()
    
    var body: some View {
        VStack(alignment: .leading) {
            Button {
                for selectedError in selectedErrors {
                    ErrorIgnoreManager.removeIgnoredURLError(selectedError)
                }
            } label: {
                Label("Stop ignoring selected Errors", systemImage: "trash")
            }
            .buttonStyle(.accessoryBar)
            .padding(.top, 10)
            .padding(.leading, 10)
            List($ignoredErrors, id: \.self) { error in
                HStack {
                    Text(selectedErrors.contains(error.wrappedValue) ? Image(systemName: "inset.filled.square"): Image(systemName: "square"))
                        .onTapGesture {
                            if selectedErrors.contains(error.wrappedValue) {
                                selectedErrors.removeAll(where: {$0 == error.wrappedValue})
                                return
                            }
                            selectedErrors.append(error.wrappedValue)
                        }
                    Text(error.wrappedValue)
                }
            }
            .onAppear() {
                ignoredErrors = IgnoredError.ignoredURLErrors.all
            }
        }
    }
}
