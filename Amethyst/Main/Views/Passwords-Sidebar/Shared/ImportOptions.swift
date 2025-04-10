//
//  ImportOptions.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 25.03.25.
//

import SwiftUI

class ImportOptions: ObservableObject {
    ///fetch the favicon.ico and title for every account when importing
    @Published var fetchServiceData = true
    ///transfer notes from the csv to the imported accounts
    @Published var transferNotes = true
    ///transfer the title
    @Published var transferTitle = false
    
}
