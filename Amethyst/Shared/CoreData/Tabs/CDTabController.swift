//
//  CDTabController.swift
//  Amethyst Project
//
//  Created by Mia Koring on 17.04.25.
//

import Foundation
import CoreData

class CDTabController: ObservableObject {
    public static var shared = CDTabController(name: "Tabs")
    var container: NSPersistentContainer
    
    init(name: String) {
        container = NSPersistentContainer(name: name)
        container.loadPersistentStores { _, error in
            if let error {
                print("Error initializing CoreData: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchAll() -> [SavedTab] {
        let request = SavedTab.createFetchRequest()
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error while fetching all SavedTabs: \(error.localizedDescription)")
        }
        return []
    }
    
    func clearEntity() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedTab")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try container.viewContext.execute(batchDeleteRequest)
            save()
        } catch {
            print("An error occured while emptying SavedTabs: \(error.localizedDescription)")
        }
    }
    
    func printKnownEntities() {
        print("Known Entities: \(container.managedObjectModel.entities.compactMap(\.name))")
    }
    
    func insertSavedTab(_ tab: SavedTab) {
        container.viewContext.insert(tab)
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
    
    func fetchCount(_ predicate: NSPredicate) -> Int {
        let request = SavedTab.createFetchRequest()
        request.predicate = predicate
        do {
            return try container.viewContext.count(for: request)
        } catch {
            print("Error while fetching count with Predicate")
        }
        return 0
    }
    
}

extension CDTabController {
    static func fetchAll() -> [SavedTab] {
        CDTabController.shared.fetchAll()
    }
    
    static func save() {
        CDTabController.shared.save()
    }
    
    static func insertSavedTab(_ tab: SavedTab) {
        CDTabController.shared.insertSavedTab(tab)
    }
    
    static func clear() {
        CDTabController.shared.clearEntity()
    }
    
    static func fetchCount(_ predicate: NSPredicate) -> Int {
        CDTabController.shared.fetchCount(predicate)
    }
    
}
