import SwiftUI

@main
struct KeyboardApp: App {
    @StateObject private var model = KeyboardAppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
        }
    }
}

private struct RootView: View {
    @EnvironmentObject private var model: KeyboardAppModel

    var body: some View {
        Group {
            if model.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .tint(.blue)
    }
}

private struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack { SetupGuideView() }
                .tabItem { Label("Cài đặt", systemImage: "keyboard") }
            NavigationStack { TypingTestView() }
                .tabItem { Label("Gõ thử", systemImage: "text.cursor") }
            NavigationStack { KeyboardSettingsView() }
                .tabItem { Label("Tùy chỉnh", systemImage: "slider.horizontal.3") }
            NavigationStack { AboutView() }
                .tabItem { Label("Thông tin", systemImage: "info.circle") }
        }
    }
}
