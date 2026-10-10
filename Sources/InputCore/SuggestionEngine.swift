import Foundation

/// A deterministic, offline candidate engine.
///
/// The keyboard extension passes only the current token and the immediately
/// preceding word. The lexicon is bundled data and this provider never
/// persists or transmits typed text. Apple's `UITextChecker` can augment this
/// engine at the UI boundary, while this provider remains the privacy-
/// preserving fallback for every device and host field.
public struct SuggestionEngine: Sendable {
    public let defaultLimit: Int

    public init(defaultLimit: Int = 3) {
        self.defaultLimit = max(1, defaultLimit)
    }

    /// Returns prefix completions and next-word candidates in stable order.
    public func suggestions(
        prefix: String,
        previousWord: String?,
        language: KeyboardLanguage,
        limit: Int? = nil
    ) -> [String] {
        let count = max(1, limit ?? defaultLimit)
        let normalizedPrefix = Self.folded(prefix)
        var candidates: [LexiconEntry] = []

        if normalizedPrefix.isEmpty {
            if let previousWord {
                candidates.append(contentsOf: Self.nextWords(for: language)[Self.folded(previousWord)] ?? [])
            }
            if candidates.isEmpty {
                candidates.append(contentsOf: Self.starterWords(for: language))
            }
        } else {
            let lexicon = Self.lexicon(for: language)
            let exactPrefix = prefix.lowercased()
            let exactMatches = lexicon.filter { entry in
                let word = entry.word.lowercased()
                return word.hasPrefix(exactPrefix) && word != exactPrefix
            }
            candidates = exactMatches.isEmpty
                ? lexicon.filter { entry in
                    Self.folded(entry.word).hasPrefix(normalizedPrefix) &&
                        Self.folded(entry.word) != normalizedPrefix
                }
                : exactMatches
            candidates.sort {
                if $0.frequency != $1.frequency { return $0.frequency > $1.frequency }
                return $0.word < $1.word
            }
        }

        return uniquePreservingCase(candidates.map(\.word), matching: prefix, limit: count)
    }

    /// Ranks words against a collapsed swipe path such as `helo` -> `hello`.
    /// Duplicate letters are commonly collapsed by the gesture recognizer, so
    /// the score combines normalized edit distance, subsequence shape, and
    /// corpus frequency. It is conservative for short/noisy paths.
    public func swipeCandidates(
        keySequence: String,
        language: KeyboardLanguage,
        limit: Int? = nil
    ) -> [String] {
        let count = max(1, limit ?? defaultLimit)
        let path = Array(Self.folded(keySequence))
        guard path.count >= 2 else { return [] }

        let ranked = Self.lexicon(for: language).compactMap { entry -> RankedSwipeCandidate? in
            let word = Array(Self.folded(entry.word))
            guard word.count >= max(2, path.count - 1) else { return nil }
            let distance = Self.levenshtein(path, word)
            let maximumLength = max(path.count, word.count)
            let relativeDistance = Double(distance) / Double(maximumLength)
            let subsequence = Self.isSubsequence(path, in: word)
            let closeEnough = relativeDistance <= 0.34 || (subsequence && relativeDistance <= 0.45)
            guard closeEnough else { return nil }

            let score = relativeDistance - (subsequence ? 0.08 : 0) - (Double(entry.frequency) / 1_000_000)
            return RankedSwipeCandidate(word: entry.word, score: score, frequency: entry.frequency)
        }

        return uniquePreservingCase(
            ranked.sorted {
                if $0.score != $1.score { return $0.score < $1.score }
                if $0.frequency != $1.frequency { return $0.frequency > $1.frequency }
                return $0.word < $1.word
            }.map(\.word),
            matching: "",
            limit: count
        )
    }

    private func uniquePreservingCase(_ values: [String], matching prefix: String, limit: Int) -> [String] {
        var unique: [String] = []
        for candidate in values {
            let value = Self.preserveCase(candidate, matching: prefix)
            guard !unique.contains(where: { $0.caseInsensitiveCompare(value) == .orderedSame }) else { continue }
            unique.append(value)
            if unique.count == limit { break }
        }
        return unique
    }

    private struct LexiconEntry: Sendable {
        let word: String
        let frequency: Int
    }

    private struct RankedSwipeCandidate {
        let word: String
        let score: Double
        let frequency: Int
    }

    private static func lexicon(for language: KeyboardLanguage) -> [LexiconEntry] {
        switch language {
        case .english: return englishLexicon
        case .vietnameseTelex: return vietnameseLexicon
        }
    }

    // Frequencies are project-authored ranking weights, not a downloaded user corpus.
    private static let englishLexicon: [LexiconEntry] = [
        ("the", 1000), ("that", 940), ("this", 930), ("there", 900), ("then", 860),
        ("they", 850), ("their", 820), ("thank", 800), ("thanks", 790), ("than", 780),
        ("you", 990), ("your", 910), ("you're", 700), ("are", 960), ("and", 980),
        ("can", 900), ("could", 760), ("come", 650), ("for", 950), ("from", 820),
        ("have", 920), ("has", 850), ("hello", 760), ("help", 700), ("how", 900),
        ("i", 970), ("in", 940), ("is", 960), ("it", 950), ("its", 700),
        ("just", 740), ("know", 720), ("like", 700), ("make", 650), ("me", 860),
        ("my", 820), ("need", 720), ("next", 600), ("nice", 540), ("of", 980),
        ("on", 900), ("one", 760), ("only", 650), ("please", 760), ("right", 700),
        ("see", 800), ("send", 650), ("she", 730), ("so", 820), ("some", 720),
        ("sorry", 630), ("thankful", 420), ("that's", 680), ("to", 990), ("today", 630),
        ("tomorrow", 500), ("too", 730), ("want", 820), ("was", 850), ("we", 900),
        ("what", 900), ("when", 820), ("where", 780), ("which", 700), ("with", 900),
        ("would", 760), ("yes", 640), ("good", 760), ("morning", 560), ("night", 520),
        ("home", 620), ("work", 680), ("going", 650), ("get", 780), ("got", 580),
        ("great", 620), ("really", 690), ("love", 610), ("later", 520), ("meeting", 450),
        ("okay", 660), ("people", 520), ("time", 790), ("will", 850), ("well", 700),
        ("because", 650), ("before", 580), ("after", 570), ("about", 760), ("also", 650),
        ("always", 540), ("back", 600), ("best", 560), ("day", 700), ("find", 570),
        ("first", 620), ("give", 600), ("keep", 540), ("let", 520), ("look", 650),
        ("much", 630), ("now", 780), ("still", 640), ("take", 620), ("tell", 620),
        ("thing", 600), ("think", 720), ("use", 600), ("very", 720), ("welcome", 430),
        ("world", 470), ("write", 430)
    ].map { LexiconEntry(word: $0.0, frequency: $0.1) }

    private static let vietnameseLexicon: [LexiconEntry] = [
        ("anh", 880), ("bạn", 980), ("bằng", 560), ("bao", 520), ("biết", 850),
        ("bị", 500), ("cảm", 780), ("chào", 860), ("cho", 930), ("chúng", 700),
        ("có", 1000), ("cũng", 820), ("đang", 890), ("để", 900), ("đến", 720),
        ("đi", 760), ("được", 960), ("gì", 900), ("giúp", 700), ("hai", 580),
        ("hay", 620), ("hôm", 650), ("không", 990), ("làm", 880), ("lại", 760),
        ("lắm", 530), ("mình", 940), ("muốn", 900), ("một", 970), ("này", 860),
        ("ngày", 780), ("người", 920), ("nhé", 740), ("nhưng", 760), ("nơi", 540),
        ("nữa", 680), ("phải", 790), ("qua", 580), ("rất", 770), ("rồi", 820),
        ("sao", 740), ("sẽ", 720), ("tại", 660), ("thật", 670), ("thể", 850),
        ("thì", 900), ("thời", 530), ("tiếng", 630), ("tôi", 980), ("trong", 920),
        ("trường", 570), ("và", 980), ("về", 760), ("việt", 680), ("với", 940),
        ("vương", 420), ("xin", 820), ("yêu", 730), ("ơn", 620), ("đường", 620),
        ("đúng", 660), ("hòa", 420), ("khỏe", 460), ("thủy", 390), ("quốc", 570),
        ("tiện", 420), ("tiếp", 470), ("theo", 700), ("từ", 780), ("cùng", 700),
        ("mới", 720), ("nhiều", 760), ("nhanh", 550), ("chậm", 420), ("sáng", 450),
        ("tối", 460), ("mai", 620), ("nay", 700), ("nhớ", 630), ("nói", 690),
        ("đây", 720), ("đó", 780), ("rằng", 520), ("sẵn", 390), ("sống", 430),
        ("tốt", 740), ("vui", 620), ("việc", 760), ("vừa", 600), ("muộn", 370),
        ("mừng", 380), ("lỗi", 430), ("cần", 730), ("đã", 880), ("sắp", 500),
        ("mang", 470), ("nhận", 430), ("gửi", 440), ("xem", 620), ("mua", 410),
        ("dùng", 590), ("nếu", 650), ("khi", 820), ("vì", 820), ("nên", 720),
        ("hoặc", 430), ("lên", 610), ("xuống", 390), ("ra", 700), ("vào", 730)
    ].map { LexiconEntry(word: $0.0, frequency: $0.1) }

    private static func nextWords(for language: KeyboardLanguage) -> [String: [LexiconEntry]] {
        switch language {
        case .english:
            return [
                "how": [("are", 960), ("can", 720), ("to", 650)],
                "thank": [("you", 1000)], "thanks": [("for", 900)],
                "see": [("you", 900), ("the", 640)], "i": [("am", 850), ("can", 700), ("will", 650)],
                "what": [("is", 900), ("are", 740)], "where": [("are", 860), ("is", 650)],
                "please": [("help", 780), ("send", 560)], "good": [("morning", 900), ("night", 760)]
            ].mapValues { $0.map { LexiconEntry(word: $0.0, frequency: $0.1) } }
        case .vietnameseTelex:
            return [
                "xin": [("chào", 950), ("lỗi", 450)], "chào": [("bạn", 900), ("buổi", 620)],
                "cảm": [("ơn", 980)], "bạn": [("đang", 760), ("có", 720), ("muốn", 650)],
                "tôi": [("đang", 780), ("có", 720), ("muốn", 680)],
                "không": [("có", 800), ("phải", 650), ("thể", 620)],
                "có": [("thể", 900), ("một", 720), ("gì", 620)], "hôm": [("nay", 900)],
                "ngày": [("mai", 880)], "với": [("bạn", 840)], "đường": [("đi", 510)],
                "rất": [("vui", 620)], "để": [("tôi", 600)]
            ].mapValues { $0.map { LexiconEntry(word: $0.0, frequency: $0.1) } }
        }
    }

    private static func starterWords(for language: KeyboardLanguage) -> [LexiconEntry] {
        switch language {
        case .english: return [LexiconEntry(word: "the", frequency: 1000), LexiconEntry(word: "I", frequency: 990), LexiconEntry(word: "you", frequency: 980)]
        case .vietnameseTelex: return [LexiconEntry(word: "mình", frequency: 940), LexiconEntry(word: "bạn", frequency: 900), LexiconEntry(word: "xin", frequency: 850)]
        }
    }

    private static func folded(_ value: String) -> String {
        value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "vi_VN"))
    }

    private static func preserveCase(_ candidate: String, matching prefix: String) -> String {
        guard let first = prefix.first else { return candidate }
        if first.isUppercase { return candidate.first?.isUppercase == true ? candidate : candidate.capitalized }
        return candidate
    }

    private static func isSubsequence(_ needle: [Character], in haystack: [Character]) -> Bool {
        var index = 0
        for character in haystack where index < needle.count {
            if character == needle[index] { index += 1 }
        }
        return index == needle.count
    }

    private static func levenshtein(_ lhs: [Character], _ rhs: [Character]) -> Int {
        if lhs.isEmpty { return rhs.count }
        if rhs.isEmpty { return lhs.count }
        var previous = Array(0...rhs.count)
        for (i, left) in lhs.enumerated() {
            var current = [i + 1]
            current.reserveCapacity(rhs.count + 1)
            for (j, right) in rhs.enumerated() {
                let insertion = current[j] + 1
                let deletion = previous[j + 1] + 1
                let substitution = previous[j] + (left == right ? 0 : 1)
                current.append(min(insertion, deletion, substitution))
            }
            previous = current
        }
        return previous[rhs.count]
    }
}
