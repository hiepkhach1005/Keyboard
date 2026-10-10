#if canImport(XCTest)
import XCTest
@testable import SharedSettings

final class SharedSettingsTests: XCTestCase {
    func testDefaultsAndHoldDurationClamp() {
        let defaults = KeyboardSettings()
        XCTAssertEqual(defaults.longPressDurationMilliseconds, 350)
        XCTAssertEqual(KeyboardSettings(longPressDurationMilliseconds: 1).longPressDurationMilliseconds, 150)
        XCTAssertEqual(KeyboardSettings(longPressDurationMilliseconds: 5000).longPressDurationMilliseconds, 1000)
    }

    func testInMemoryStoreRoundTripUsesSafeValues() {
        let store = InMemorySettingsStore()
        store.save(KeyboardSettings(activeLanguage: "vietnameseTelex", longPressDurationMilliseconds: 1200))
        let result = store.load()
        XCTAssertEqual(result.activeLanguage, "vietnameseTelex")
        XCTAssertEqual(result.longPressDurationMilliseconds, 1000)
    }

    func testUserDefaultsStoreRoundTrip() {
        let suite = "KeyboardCoreTests.\(UUID().uuidString)"
        let store = UserDefaultsSettingsStore(suiteName: suite)
        store.save(KeyboardSettings(
            activeLanguage: "vietnameseTelex",
            showSecondaryLegends: false,
            swipeTypingEnabled: false,
            nextWordSuggestionsEnabled: false,
            theme: KeyboardTheme.ocean.rawValue
        ))
        let result = store.load()
        XCTAssertEqual(result.activeLanguage, "vietnameseTelex")
        XCTAssertFalse(result.showSecondaryLegends)
        XCTAssertFalse(result.swipeTypingEnabled)
        XCTAssertFalse(result.nextWordSuggestionsEnabled)
        XCTAssertEqual(result.theme, KeyboardTheme.ocean.rawValue)
    }

    func testNewSettingsDecodeKeepsSafeDefaultsForVersionOneData() throws {
        let data = try JSONSerialization.data(withJSONObject: [
            "schemaVersion": 1,
            "enabledLanguages": ["english"],
            "activeLanguage": "english",
            "longPressDurationMilliseconds": 350,
            "showSecondaryLegends": true,
            "ipadLayoutPreference": "auto",
            "modernVietnameseTonePlacement": true
        ])
        let settings = try JSONDecoder().decode(KeyboardSettings.self, from: data)
        XCTAssertTrue(settings.swipeTypingEnabled)
        XCTAssertTrue(settings.nextWordSuggestionsEnabled)
        XCTAssertEqual(settings.theme, KeyboardTheme.system.rawValue)
    }

    func testAppGroupIdentifierHasSafeFallbackOutsideAppBundle() {
        XCTAssertEqual(
            SharedSettingsConfiguration.appGroupIdentifier(),
            SharedSettingsConfiguration.fallbackAppGroupIdentifier
        )
    }
}
#endif
