//
//  TOTPInputView.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 11.03.25.
//

import SwiftUI

struct TOTPInputView: View {
    let completion: (String) -> Void
    @State var totpSecret: String = ""
    var body: some View {
        TextField("Setup Key", text: $totpSecret)
        Button("Use Setup Key") {
            completion(totpSecret)
        }
        .disabled(totpSecret.isEmpty)
    }
}
