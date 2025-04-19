//
//  CDTabController.swift
//  Amethyst Project
//
//  Created by Mia Koring on 17.04.25.
//

import Foundation
import CoreData

class CDHistoryController: ObservableObject {
    public static var shared = CDHistoryController(name: "History")
    var container: NSPersistentContainer
    
    init(name: String) {
        container = NSPersistentContainer(name: name)
        container.loadPersistentStores { _, error in
            if let error {
                print("Error initializing CoreData: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchAll(sortDescriptors: [NSSortDescriptor] = []) -> [HistoryDay] {
        let request = HistoryDay.createFetchRequest()
        request.includesSubentities = false
        request.sortDescriptors = sortDescriptors
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error while fetching all SavedTabs: \(error.localizedDescription)")
        }
        return []
    }
    
    func delete(_ item: HistoryItem) {
        container.viewContext.delete(item)
    }
    
    func clearEntity() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HistoryDay")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try container.viewContext.execute(batchDeleteRequest)
            save()
        } catch {
            print("An error occured while emptying HistoryDay: \(error.localizedDescription)")
        }
    }
    
    func printKnownEntities() {
        print("Known Entities: \(container.managedObjectModel.entities.compactMap(\.name))")
    }
    
    func insertHistoryDay(_ day: HistoryDay) {
        container.viewContext.insert(day)
    }
    
    func save() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("Error saving CoreData: \(error.localizedDescription)")
            }
        }
    }
    
    func dayFetchCount(_ predicate: Predicate<HistoryDay>) -> Int {
        let request = HistoryDay.createFetchRequest()
        request.predicate = NSPredicate(predicate)
        do {
            return try container.viewContext.count(for: request)
        } catch {
            print("Error while fetching count with Predicate")
        }
        return 0
    }
    
    func itemFetchCount(_ predicate: Predicate<HistoryItem>) -> Int {
        let request = HistoryItem.createFetchRequest()
        request.predicate = NSPredicate(predicate)
        do {
            return try container.viewContext.count(for: request)
        } catch {
            print("Error while fetching count with Predicate")
        }
        return 0
    }
    
    func fetchOrCreateHistoryDay() -> HistoryDay {
        let rangeStart = Calendar.current.startOfDay(for: Date.now).timeIntervalSinceReferenceDate

        let request = HistoryDay.createFetchRequest()
        request.predicate = NSPredicate(
            #Predicate<HistoryDay>{
            $0.dayTime == rangeStart
        })
        request.fetchLimit = 1
        
        guard let day = try? container.viewContext.fetch(request).first else {
            let day = HistoryDay()
            day.dayTime = rangeStart
            insertHistoryDay(day)
            return day
        }
        return day
    }
    
}

extension CDHistoryController {
    static func fetchAll(sortDescriptors: [NSSortDescriptor] = []) -> [HistoryDay] {
        CDHistoryController.shared.fetchAll(sortDescriptors: sortDescriptors)
    }
    
    static func save() {
        CDHistoryController.shared.save()
    }
    
    static func insertHistoryDay(_ day: HistoryDay) {
        CDHistoryController.shared.insertHistoryDay(day)
    }
    
    static func clear() {
        CDHistoryController.shared.clearEntity()
    }
    
    static func dayFetchCount(_ predicate: Predicate<HistoryDay>) -> Int {
        CDHistoryController.shared.dayFetchCount(predicate)
    }
    
    static func itemFetchCount(_ predicate: Predicate<HistoryItem>) -> Int {
        CDHistoryController.shared.itemFetchCount(predicate)
    }
    
    static func delete(_ item: HistoryItem) {
        CDHistoryController.shared.delete(item)
    }
    
    static var currentHistoryDay: HistoryDay {
        CDHistoryController.shared.fetchOrCreateHistoryDay()
    }
    
}
