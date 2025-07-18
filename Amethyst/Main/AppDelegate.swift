//
//  AppDelegate.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 30.11.24.
//
import SwiftData
import SwiftUI
import WebKit
import OSLog

class AppDelegate: NSObject, NSApplicationDelegate {
    var appViewModel: AppViewModel?
    private static var logger = Logger(subsystem: AmethystApp.subSystem, category: "AppDelegate")
    
    static let settingsGroupID: String = {
        guard let teamID = Bundle.main.object(forInfoDictionaryKey: "TeamID") as? String else { fatalError("TeamID not found")}
        return "\(teamID)group.de.touchthegrass.Amethyst.Index"
    }()
    
    func configure(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let appViewModel else { return .terminateNow }
        CDTabController.clear()
        
        for contentViewModel in appViewModel.displayedWindows.values {
            insert(valuesOf: contentViewModel, id: contentViewModel.id)
        }
        
        Self.logger.info("about to save tab changes")
        Self.logger.info("Container has changes: \(CDTabController.shared.container.viewContext.hasChanges)")
        CDTabController.save()
        Self.logger.info("tabs saved")
        Self.logger.info("Container has changes after saving: \(CDTabController.shared.container.viewContext.hasChanges)")
        return .terminateNow
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("applicationLaunched")
        //TODO: update to restore tabs again
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let window1Count = CDTabController.fetchCount(NSPredicate(format: "windowID == %@", "window1"))
            let window2Count = CDTabController.fetchCount(NSPredicate(format: "windowID == %@", "window2"))
            let window3Count = CDTabController.fetchCount(NSPredicate(format: "windowID == %@", "window3"))
            
            if let appViewModel = self.appViewModel, let open = appViewModel.openWindowByID {
                if window1Count > 0 { open("window1") }
                if window2Count > 0 { open("window2") }
                if window3Count > 0 { open("window3") }
            }
        }*/
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            if let openWindow = appViewModel?.openWindow {
                openWindow(url)
            } else {
                Self.logger.error("failed to open url")
            }
        }
    }
    
    private func insert(valuesOf values: ContentViewModel, id: String) {
        for i in 0..<values.tabs.count {
            let tab = values.tabs[i]
            
            let newTab = SavedTab()
            newTab.tabID = tab.id
            newTab.sortingID = Int16(i)
            newTab.url = tab.webViewModel.currentURL
            newTab.windowID = id
            
            CDTabController.insertSavedTab(newTab)
        }
    }
    
}

