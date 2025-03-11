//
//  ContentView.swift
//  Amethyst Authenticator
//
//  Created by Mia Koring on 07.03.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            HomeViewIpad()
        } else {
            HomeView()
        }
    }
}

#Preview {
    ContentView()
}
