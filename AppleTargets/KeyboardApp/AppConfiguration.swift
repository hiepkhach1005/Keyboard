import Foundation

enum AppConfiguration {
    static var displayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "VuongKey"
    }

    static var version: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    static var privacyPolicyURL: URL? { configuredURL(forKey: "PrivacyPolicyURL") }
    static var supportURL: URL? { configuredURL(forKey: "SupportURL") }

    private static func configuredURL(forKey key: String) -> URL? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              value.hasPrefix("https://") else { return nil }
        return URL(string: value)
    }
}
