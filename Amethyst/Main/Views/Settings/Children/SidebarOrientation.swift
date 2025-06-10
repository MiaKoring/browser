//
//  SidebarOrientation.swift
//  Amethyst Project
//
//  Created by Mia Koring on 04.06.25.
//
import SwiftUI


struct SidebarOrientation: View {
    @AppStorage(UDKey.sidebarOrientation.rawValue) var trailingTabs: Bool = false
    var body: some View {
        HStack {
            VStack {
                Image(.leadingTabs)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        trailingTabs = false
                    }
                    .if(!trailingTabs) { view in
                        view.shadow(color: .purple, radius: 20, y: 25)
                    }
            }
            VStack {
                Image(.trailingTabs)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        trailingTabs = true
                    }
                    .if(trailingTabs) { view in
                        view.shadow(color: .purple, radius: 20, y: 25)
                    }
            }
        }
    }
}
