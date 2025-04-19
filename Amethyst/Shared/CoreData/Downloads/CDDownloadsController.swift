//
//  CDTabController.swift
//  Amethyst Project
//
//  Created by Mia Koring on 17.04.25.
//

import Foundation
import CoreData

class CDDownloadsController: ObservableObject {
    public static var shared = CDDownloadsController(name: "Downloads")
    var container: NSPersistentContainer
    
    @Published var latestFour = [DownloadedItem]()
    
    init(name: String) {
        container = NSPersistentContainer(name: name)
        container.loadPersistentStores { _, error in
            if let error {
                print("Error initializing CoreData: \(error.localizedDescription)")
            }
        }
        latestFour = fetchLatestFour()
    }
    
    func fetchAll(sortDescriptors: [NSSortDescriptor] = []) -> [DownloadedItem] {
        let request = DownloadedItem.createFetchRequest()
        request.sortDescriptors = sortDescriptors
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error while fetching all SavedTabs: \(error.localizedDescription)")
        }
        return []
    }
    
    func delete(_ item: DownloadedItem) {
        container.viewContext.delete(item)
        save()
        latestFour = fetchLatestFour()
    }
    
    func fetchLatestFour() -> [DownloadedItem] {
        let request = DownloadedItem.createFetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(
                SortDescriptor(\DownloadedItem.createdAt, order: .reverse)
            )
        ]
        request.fetchLimit = 4
        
        do {
            let latest = try container.viewContext.fetch(request)
            return latest
        } catch {
            print("Error while fetching latest DownloadedItems: \(error.localizedDescription)")
        }
        return []
    }
    
    func clearEntity() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadedItem")
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
    
    func insertDownloadedItem(_ item: DownloadedItem) {
        container.viewContext.insert(item)
        save()
        
        latestFour = fetchLatestFour()
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
    
    func fetchCount(_ predicate: Predicate<DownloadedItem>) -> Int {
        let request = DownloadedItem.createFetchRequest()
        request.predicate = NSPredicate(predicate)
        do {
            return try container.viewContext.count(for: request)
        } catch {
            print("Error while fetching count with Predicate")
        }
        return 0
    }
    
}

extension CDDownloadsController {
    static func fetchAll() -> [DownloadedItem] {
        CDDownloadsController.shared.fetchAll()
    }
    
    static func save() {
        CDDownloadsController.shared.save()
    }
    
    static func insert(_ item: DownloadedItem) {
        CDDownloadsController.shared.insertDownloadedItem(item)
    }
    
    static func clear() {
        CDDownloadsController.shared.clearEntity()
    }
    
    static func fetchCount(_ predicate: Predicate<DownloadedItem>) -> Int {
        CDDownloadsController.shared.fetchCount(predicate)
    }
    
    static func delete(_ item: DownloadedItem) {
        CDDownloadsController.shared.delete(item)
    }
    
}
