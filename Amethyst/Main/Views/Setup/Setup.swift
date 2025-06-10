//
//  MeiliSetup.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 06.12.24.
//

import SwiftUI

struct Setup: View {
    @State private var current: SetupStep = .welcome
    @Environment(AppViewModel.self) var appViewModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        BackgroundView(shouldRotate: false) {
            VStack {
                ZStack {
                    ForEach(SetupStep.allCases) { step in
                        step.view(current: $current)
                            .frame(width: 680, height: 380)
                            .if (step != current) { view in
                                view.hidden()
                            }
                            .padding(.top, 10)
                    }
                    .overlay(alignment: .topTrailing) {
                        if current == .whatIs {
                            Button("Skip") {
                                UDKey.wasSetupOnce.boolValue = true
                                dismiss()
                            }
                            .buttonStyle(.borderless)
                            .padding()
                        }
                    }
                    HStack {
                        if current != .welcome {
                            Button {
                                current = current.previous
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title)
                                    .padding(.leading, 5)
                            }
                            .buttonStyle(.borderless)
                        }
                        Spacer()
                        if current != .checkMeiliRunning && current != .welcome {
                            Button {
                                current = current.next
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.title)
                                    .padding(.trailing, 5)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                .frame(height: 380)
            }
            .background() {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.thinMaterial)
            }
            .padding(10)
        }
        .onAppear() {
            ErrorIgnoreManager.addIgnoredURLError("Frame load interrupted")
        }
    }
}

#Preview {
    Setup()
        .frame(width: 700, height: 400)
}
