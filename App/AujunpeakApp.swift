import SwiftUI

@main
struct AujunpeakApp: App {
    @AppStorage("demoSignedIn") private var demoSignedIn = false
    @State private var sessionSignedIn = false
    @StateObject private var store = DemoStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if demoSignedIn || sessionSignedIn {
                    AppShell(onLogout: {
                        demoSignedIn = false
                        sessionSignedIn = false
                    })
                } else {
                    LoginView(onLogin: { remember in
                        if remember { demoSignedIn = true }
                        else { sessionSignedIn = true }
                    })
                }
            }
            .environmentObject(store)
            .tint(UIStyle.blue)
            .preferredColorScheme(.light)
        }
    }
}

struct AppShell: View {
    let onLogout: () -> Void
    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem { Label("Tổng quan", systemImage: "square.grid.2x2.fill") }
                .tag(0)
            ExploreView()
                .tabItem { Label("Khám phá", systemImage: "square.stack.3d.up.fill") }
                .tag(1)
            TasksView()
                .tabItem { Label("Công việc", systemImage: "checkmark.circle.fill") }
                .tag(2)
            InboxView()
                .tabItem { Label("Tin nhắn", systemImage: "bubble.left.and.bubble.right.fill") }
                .tag(3)
            ProfileView(onLogout: onLogout)
                .tabItem { Label("Tài khoản", systemImage: "person.crop.circle.fill") }
                .tag(4)
        }
        .tint(UIStyle.blue)
    }
}
