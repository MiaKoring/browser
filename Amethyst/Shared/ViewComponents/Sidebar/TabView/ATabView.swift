
import SwiftUI

extension ATabView: View {
    var body: some View {
        VStack {
            List(contentViewModel.tabs) { tab in
                TabButton(id: tab.id, tabVM: tab.webViewModel)
                    .listRowSeparator(.hidden)
            }
            .scrollContentBackground(.hidden)
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
}


#Preview {
    @Previewable @State var contentViewModel = ContentViewModel(id: "lol")
    @Previewable @State var appViewModel = AppViewModel()
    ZStack {
        ContentView()
            .environment(contentViewModel)
            .environment(appViewModel)
            .onAppear() {
                let vm = WebViewModel(processPool: contentViewModel.wkProcessPool, contentViewModel: contentViewModel, appViewModel: appViewModel)
                vm.load(urlString: "https://google.com")
                contentViewModel.tabs.append(ATab(webViewModel: vm, restoredURLs: []))
                let vm1 = WebViewModel(processPool: contentViewModel.wkProcessPool, contentViewModel: contentViewModel, appViewModel: appViewModel)
                vm.load(urlString: "https://miakoring.de")
                contentViewModel.tabs.append(ATab(webViewModel: vm1))
                contentViewModel.currentTab = contentViewModel.tabs.first!.id
            }
        HStack {
            ATabView()
                .environment(contentViewModel)
            Spacer()
        }
    }
    
}

struct TabButton: View {
    let id: UUID
    @ObservedObject var tabVM: WebViewModel
    @Environment(AppViewModel.self) var appViewModel
    @State var isHovered: Bool = false
    @Environment(ContentViewModel.self) var contentViewModel
    @Environment(\.colorScheme) var appearance
    var body: some View {
        HStack {
            if let title = tabVM.title, !title.isEmpty {
                Text(title)
                    .lineLimit(1)
            } else {
                Text(tabVM.currentURL?.absoluteString ?? "failed")
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(10)
        .overlay {
            HStack(spacing: 0) {
                Spacer()
                HStack {
                    if tabVM.isUsingCamera == .active {
                        Image(systemName: "camera.circle.fill")
                            .padding(5)
                            .background {
                                Circle()
                                    .fill(.ultraThinMaterial)
                            }
                    }
                    if tabVM.isUsingCamera == .muted {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.camera.fill")
                            .padding(5)
                            .background {
                                Circle()
                                    .fill(.ultraThinMaterial)
                            }
                    }
                    if tabVM.isUsingMicrophone == .active {
                        Image(systemName: "microphone.circle.fill")
                            .padding(5)
                            .background {
                                Circle()
                                    .fill(.ultraThinMaterial)
                            }
                    }
                    if tabVM.isUsingMicrophone == .muted {
                        Image(systemName: "microphone.slash.circle.fill")
                            .padding(5)
                            .background {
                                Circle()
                                    .fill(.ultraThinMaterial)
                            }
                    }
                }
                .font(.title2)
                .foregroundStyle(.gray)
                .padding(.trailing, 5)
                if isHovered {
                    Button {
                        if contentViewModel.currentTab == id {
                            let index = contentViewModel.tabs.firstIndex(where: {$0.id == id}) ?? 0
                            if contentViewModel.tabs.count > 1 {
                                let before = contentViewModel.tabs[max(0, index - 1)].id
                                let after = contentViewModel.tabs[min(contentViewModel.tabs.count - 1, index + 1)].id
                                contentViewModel.currentTab = before == id ? after : before
                            } else {
                                contentViewModel.currentTab = nil
                            }
                        }
                        withAnimation(.linear(duration: 0.2)) { contentViewModel.tabs.first(where: {$0.id == id})?.webViewModel.deinitialize()
                            contentViewModel.tabs.removeAll(where: {$0.id == id})
                        }
                    } label: {
                        Image(systemName: "xmark.square.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                    .buttonStyle(.plain)
                    .padding(5)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background() {
            if contentViewModel.currentTab == id {
                RoundedRectangle(cornerRadius: 12)
                    .fill(appearance == .dark ? .mainColorMix.opacity(0.2): .white)
                    .shadow(radius: appearance == .dark ? 0: 2)
            } else {
                if isHovered {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(appearance == .dark ? .mainColorMix.opacity(0.1): .mainColorMix.opacity(0.02))
                } else {
                    if appearance == .dark {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.thinMaterial)
                    }
                }
            }
        }
        .onHover { hovering in
            withAnimation(.linear(duration: 0.07)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            if let currentTab = contentViewModel.tabs.first(where: {$0.id == contentViewModel.currentTab}) {
                currentTab.webViewModel.removeHighlights()
            }
            contentViewModel.showInlineSearch = false
            contentViewModel.currentTab = id
        }
    }
}
