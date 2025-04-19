//
//  SavedTabExtension.swift
//  Amethyst Project
//
//  Created by Mia Koring on 17.04.25.
//

import Foundation
import CoreData

extension DownloadedItem {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<DownloadedItem> {
        return NSFetchRequest<DownloadedItem>(entityName: "DownloadedItem")
    }
    
    @NSManaged public var bookmark: Data?
    @NSManaged public var createdAt: Double
    @NSManaged public var itemID: UUID?
    
}
