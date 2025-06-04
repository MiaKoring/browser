//
//  SidebarOrientation.swift
//  Amethyst Project
//
//  Created by Mia Koring on 04.06.25.
//
import SwiftUI


struct SidebarOrientation: View {
    @State var trailingTabs: Bool = UDKey.sidebarOrientation.boolValue
    var body: some View {
        HStack {
            VStack {
                Image(.leadingTabs)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        trailingTabs = false
                        UDKey.sidebarOrientation.boolValue = false
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
                        UDKey.sidebarOrientation.boolValue = true
                    }
                    .if(trailingTabs) { view in
                        view.shadow(color: .purple, radius: 20, y: 25)
                    }
            }
        }
    }
}
