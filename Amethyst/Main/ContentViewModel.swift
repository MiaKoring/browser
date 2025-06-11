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
    var isPasswordShown: Bool = false
    var isPasswordFixed: Bool = false
    var currentTab: UUID?
    var tabs: [ATab] = []
    var wkProcessPool = WKProcessPool()
    var blockNotification: Bool = false
    var showInlineSearch: Bool = false
    var showHistory: Bool = false
    var lastInlineQuery: String = ""
    var isLoaded: Bool = false
    var sidebarOrientation: SidebarOrientations
    
    init(id: String) {
        self.id = id
        self.sidebarOrientation = UDKey.sidebarOrientation.boolValue ? .tabsTrailing: .tabsLeading
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
    @Environment(\.dismissWindow) var dismissWindow
    @State var showInputBar: Bool = false
    @State var inputBarText: String = ""
    @State var showMacosWindowIconsAreaHovered: Bool = false
    @State var macosWindowIconsHovered: Bool = false
    @State var window: NSWindow? = nil
    @Environment(\.scenePhase) var scenePhase
    @State var showHistory = false
    @State var showSetup = false
    
    
    func onAppear() {
        CDTabController.shared.printKnownEntities()
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
        #if DEBUG
        #else
        showSetup = appViewModel.showSetup
        #endif
        if contentViewModel.tabs.isEmpty {
            contentViewModel.isSidebarShown = true
        }
        
        if contentViewModel.tabs.isEmpty {
            let savedTabs = CDTabController.fetchAll().filter({
                $0.windowID == contentViewModel.id
            })
            
            var memoizedIDs = [UUID]()
            for savedTab in savedTabs {
                guard let id = savedTab.tabID, !memoizedIDs.contains(id) else {
                    continue
                }
                memoizedIDs.append(id)
                let vm = WebViewModel(contentViewModel: contentViewModel, appViewModel: appViewModel)
                vm.load(urlString: savedTab.url?.absoluteString ?? "https://miakoring.de")
                let newTab = ATab(id: id, webViewModel: vm)
                contentViewModel.tabs.append(newTab)
            }
        }
    }

}

