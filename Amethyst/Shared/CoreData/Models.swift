//
//  Models.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 29.11.24.
//
import Foundation
import SwiftData
import WebKit

typealias FavouriteItem = ModelSchemaV0_1_9.FavouriteItem

enum ModelSchemaV0_1_9: VersionedSchema {
    static let versionIdentifier: Schema.Version = Schema.Version(0, 1, 9)
    static var models: [any PersistentModel.Type] {
        [ FavouriteItem.self]
    }
    
    
    @Model
    final class FavouriteItem {
        var id: UUID
        var url: URL
        var title: String? = nil
        
        init(id: UUID = UUID(), url: URL, title: String?) {
            self.id = id
            self.url = url
            self.title = title
        }
    }
}
