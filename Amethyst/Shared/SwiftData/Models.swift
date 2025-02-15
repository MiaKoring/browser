//
//  Models.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 29.11.24.
//
import Foundation
import SwiftData
import WebKit

typealias SavedTab = ModelSchemaV0_1_9.SavedTab
typealias BackForwardListItem = ModelSchemaV0_1_9.BackForwardListItem
typealias HistoryItem = ModelSchemaV0_1_9.HistoryItem
typealias HistoryDay = ModelSchemaV0_1_9.HistoryDay
typealias FavouriteItem = ModelSchemaV0_1_9.FavouriteItem
typealias DownloadedItem = ModelSchemaV0_1_9.DownloadedItem

enum ModelSchemaV0_1_9: VersionedSchema {
    static let versionIdentifier: Schema.Version = Schema.Version(0, 1, 9)
    static var models: [any PersistentModel.Type] {
        [SavedTab.self, BackForwardListItem.self, HistoryItem.self, HistoryDay.self, FavouriteItem.self, DownloadedItem.self]
    }
    
    @Model
    final class SavedTab {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var windowID: String
        @Relationship(deleteRule: .cascade)
        var backForwardList: [BackForwardListItem]
        
        init(id: UUID, sortingID: Int, url: URL?, windowID: String, backForwardList: [BackForwardListItem]) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.windowID = windowID
            self.backForwardList = backForwardList
        }
    }
    
    @Model
    final class BackForwardListItem {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var title: String?
        
        init(id: UUID = UUID(), sortingID: Int, url: URL?, title: String?) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.title = title
        }
    }
    
    @Model
    final class HistoryItem {
        var id: UUID = UUID()
        var time: Double
        var url: URL
        var title: String? = nil
        
        init(id: UUID = UUID(), time: Double, url: URL, title: String?) {
            self.id = id
            self.time = time
            self.url = url
            self.title = title
        }
    }
    
    @Model
    final class HistoryDay: Identifiable {
        var id: UUID = UUID()
        var time: Double
        var historyItems: [HistoryItem]
        
        init(time: Double, historyItems: [HistoryItem]) {
            self.time = time
            self.historyItems = historyItems
        }
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
    
    @Model
    final class DownloadedItem: Identifiable {
        var id: UUID = UUID()
        var createdAt: Double
        var bookmark: String
        
        init(bookmark: Data, createdAt: Double) {
            self.bookmark = bookmark.base64EncodedString()
            self.createdAt = createdAt
        }
    }
}

enum ModelSchemaV0_1_8: VersionedSchema {
    static let versionIdentifier: Schema.Version = Schema.Version(0, 1, 8)
    static var models: [any PersistentModel.Type] {
        [SavedTab.self, BackForwardListItem.self, HistoryItem.self, HistoryDay.self, FavouriteItem.self, DownloadedItem.self]
    }
    
    @Model
    final class SavedTab {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var windowID: String
        @Relationship(deleteRule: .cascade)
        var backForwardList: [BackForwardListItem]
        
        init(id: UUID, sortingID: Int, url: URL?, windowID: String, backForwardList: [BackForwardListItem]) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.windowID = windowID
            self.backForwardList = backForwardList
        }
    }
    
    @Model
    final class BackForwardListItem {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var title: String?
        
        init(id: UUID = UUID(), sortingID: Int, url: URL?, title: String?) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.title = title
        }
    }
    
    @Model
    final class HistoryItem {
        var id: UUID = UUID()
        var time: Double
        var url: URL
        var title: String? = nil
        
        init(id: UUID = UUID(), time: Double, url: URL, title: String?) {
            self.id = id
            self.time = time
            self.url = url
            self.title = title
        }
    }
    
    @Model
    final class HistoryDay: Identifiable {
        var id: UUID = UUID()
        var time: Double
        var historyItems: [HistoryItem]
        
        init(time: Double, historyItems: [HistoryItem]) {
            self.time = time
            self.historyItems = historyItems
        }
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
    
    @Model
    final class DownloadedItem: Identifiable {
        var id: UUID = UUID()
        var createdAt: Date
        var bookmark: Data
        
        init(bookmark: Data, createdAt: Date = Date()) {
            self.bookmark = bookmark
            self.createdAt = createdAt
        }
    }
}

enum ModelSchemaV0_1_7: VersionedSchema {
    static let versionIdentifier: Schema.Version = Schema.Version(0, 1, 7)
    static var models: [any PersistentModel.Type] {
        [SavedTab.self, BackForwardListItem.self, HistoryItem.self, HistoryDay.self, FavouriteItem.self, DownloadedItem.self]
    }
    
    @Model
    final class SavedTab {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var windowID: String
        @Relationship(deleteRule: .cascade)
        var backForwardList: [BackForwardListItem]
        
        init(id: UUID, sortingID: Int, url: URL?, windowID: String, backForwardList: [BackForwardListItem]) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.windowID = windowID
            self.backForwardList = backForwardList
        }
    }
    
    @Model
    final class BackForwardListItem {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var title: String?
        
        init(id: UUID = UUID(), sortingID: Int, url: URL?, title: String?) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.title = title
        }
    }
    
    @Model
    final class HistoryItem {
        var id: UUID = UUID()
        var time: Double
        var url: URL
        var title: String? = nil
        
        init(id: UUID = UUID(), time: Double, url: URL, title: String?) {
            self.id = id
            self.time = time
            self.url = url
            self.title = title
        }
    }
    
    @Model
    final class HistoryDay: Identifiable {
        var id: UUID = UUID()
        var time: Double
        var historyItems: [HistoryItem]
        
        init(time: Double, historyItems: [HistoryItem]) {
            self.time = time
            self.historyItems = historyItems
        }
    }
    
    @Model
    final class FavouriteItem {
        var id: UUID = UUID()
        var url: URL
        var title: String? = nil
        
        init(id: UUID = UUID(), url: URL, title: String?) {
            self.id = id
            self.url = url
            self.title = title
        }
    }
    
    @Model
    final class DownloadedItem {
        var id: UUID = UUID()
        var bookmark: Data
        
        init(bookmark: Data) {
            self.bookmark = bookmark
        }
    }
}

enum ModelSchemaV0_1_6: VersionedSchema {
    static let versionIdentifier = Schema.Version(0, 1, 6)
    static var models: [any PersistentModel.Type] {
        [SavedTab.self, BackForwardListItem.self, HistoryItem.self, HistoryDay.self, FavouriteItem.self]
    }
    
    @Model
    final class SavedTab {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var windowID: String
        @Relationship(deleteRule: .cascade)
        var backForwardList: [BackForwardListItem]
        
        init(id: UUID, sortingID: Int, url: URL?, windowID: String, backForwardList: [BackForwardListItem]) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.windowID = windowID
            self.backForwardList = backForwardList
        }
    }
    
    @Model
    final class BackForwardListItem {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var title: String?
        
        init(id: UUID = UUID(), sortingID: Int, url: URL?, title: String?) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.title = title
        }
    }
    
    @Model
    final class HistoryItem {
        var id: UUID = UUID()
        var time: Double
        var url: URL
        var title: String? = nil
        
        init(id: UUID = UUID(), time: Double, url: URL, title: String?) {
            self.id = id
            self.time = time
            self.url = url
            self.title = title
        }
    }
    
    @Model
    final class HistoryDay: Identifiable {
        var id: UUID = UUID()
        var time: Double
        var historyItems: [HistoryItem]
        
        init(time: Double, historyItems: [HistoryItem]) {
            self.time = time
            self.historyItems = historyItems
        }
    }
    
    @Model
    final class FavouriteItem {
        var id: UUID = UUID()
        var url: URL
        var title: String? = nil
        
        init(id: UUID = UUID(), url: URL, title: String?) {
            self.id = id
            self.url = url
            self.title = title
        }
    }
}

enum SavedTabSchemaV0_1_5: VersionedSchema {
    static let versionIdentifier = Schema.Version(0, 1, 5)
    static var models: [any PersistentModel.Type] {
        [SavedTab.self, BackForwardListItem.self, HistoryItem.self, HistoryDay.self]
    }
    
    @Model
    final class SavedTab {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var windowID: String
        @Relationship(deleteRule: .cascade)
        var backForwardList: [BackForwardListItem]
        
        init(id: UUID, sortingID: Int, url: URL?, windowID: String, backForwardList: [BackForwardListItem]) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.windowID = windowID
            self.backForwardList = backForwardList
        }
    }
    
    @Model
    final class BackForwardListItem {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var title: String?
        
        init(id: UUID = UUID(), sortingID: Int, url: URL?, title: String?) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.title = title
        }
    }
    
    @Model
    final class HistoryItem {
        var id: UUID = UUID()
        var time: Double
        var url: URL
        var title: String? = nil
        
        init(id: UUID = UUID(), time: Double, url: URL, title: String?) {
            self.id = id
            self.time = time
            self.url = url
            self.title = title
        }
    }
    
    @Model
    final class HistoryDay: Identifiable {
        var id: UUID = UUID()
        var time: Double
        var historyItems: [HistoryItem]
        
        init(time: Double, historyItems: [HistoryItem]) {
            self.time = time
            self.historyItems = historyItems
        }
    }
}

enum SavedTabSchemaV0_1_4: VersionedSchema {
    static let versionIdentifier = Schema.Version(0, 1, 4)
    static var models: [any PersistentModel.Type] {
        [SavedTab.self, BackForwardListItem.self, HistoryItem.self, HistoryDay.self]
    }
    
    @Model
    final class SavedTab {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var windowID: String
        @Relationship(deleteRule: .cascade)
        var backForwardList: [BackForwardListItem]
        
        init(id: UUID, sortingID: Int, url: URL?, windowID: String, backForwardList: [BackForwardListItem]) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.windowID = windowID
            self.backForwardList = backForwardList
        }
    }
    
    @Model
    final class BackForwardListItem {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var title: String?
        
        init(id: UUID = UUID(), sortingID: Int, url: URL?, title: String?) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.title = title
        }
    }
    
    @Model
    final class HistoryItem {
        var id: UUID = UUID()
        var time: Double
        var url: URL
        var httpHeaderFields: [String: String]?
        var httpMethod: String?
        var httpBody: Data?
        
        init(id: UUID = UUID(), time: Double, url: URL, httpHeaderFields: [String : String]?, httpMethod: String?, httpBody: Data? = nil) {
            self.id = id
            self.time = time
            self.url = url
            self.httpHeaderFields = httpHeaderFields
            self.httpMethod = httpMethod
            self.httpBody = httpBody
        }
    }
    
    @Model
    final class HistoryDay: Identifiable {
        var id: UUID = UUID()
        var time: Double
        var historyItems: [HistoryItem]
        
        init(time: Double, historyItems: [HistoryItem]) {
            self.time = time
            self.historyItems = historyItems
        }
    }
}

enum SavedTabSchemaV0_1_3: VersionedSchema {
    static let versionIdentifier = Schema.Version(0, 1, 3)
    static var models: [any PersistentModel.Type] {
        [SavedTab.self, BackForwardListItem.self]
    }
    
    @Model
    final class SavedTab {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var windowID: String
        @Relationship(deleteRule: .cascade)
        var backForwardList: [BackForwardListItem]
        
        init(id: UUID, sortingID: Int, url: URL?, windowID: String, backForwardList: [BackForwardListItem]) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.windowID = windowID
            self.backForwardList = backForwardList
        }
    }
    
    @Model
    final class BackForwardListItem {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var title: String?
        
        init(id: UUID = UUID(), sortingID: Int, url: URL?, title: String?) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.title = title
        }
    }
}

enum SavedTabSchemaV0_1_2: VersionedSchema {
    static let versionIdentifier = Schema.Version(0, 1, 2)
    static var models: [any PersistentModel.Type] {
        [SavedTab.self, BackForwardListItem.self]
    }
    
    @Model
    final class SavedTab {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var windowID: String
        var backList: [BackForwardListItem]?
        var forwardList: [BackForwardListItem]?
        
        init(id: UUID, sortingID: Int, url: URL?, windowID: String, backList: [BackForwardListItem], forwardList: [BackForwardListItem]) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.windowID = windowID
            self.backList = backList
            self.forwardList = forwardList
        }
    }
    
    @Model
    final class BackForwardListItem {
        var id: UUID
        var sortingID: Int
        var url: URL
        
        init(id: UUID = UUID(), sortingID: Int, url: URL) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
        }
    }
}

enum SavedTabSchemaV0_1_1: VersionedSchema {
    static let versionIdentifier = Schema.Version(0, 1, 1)
    static var models: [any PersistentModel.Type] {
        [SavedTab.self]
    }
    
    @Model
    final class SavedTab {
        var id: UUID
        var sortingID: Int
        var url: URL?
        var windowID: String?
        
        init(id: UUID, sortingID: Int, url: URL?, windowID: String) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
            self.windowID = windowID
        }
    }
}

enum SavedTabSchemaV0_1: VersionedSchema {
    static let versionIdentifier = Schema.Version(0, 1, 0)
    static var models: [any PersistentModel.Type] {
        [SavedTab.self]
    }
    
    @Model
    final class SavedTab {
        var id: UUID
        var sortingID: Int
        var url: URL?
        
        init(id: UUID, sortingID: Int, url: URL?) {
            self.id = id
            self.sortingID = sortingID
            self.url = url
        }
    }
}

