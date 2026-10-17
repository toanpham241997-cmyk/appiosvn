import SwiftUI

@main
struct AujunpeakApp: App {
    @StateObject private var session = SessionManager()
    @StateObject private var monitor = DeviceMonitor()
    @StateObject private var preferences = BoostPreferences()
    @StateObject private var toast = ToastCenter()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if session.isLoggedIn {
                    AppShell()
                } else {
                    LoginView()
                }
            }
            .environmentObject(session)
            .environmentObject(monitor)
            .environmentObject(preferences)
            .environmentObject(toast)
            .tint(Palette.purple)
            .preferredColorScheme(.light)
            .transaction { if preferences.reduceEffects { $0.disablesAnimations = true } }
            .overlay(alignment: .top) { ToastBanner().environmentObject(toast) }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    monitor.refresh()
                    preferences.applyIdleTimer()
                } else {
                    preferences.pauseIdleTimer()
                }
            }
        }
    }
}

struct AppShell: View {
    @State private var tab = 0
    var body: some View {
        TabView(selection: $tab) {
            OverviewView(tab: $tab)
                .tabItem { Label("Tổng quan", systemImage: "square.grid.2x2.fill") }.tag(0)
            GamesView()
                .tabItem { Label("Game", systemImage: "gamecontroller.fill") }.tag(1)
            BoostView()
                .tabItem { Label("Tăng tốc", systemImage: "bolt.fill") }.tag(2)
            MessagesView()
                .tabItem { Label("Tin nhắn", systemImage: "bubble.left.and.bubble.right.fill") }.tag(3)
            AccountView()
                .tabItem { Label("Tài khoản", systemImage: "person.crop.circle.fill") }.tag(4)
        }
        .tint(Palette.purple)
    }
}
