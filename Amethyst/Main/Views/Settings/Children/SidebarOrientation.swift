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
            ForEach(SidebarOrientations.allCases, id: \.hashValue) { orientation in
                VStack {
                    orientation.image
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            trailingTabs = orientation.isTabTrailing
                        }
                        .if(trailingTabs == orientation.isTabTrailing) { view in
                            view.shadow(color: .purple, radius: 20, y: 25)
                        }
                }
            }
        }
    }
}
