//
//  UDKey.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//
import SwiftUI

enum UDKey: String, CaseIterable, UserDefaultWrapper {
    case dontAnimateBackground
    case searchEngine
    case wasSetupOnce
    case lastAuthTime
    case sidebarOrientation
    case leadingFixedSidebarWidth
    case trailingFixedSidebarWidth
    case useMacOS26upDesign
}
