//
//  AppDelegate.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 30.11.24.
//
import SwiftData
import SwiftUI
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var appViewModel: AppViewModel?
    var contentViewModel: ContentViewModel?
    var contentViewModel2: ContentViewModel?
    var contentViewModel3: ContentViewModel?
    
    func configure(appViewModel: AppViewModel, contentViewModel: ContentViewModel, contentViewModel2: ContentViewModel, contentViewModel3: ContentViewModel) {
        self.appViewModel = appViewModel
        self.contentViewModel = contentViewModel
        self.contentViewModel2 = contentViewModel2
        self.contentViewModel3 = contentViewModel3
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        print("Appviewmodel is nil: \(appViewModel == nil)")
        if let appViewModel {
            CDTabController.clear()
            
            if appViewModel.displayedWindows.contains("window1") {
                if let contentViewModel {
                    insertTo(valuesOf: contentViewModel, id: "window1")
                }
            }
            if appViewModel.displayedWindows.contains("window2") {
                if let contentViewModel2 {
                    insertTo(valuesOf: contentViewModel2, id: "window2")
                }
            }
            if appViewModel.displayedWindows.contains("window3") {
                if let contentViewModel3 {
                    insertTo(valuesOf: contentViewModel3, id: "window3")
                }
            }
            print("presave")
            print(CDTabController.shared.container.viewContext.hasChanges)
            CDTabController.save()
            print("postsave")
            print(CDTabController.shared.container.viewContext.hasChanges)
        }
        
        return .terminateNow
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("applicationLaunched")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let window1Count = CDTabController.fetchCount(NSPredicate(format: "windowID == %@", "window1"))
            let window2Count = CDTabController.fetchCount(NSPredicate(format: "windowID == %@", "window2"))
            let window3Count = CDTabController.fetchCount(NSPredicate(format: "windowID == %@", "window3"))
            if let appViewModel = self.appViewModel, let open = appViewModel.openWindowByID {
                if window1Count > 0 {
                    open("window1")
                }
                if window2Count > 0 {
                    open("window2")
                }
                if window3Count > 0 {
                    open("window3")
                }
            }
        }
    }
    func application(_ application: NSApplication, open urls: [URL]) {
        print("urls opened")
        for url in urls {
            if let openWindow = appViewModel?.openWindow {
                openWindow(url)
            } else {
                print("failed")
            }
        }
    }
    
    
    private func insertTo(valuesOf values: ContentViewModel, id: String) {
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

