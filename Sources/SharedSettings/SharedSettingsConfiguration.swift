import Foundation

public enum SharedSettingsConfiguration {
    public static let fallbackAppGroupIdentifier = "group.com.bavuong.vuongkey"

    public static func appGroupIdentifier(bundle: Bundle = .main) -> String {
        guard let identifier = bundle.object(forInfoDictionaryKey: "KeyboardAppGroupIdentifier") as? String,
              identifier.hasPrefix("group."),
              !identifier.contains("$(") else {
            return fallbackAppGroupIdentifier
        }
        return identifier
    }
}
