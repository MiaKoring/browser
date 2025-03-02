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
    
    func updateDisplayedItems() {
        let active = appViewModel.downloadManager?.activeDownloads.prefix(4).map { item in
            DownloadItem(name: item.value.targetURL.lastPathComponent, dateCreated: Date.now.timeIntervalSinceReferenceDate, progress: item.value.progress, url: nil, icon: Image(nsImage: NSWorkspace.shared.icon(for: .init(item.value.targetURL.pathExtension) ?? .data)))
        }
        var newest: [DownloadItem] = []
        
        let newestDownloadedItems = downloadedItems.filter({$0.createdAt > Date.now.timeIntervalSinceReferenceDate - 3600 * 24 * 7}).prefix(4)
        for item in newestDownloadedItems {
            var bookmarkDataIsStale: Bool = false
            guard let data = Data(base64Encoded: item.bookmark), let url = try? URL(resolvingBookmarkData: data, options: .withSecurityScope, bookmarkDataIsStale: &bookmarkDataIsStale) else {
                print("couldn't get URL")
                context.delete(item)
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
            
            guard !FileManager.default.isInTrash(url), let ressourceValues = try? url.resourceValues(forKeys: [.nameKey, .typeIdentifierKey]), let name = ressourceValues.name, let typeIdentifier = ressourceValues.typeIdentifier else {
                print("failed to get ressource values")
                context.delete(item)
                continue
            }
            newest.append(DownloadItem(name: name, dateCreated: item.createdAt, progress: nil, url: url, icon: Image(nsImage: NSWorkspace.shared.icon(for: .init(typeIdentifier) ?? .data))))
            
            
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

extension FileManager {
    public func isInTrash(_ file: URL) -> Bool {
        var relationship: URLRelationship = .other
        try? getRelationship(
            &relationship,
            of: .trashDirectory,
            in: .allDomainsMask,
            toItemAt: file
        )
        return relationship == .contains
    }
}
