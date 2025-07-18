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
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        Self.logger.warning("trying to open url")
        guard let url = urls.first else { return }
        if let appVMopenWindow = appViewModel?.openWindow {
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(5))) {
                appVMopenWindow(url)
            }
        } else {
            Self.logger.error("failed to open url")
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

