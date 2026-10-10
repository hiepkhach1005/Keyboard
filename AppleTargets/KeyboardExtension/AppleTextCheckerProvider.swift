import InputCore
import UIKit

/// Adapter around Apple's on-device lexicon.
///
/// `UITextChecker` is deliberately kept at the extension boundary so
/// `InputCore` remains platform-light and testable on the command line. It
/// does not require Full Access: when the host/iOS lexicon has no result, the
/// caller falls back to `SuggestionEngine`'s bundled corpus.
@MainActor
final class AppleTextCheckerProvider {
    private let checker = UITextChecker()

    func suggestions(
        prefix: String,
        language: KeyboardLanguage,
        limit: Int = 3
    ) -> [String] {
        guard !prefix.isEmpty, let languageCode = languageCode(for: language) else { return [] }

        let text = prefix as NSString
        let range = NSRange(location: 0, length: text.length)
        var values: [String] = []
        let completions = checker.completions(
            forPartialWordRange: range,
            in: prefix,
            language: languageCode
        ) ?? []
        values.append(contentsOf: completions)

        // Guesses are useful when the user has already made a typo and the
        // completion list does not contain a prefix match.
        let guesses = checker.guesses(forWordRange: range, in: prefix, language: languageCode) ?? []
        values.append(contentsOf: guesses)

        var unique: [String] = []
        for value in values {
            guard !value.isEmpty,
                  value.caseInsensitiveCompare(prefix) != .orderedSame,
                  !unique.contains(where: { $0.caseInsensitiveCompare(value) == .orderedSame })
            else { continue }
            unique.append(value)
            if unique.count == max(1, limit) { break }
        }
        return unique
    }

    func supports(_ language: KeyboardLanguage) -> Bool {
        languageCode(for: language) != nil
    }

    private func languageCode(for language: KeyboardLanguage) -> String? {
        let available = Set(UITextChecker.availableLanguages)
        let preferred: [String]
        switch language {
        case .english:
            preferred = ["en_US", "en-GB", "en"]
        case .vietnameseTelex:
            preferred = ["vi_VN", "vi"]
        }
        return preferred.first(where: available.contains)
    }
}
