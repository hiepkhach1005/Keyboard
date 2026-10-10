import Combine
import Foundation
import SharedSettings
import UIKit

@MainActor
final class KeyboardAppModel: ObservableObject {
    private enum Keys { static let onboarding = "HasCompletedKeyboardOnboarding" }
    private let store: UserDefaultsSettingsStore

    @Published var settings: KeyboardSettings {
        didSet { store.save(settings) }
    }
    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.onboarding) }
    }

    init() {
        let resolvedStore = UserDefaultsSettingsStore(suiteName: SharedSettingsConfiguration.appGroupIdentifier())
        store = resolvedStore
        settings = resolvedStore.load()
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.onboarding)
    }

    func completeOnboarding() { hasCompletedOnboarding = true }
    func showOnboardingAgain() { hasCompletedOnboarding = false }
    func resetSettings() { settings = KeyboardSettings() }

    func openSystemSettings() async {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        await UIApplication.shared.open(url)
    }
}
