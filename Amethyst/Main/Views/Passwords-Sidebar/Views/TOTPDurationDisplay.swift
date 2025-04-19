//
//  TOTPDurationDisplay.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 15.03.25.
//

import SwiftUI

struct TOTPDurationDisplay: View {
    @State var remainingTime: Double = 0.0
    @State var timer: Timer?
    var body: some View {
        ProgressView(value: remainingTime)
            .progressViewStyle(.linear)
            .onAppear {
                remainingTime = Double(AccountDetail.getRemainingTOTPTime()) / 30.0
                timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            remainingTime = Double(AccountDetail.getRemainingTOTPTime()) / 30.0
                        }
                    }
                }
            }
    }
}
