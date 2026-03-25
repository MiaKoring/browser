//
//  DownloadItem.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 02.03.25.
//
import SwiftUI

struct DownloadItem: Hashable, Observable {
    static func == (lhs: DownloadItem, rhs: DownloadItem) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    let id = UUID()
    let name: String
    let dateCreated: Double
    let url: URL?
    let icon: Image
    var info: DownloadInfo?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name + dateCreated.description)
    }
}
