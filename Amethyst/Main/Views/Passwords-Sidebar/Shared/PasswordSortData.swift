//
//  PasswordSortData.swift
//  Amethyst Project
//
//  Created by Mia Koring on 16.04.25.
//
import SwiftUI
@Observable
class PasswordSortData {
    var filter: SortFilter = .title
    var ascending: Bool = true
    var triggerSort: Bool = false
}
