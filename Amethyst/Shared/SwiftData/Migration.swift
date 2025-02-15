//
//  TabMigration.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 29.11.24.
//

import SwiftData

enum TabMigration: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SavedTabSchemaV0_1.self, SavedTabSchemaV0_1_1.self, SavedTabSchemaV0_1_2.self, SavedTabSchemaV0_1_3.self, SavedTabSchemaV0_1_4.self, SavedTabSchemaV0_1_5.self, ModelSchemaV0_1_6.self, ModelSchemaV0_1_7.self, ModelSchemaV0_1_8.self, ModelSchemaV0_1_9.self]
    }
    static var stages: [MigrationStage] = [v0_1Tov0_1_1, v0_1_1Tov0_1_2, v0_1_2Tov0_1_3, v0_1_3Tov0_1_4, v0_1_4Tov0_1_5, v0_1_5Tov0_1_6, v0_1_6Tov0_1_7, v0_1_7Tov0_1_8, v0_1_8Tov0_1_9]
    
    static var v0_1_8Tov0_1_9: MigrationStage = MigrationStage.custom(
        fromVersion: ModelSchemaV0_1_8.self,
        toVersion: ModelSchemaV0_1_9.self,
        willMigrate: { context in
            let old = try context.fetch(FetchDescriptor<ModelSchemaV0_1_8.DownloadedItem>())
            for one in old {
                context.delete(one)
            }
        },
        didMigrate: nil)
    
    static var v0_1_7Tov0_1_8: MigrationStage = MigrationStage.custom(fromVersion: ModelSchemaV0_1_7.self, toVersion: ModelSchemaV0_1_8.self, willMigrate: { context in
        let old = try context.fetch(FetchDescriptor<ModelSchemaV0_1_7.DownloadedItem>())
        
        for oldDownload in old {
            context.delete(oldDownload)
            var new = ModelSchemaV0_1_8.DownloadedItem(bookmark: oldDownload.bookmark)
            context.insert(new)
        }
    }, didMigrate: nil)
    
    static var v0_1_6Tov0_1_7: MigrationStage = MigrationStage.custom(fromVersion: ModelSchemaV0_1_6.self, toVersion: ModelSchemaV0_1_7.self, willMigrate: { context in }, didMigrate: nil)
    
    static var v0_1_5Tov0_1_6: MigrationStage = MigrationStage.custom(
        fromVersion: SavedTabSchemaV0_1_5.self,
        toVersion: ModelSchemaV0_1_6.self,
        willMigrate: { context in
        }, didMigrate: nil)
    
    static var v0_1_4Tov0_1_5: MigrationStage = MigrationStage.custom(
        fromVersion: SavedTabSchemaV0_1_4.self,
        toVersion: SavedTabSchemaV0_1_5.self,
        willMigrate: { context in
            let items = try context.fetch(FetchDescriptor<SavedTabSchemaV0_1_4.HistoryItem>())
            let new = {
                for item in items {
                    context.delete(item)
                    context.insert(SavedTabSchemaV0_1_5.HistoryItem(id: item.id, time: item.time, url: item.url, title: nil))
                }
            }
        }, didMigrate: nil)
    
    static var v0_1_3Tov0_1_4: MigrationStage = MigrationStage.custom(
        fromVersion: SavedTabSchemaV0_1_3.self,
        toVersion: SavedTabSchemaV0_1_4.self,
        willMigrate: { context in
        }, didMigrate: nil)
    
    static var v0_1_2Tov0_1_3: MigrationStage = MigrationStage.custom(
        fromVersion: SavedTabSchemaV0_1_2.self,
        toVersion: SavedTabSchemaV0_1_3.self,
        willMigrate: { context in
            let tabs = try context.fetch(FetchDescriptor<SavedTabSchemaV0_1_2.SavedTab>())
            let new = {
                for tab in tabs {
                    context.delete(tab)
                    context.insert(SavedTabSchemaV0_1_3.SavedTab(id: tab.id, sortingID: tab.sortingID, url: tab.url, windowID: tab.windowID, backForwardList: []))
                }
            }
        }, didMigrate: nil)
    
    static var v0_1_1Tov0_1_2: MigrationStage = MigrationStage.custom(
        fromVersion: SavedTabSchemaV0_1_1.self,
        toVersion: SavedTabSchemaV0_1_2.self,
        willMigrate: { context in
            let tabs = try context.fetch(FetchDescriptor<SavedTabSchemaV0_1_1.SavedTab>())
            let new = {
                for tab in tabs {
                    context.delete(tab)
                    context.insert(SavedTabSchemaV0_1_2.SavedTab(id: tab.id, sortingID: tab.sortingID, url: tab.url, windowID: tab.windowID ?? "window1", backList: [], forwardList: []))
                }
            }
        }, didMigrate: nil)
    
    static var v0_1Tov0_1_1: MigrationStage = MigrationStage.custom(
        fromVersion: SavedTabSchemaV0_1.self,
        toVersion: SavedTabSchemaV0_1_1.self,
        willMigrate: { context in
            let tabs = try context.fetch(FetchDescriptor<SavedTabSchemaV0_1.SavedTab>())
            let new = {
                for tab in tabs {
                    context.delete(tab)
                    context.insert(SavedTabSchemaV0_1_1.SavedTab(id: tab.id, sortingID: tab.sortingID, url: tab.url, windowID: "window1"))
                }
            }
    }, didMigrate: nil)
}
