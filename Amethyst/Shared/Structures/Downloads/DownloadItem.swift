//
//  DownloadItem.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 02.03.25.
//
import SwiftUI

struct DownloadItem: Hashable {
    let name: String
    let dateCreated: Double
    let progress: Progress?
    let url: URL?
    let icon: Image
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name + dateCreated.description)
    }
}
