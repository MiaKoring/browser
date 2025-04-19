//
//  TabMigration.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 29.11.24.
//

import SwiftData

enum TabMigration: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [ModelSchemaV0_1_9.self]
    }
    static var stages: [MigrationStage] = []
    
    
}
