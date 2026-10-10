import Foundation

public enum KeyboardTheme: String, Codable, CaseIterable, Sendable {
    case system
    case midnight
    case ocean
    case royal
    case forest
    case rose
    case highContrast

    public var displayName: String {
        switch self {
        case .system: return "Theo hệ thống"
        case .midnight: return "Đêm than"
        case .ocean: return "Đại dương"
        case .royal: return "Hoàng gia"
        case .forest: return "Rừng xanh"
        case .rose: return "Hồng san hô"
        case .highContrast: return "Tương phản cao"
        }
    }
}

public struct KeyboardSettings: Codable, Equatable, Sendable {
    public static let currentSchemaVersion = 2
    public static let defaultHoldMilliseconds = 350

    public var schemaVersion: Int
    public var enabledLanguages: [String]
    public var activeLanguage: String
    public var longPressDurationMilliseconds: Int
    public var showSecondaryLegends: Bool
    public var ipadLayoutPreference: String
    public var modernVietnameseTonePlacement: Bool
    public var swipeTypingEnabled: Bool
    public var nextWordSuggestionsEnabled: Bool
    public var theme: String

    public init(
        schemaVersion: Int = KeyboardSettings.currentSchemaVersion,
        enabledLanguages: [String] = ["english", "vietnameseTelex"],
        activeLanguage: String = "english",
        longPressDurationMilliseconds: Int = KeyboardSettings.defaultHoldMilliseconds,
        showSecondaryLegends: Bool = true,
        ipadLayoutPreference: String = "auto",
        modernVietnameseTonePlacement: Bool = true,
        swipeTypingEnabled: Bool = true,
        nextWordSuggestionsEnabled: Bool = true,
        theme: String = "system"
    ) {
        self.schemaVersion = schemaVersion
        self.enabledLanguages = enabledLanguages
        self.activeLanguage = activeLanguage
        self.longPressDurationMilliseconds = min(max(longPressDurationMilliseconds, 150), 1000)
        self.showSecondaryLegends = showSecondaryLegends
        self.ipadLayoutPreference = ipadLayoutPreference
        self.modernVietnameseTonePlacement = modernVietnameseTonePlacement
        self.swipeTypingEnabled = swipeTypingEnabled
        self.nextWordSuggestionsEnabled = nextWordSuggestionsEnabled
        self.theme = theme
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, enabledLanguages, activeLanguage
        case longPressDurationMilliseconds, showSecondaryLegends
        case ipadLayoutPreference, modernVietnameseTonePlacement
        case swipeTypingEnabled, nextWordSuggestionsEnabled, theme
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            schemaVersion: try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? Self.currentSchemaVersion,
            enabledLanguages: try container.decodeIfPresent([String].self, forKey: .enabledLanguages) ?? ["english", "vietnameseTelex"],
            activeLanguage: try container.decodeIfPresent(String.self, forKey: .activeLanguage) ?? "english",
            longPressDurationMilliseconds: try container.decodeIfPresent(Int.self, forKey: .longPressDurationMilliseconds) ?? Self.defaultHoldMilliseconds,
            showSecondaryLegends: try container.decodeIfPresent(Bool.self, forKey: .showSecondaryLegends) ?? true,
            ipadLayoutPreference: try container.decodeIfPresent(String.self, forKey: .ipadLayoutPreference) ?? "auto",
            modernVietnameseTonePlacement: try container.decodeIfPresent(Bool.self, forKey: .modernVietnameseTonePlacement) ?? true,
            swipeTypingEnabled: try container.decodeIfPresent(Bool.self, forKey: .swipeTypingEnabled) ?? true,
            nextWordSuggestionsEnabled: try container.decodeIfPresent(Bool.self, forKey: .nextWordSuggestionsEnabled) ?? true,
            theme: try container.decodeIfPresent(String.self, forKey: .theme) ?? "system"
        )
    }
}

public protocol SettingsStore: Sendable {
    func load() -> KeyboardSettings
    func save(_ settings: KeyboardSettings)
}

public final class InMemorySettingsStore: SettingsStore, @unchecked Sendable {
    private var value: KeyboardSettings

    public init(_ value: KeyboardSettings = KeyboardSettings()) {
        self.value = value
    }

    public func load() -> KeyboardSettings { value }

    public func save(_ settings: KeyboardSettings) {
        value = KeyboardSettings(
            schemaVersion: settings.schemaVersion,
            enabledLanguages: settings.enabledLanguages,
            activeLanguage: settings.activeLanguage,
            longPressDurationMilliseconds: settings.longPressDurationMilliseconds,
            showSecondaryLegends: settings.showSecondaryLegends,
            ipadLayoutPreference: settings.ipadLayoutPreference,
            modernVietnameseTonePlacement: settings.modernVietnameseTonePlacement,
            swipeTypingEnabled: settings.swipeTypingEnabled,
            nextWordSuggestionsEnabled: settings.nextWordSuggestionsEnabled,
            theme: settings.theme
        )
    }
}

public final class UserDefaultsSettingsStore: SettingsStore, @unchecked Sendable {
    private let defaults: UserDefaults
    private let key: String

    public init(suiteName: String? = nil, key: String = "KeyboardSettings") {
        self.defaults = suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
        self.key = key
    }

    public func load() -> KeyboardSettings {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode(KeyboardSettings.self, from: data)
        else { return KeyboardSettings() }
        return KeyboardSettings(
            schemaVersion: decoded.schemaVersion,
            enabledLanguages: decoded.enabledLanguages,
            activeLanguage: decoded.activeLanguage,
            longPressDurationMilliseconds: decoded.longPressDurationMilliseconds,
            showSecondaryLegends: decoded.showSecondaryLegends,
            ipadLayoutPreference: decoded.ipadLayoutPreference,
            modernVietnameseTonePlacement: decoded.modernVietnameseTonePlacement,
            swipeTypingEnabled: decoded.swipeTypingEnabled,
            nextWordSuggestionsEnabled: decoded.nextWordSuggestionsEnabled,
            theme: decoded.theme
        )
    }

    public func save(_ settings: KeyboardSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: key)
    }
}
