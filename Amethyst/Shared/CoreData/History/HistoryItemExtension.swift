//
//  SavedTabExtension.swift
//  Amethyst Project
//
//  Created by Mia Koring on 17.04.25.
//


import Foundation
import CoreData

extension HistoryItem {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<HistoryItem> {
        return NSFetchRequest<HistoryItem>(entityName: "HistoryItem")
    }
    
    @NSManaged public var itemID: UUID?
    @NSManaged public var time: Double
    @NSManaged public var title: String?
    @NSManaged public var url: URL?
    @NSManaged public weak var day: HistoryDay?
}

extension HistoryItem: Identifiable {
    public var id: Int { itemID?.hashValue ?? objectID.hashValue }
}
