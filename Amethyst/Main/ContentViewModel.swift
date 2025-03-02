//
//  ContentViewModel.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//
import SwiftUI
import SwiftData
import WebKit
import AuthenticationServices

@Observable
class ContentViewModel: NSObject, ObservableObject {
    let id: String
    var triggerNewTab: Bool = false
    var isSidebarShown: Bool = false
    var isSidebarFixed: Bool = false
    var currentTab: UUID?
    var tabs: [ATab] = []
    var wkProcessPool = WKProcessPool()
    var blockNotification: Bool = false
    var triggerRestoredHistory: Bool = false
    var showInlineSearch: Bool = false
    var lastInlineQuery: String = ""
    var isLoaded: Bool = false
    var showHistory: Bool = false
    
    init(id: String) {
        self.id = id
    }
    
    func handleClose() {
        guard let index = tabs.firstIndex(where: {$0.id == currentTab}) else { return }
        if tabs.count > 1 {
            let before = tabs[max(0, index - 1)].id
            let after = tabs[min(tabs.count - 1, index + 1)].id
            currentTab = before == currentTab ? after : before
        } else {
            currentTab = nil
        }
        withAnimation(.linear(duration: 0.2)) {
            Task {
                await tabs[index].webViewModel.deinitialize()
            }
            tabs.remove(at: index)
        }
    }
    
    func tabFor(id: UUID?) -> ATab? {
        return tabs.first(where: {$0.id == id})
    }
}
struct ContentView {
    @Environment(AppViewModel.self) var appViewModel: AppViewModel
    @Environment(ContentViewModel.self) var contentViewModel: ContentViewModel
    @Environment(\.modelContext) var context: ModelContext
    @Environment(\.dismissWindow) var dismissWindow
    @State var showInputBar: Bool = false
    @State var inputBarText: String = ""
    @State var sidebarWidth: CGFloat = 308
    @State var showMacosWindowIconsAreaHovered: Bool = false
    @State var macosWindowIconsHovered: Bool = false
    @State var window: NSWindow? = nil
    @State var showRestoredHistory: Bool = false
    @Environment(\.scenePhase) var scenePhase
    @State var showHistory = false
    @State var showMeiliSetup = false
    @Query var downloadedItems: [DownloadedItem]
    
    
    func onAppear() {
        UserDefaults.standard.set(true, forKey: "WebKitLoggingEnabled")
        UserDefaults.standard.set("WebAuthn,Authenticator", forKey: "WebKitLogLevel")

        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeMainNotification,
            object: nil,
            queue: .main
        ) { notification in
            if contentViewModel.blockNotification { // to block reinserting the window on close
                contentViewModel.blockNotification = false
                return
            }
            if let name = window?.identifier?.rawValue {
                appViewModel.displayedWindows.insert(name)
            }
        }
        showMeiliSetup = appViewModel.showMeiliSetup
        if contentViewModel.tabs.isEmpty {
            contentViewModel.isSidebarShown = true
        }
        let id = contentViewModel.id
        let fetchDescriptor = FetchDescriptor(predicate: #Predicate<SavedTab>{ return $0.windowID == id}, sortBy: [SortDescriptor(\SavedTab.sortingID, order: .forward)])
        do {
            let savedTabs = try context.fetch(fetchDescriptor)
            for savedTab in savedTabs {
                let vm = WebViewModel(contentViewModel: contentViewModel, appViewModel: appViewModel)
                vm.load(urlString: savedTab.url?.absoluteString ?? "https://miakoring.de")
                let newTab = ATab(id: savedTab.id, webViewModel: vm, restoredURLs: savedTab.backForwardList)
                print(savedTab.backForwardList)
                contentViewModel.tabs.append(newTab)
            }
        } catch {
            print("failed to fetch saved tabs")
        }
    }

}

