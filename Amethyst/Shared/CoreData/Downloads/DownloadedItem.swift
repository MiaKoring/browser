//
//  SavedTab.swift
//  Amethyst Project
//
//  Created by Mia Koring on 17.04.25.
//
import Foundation
import CoreData

@objc(DownloadedItem)
public class DownloadedItem: NSManagedObject {
    convenience init() {
        self.init(context: CDDownloadsController.shared.container.viewContext)
        self.itemID = UUID()
    }
}
