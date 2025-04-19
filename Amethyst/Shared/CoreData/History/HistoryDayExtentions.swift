//
//  HistoryDayExtentions.swift
//  Amethyst Project
//
//  Created by Mia Koring on 17.04.25.
//

import Foundation
import CoreData

extension HistoryDay {
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<HistoryDay> {
        return NSFetchRequest<HistoryDay>(entityName: "HistoryDay")
    }
    
    @NSManaged public var dayID: UUID?
    @NSManaged public var dayTime: Double
    @NSManaged public var historyItems: NSSet?
    
    @nonobjc public func addHistoryItem(_ item: HistoryItem) {
        let mutableItems = self.mutableSetValue(forKey: "historyItems")
        mutableItems.add(item)
        try? self.managedObjectContext?.save()
    }
    
    public var sortedItems: [HistoryItem] {
        (historyItems?.allObjects as? [HistoryItem])?.sorted(by: {
            $0.time > $1.time
        }) ?? []
    }
}

extension HistoryDay: Identifiable {
    public var id: Int { dayID?.hashValue ?? objectID.hashValue }
}
