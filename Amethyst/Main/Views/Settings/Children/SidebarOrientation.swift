//
//  SidebarOrientation.swift
//  Amethyst Project
//
//  Created by Mia Koring on 04.06.25.
//
import SwiftUI



/// A view that allows the user to select the orientation for the sidebar.
///
/// The user can choose between a leading (left) or trailing (right) orientation.
/// The choice is persisted in `UserDefaults` and visually indicated by a shadow on the selected option.
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
                            UDKey.sidebarOrientation.boolValue = orientation.isTabTrailing
                        }
                        .if(trailingTabs == orientation.isTabTrailing) { view in
                            view.shadow(color: .purple, radius: 20, y: 25)
                        }
                }
            }
        }
    }
}
