//
//  SavedTab.swift
//  Amethyst Project
//
//  Created by Mia Koring on 17.04.25.
//
import Foundation
import CoreData

@objc(HistoryItem)
public class HistoryItem: NSManagedObject {
    convenience init() {
        self.init(context: CDHistoryController.shared.container.viewContext)
        self.itemID = UUID()
    }
}
