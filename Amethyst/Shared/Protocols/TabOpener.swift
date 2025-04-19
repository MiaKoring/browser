//
//  TabOpener.swift
//  Amethyst
//
//  Created by Mia Koring on 28.11.24.
//
import SwiftData
import SwiftUI

protocol TabOpener {
    var contentViewModel: ContentViewModel { get }
    var appViewModel: AppViewModel { get }
    //var context: ModelContext { get }
    var dismissWindow: DismissWindowAction { get }
}
