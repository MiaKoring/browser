//
//  ShortDownloadOverviewModl.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 09.02.25.
//
import SwiftUI
import SwiftData

struct ShortDownloadOverview {
    @Environment(AppViewModel.self) var appViewModel
    @Environment(\.modelContext) var context
    @State var displayedItems = [DownloadItem]()
    @Query(sort: [SortDescriptor<DownloadedItem>(\.createdAt, order: .reverse)]) var downloadedItems: [DownloadedItem]
    
    struct DownloadItem: Hashable {
        let name: String
        let dateCreated: Double
        let progress: Double?
        let icon: Image
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name + dateCreated.description)
        }
    }
    
    func updateDisplayedItems() {
        print("shouldLoad")
        let active = appViewModel.downloadManager?.activeDownloads.prefix(4).map { item in
            DownloadItem(name: item.value.targetURL.lastPathComponent, dateCreated: Date.now.timeIntervalSinceReferenceDate, progress: item.value.progress, icon: Image(nsImage: NSWorkspace.shared.icon(for: .init(item.value.targetURL.pathExtension) ?? .data)))
        }
        var newest: [DownloadItem] = []
        
        let newestDownloadedItems = downloadedItems.prefix(4)
        
        print("DownloadedItemsCount \(downloadedItems.count)")
        for item in newestDownloadedItems {
            var bookmarkDataIsStale: Bool = false
            guard let data = Data(base64Encoded: item.bookmark), let url = try? URL(resolvingBookmarkData: data, options: .withSecurityScope, bookmarkDataIsStale: &bookmarkDataIsStale) else {
                print("couldn't get URL")
                continue
            }
            guard let activeCount = active?.count, newest.count + activeCount < 4 else { continue }
            if bookmarkDataIsStale, let bookmarkData = try? url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: [.nameKey, .contentTypeKey, .creationDateKey],
                relativeTo: nil
            ) {
                item.bookmark = bookmarkData.base64EncodedString()
            }
            
            guard let ressourceValues = try? url.resourceValues(forKeys: [.nameKey, .typeIdentifierKey]), let name = ressourceValues.name, let typeIdentifier = ressourceValues.typeIdentifier else {
                print("failed to get ressource values")
                continue
            }
            newest.append(DownloadItem(name: name, dateCreated: item.createdAt, progress: nil, icon: Image(nsImage: NSWorkspace.shared.icon(for: .init(typeIdentifier) ?? .data))))
            
            
        }
        newest.sort(by: {
            if $0.dateCreated == $1.dateCreated {
                return $0.name > $1.name
            } else {
                return $0.dateCreated > $1.dateCreated
            }
        })
        newest.insert(contentsOf: active ?? [], at: 0)
        displayedItems = newest
        print(displayedItems)
    }
    
}
