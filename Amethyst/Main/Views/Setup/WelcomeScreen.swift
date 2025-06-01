//
//  WelcomeScreen.swift
//  Amethyst Project
//
//  Created by Mia Koring on 01.06.25.
//

import SwiftUI

struct WelcomeScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var current: SetupStep
    var body: some View {
        HStack {
            Image("AmethystLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
            Spacer()
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Welcome to Amethyst,")
                    Text(ProcessInfo.processInfo.fullUserName)
                }
                .font(.system(size: 30, weight: .semibold))
                .padding(.bottom)
                Text("We're glad to have you! Amethyst is designed for a fast, private, and clean browsing experience")
                Text("\nLets continue setting up your experience!")
                Button {
                    current = .welcome.next
                } label: {
                    
                    HStack {
                        Text("Set Up")
                            .padding(.leading, 30)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .padding(.trailing, 15)
                    }
                        .frame(width: 130)
                        .padding(.vertical, 7)
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.myPurple.mix(with: .purple, by: 0.4))
                        }
                        .padding(.top, 40)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 350)
        }
        .padding(50)
    }
}

#Preview {
    @Previewable @State var current: SetupStep = .welcome
    BackgroundView(shouldRotate: false) {
        WelcomeScreen(current: $current)
            .frame(width: 700, height: 400)
            .background() {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.thinMaterial)
            }
            .padding(10)
    }
}
