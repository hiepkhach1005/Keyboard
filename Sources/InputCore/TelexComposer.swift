import Foundation

public struct TelexComposer: Sendable {
    public private(set) var source: [Character] = []
    public private(set) var renderedText: String = ""

    public init() {}

    public mutating func reset() {
        source.removeAll(keepingCapacity: true)
        renderedText = ""
    }

    public mutating func handle(_ input: Character) -> TextEdit {
        guard input.isLetter || "sfxrjz".contains(input.lowercased()) else {
            let edit = TextEdit(deleteBackwardCount: renderedText.count, insertion: renderedText + String(input))
            reset()
            return edit
        }

        source.append(input)
        let previous = renderedText
        renderedText = Self.render(source)
        return TextEdit(deleteBackwardCount: previous.count, insertion: renderedText)
    }

    public mutating func backspace() -> TextEdit {
        let previous = renderedText
        guard !source.isEmpty else {
            return TextEdit(deleteBackwardCount: 1)
        }
        source.removeLast()
        renderedText = Self.render(source)
        return TextEdit(deleteBackwardCount: previous.count, insertion: renderedText)
    }

    public static func render(_ source: [Character]) -> String {
        var output: [Character] = []
        var tone: Character?

        for character in source {
            let lower = character.lowercased()
            if "sfxrj".contains(lower) {
                if toneTargetIndex(in: output) == nil {
                    output.append(character)
                } else if tone == Character(lower) {
                    tone = nil
                } else {
                    tone = Character(lower)
                }
                continue
            }
            if lower == "z" {
                if tone != nil {
                    tone = nil
                    continue
                }
                if let last = output.last, "ăâêôơư".contains(last.lowercased()) {
                    output[output.count - 1] = removeQuality(from: last)
                    continue
                }
                output.append(character)
                continue
            }

            if lower == "w", applyWModifier(to: &output) {
                continue
            }

            if lower == "o", output.last?.lowercased() == "ư" {
                output.append(preservingCase("ơ", from: character))
                continue
            }

            if let last = output.last, let modified = doubledModifier(previous: last, input: character) {
                output[output.count - 1] = modified
            } else {
                output.append(character)
            }
        }

        guard let tone else { return String(output) }
        guard let index = toneTargetIndex(in: output) else {
            return String(output) + String(tone)
        }
        output[index] = applyTone(tone, to: output[index])
        return String(output)
    }

    private static func doubledModifier(previous: Character, input: Character) -> Character? {
        switch (previous.lowercased(), input.lowercased()) {
        case ("a", "a"): return preservingCase("â", from: previous, input)
        case ("e", "e"): return preservingCase("ê", from: previous, input)
        case ("o", "o"): return preservingCase("ô", from: previous, input)
        case ("d", "d"): return preservingCase("đ", from: previous, input)
        default: return nil
        }
    }

    private static func qualityModified(_ character: Character) -> Character? {
        switch character.lowercased() {
        case "a": return preservingCase("ă", from: character)
        case "o": return preservingCase("ơ", from: character)
        case "u": return preservingCase("ư", from: character)
        default: return nil
        }
    }

    /// Applies `w` to the nearest eligible vowel even when consonants were
    /// entered after the vowel nucleus, e.g. `vuongw` -> `vương`.
    private static func applyWModifier(to output: inout [Character]) -> Bool {
        let candidates = output.indices.filter {
            "aou".contains(output[$0].lowercased())
        }
        guard let lastIndex = candidates.last,
              let modifiedLast = qualityModified(output[lastIndex]) else {
            // Treat an extra `w` after an already normalized quality vowel as
            // idempotent, preserving common free-order sequences such as
            // `truwowngf` after automatic `ưo` -> `ươ` normalization.
            return output.contains { "ăơư".contains($0.lowercased()) }
        }

        if output[lastIndex].lowercased() == "o",
           let previousIndex = candidates.dropLast().last,
           previousIndex + 1 == lastIndex,
           output[previousIndex].lowercased() == "u",
           let modifiedU = qualityModified(output[previousIndex]) {
            output[previousIndex] = modifiedU
        }
        output[lastIndex] = modifiedLast
        return true
    }

    private static func removeQuality(from character: Character) -> Character {
        switch character.lowercased() {
        case "ă", "â": return preservingCase("a", from: character)
        case "ê": return preservingCase("e", from: character)
        case "ô", "ơ": return preservingCase("o", from: character)
        case "ư": return preservingCase("u", from: character)
        default: return character
        }
    }

    private static func preservingCase(_ value: String, from first: Character, _ second: Character? = nil) -> Character {
        let uppercase = first.isUppercase || (second?.isUppercase == true)
        return Character(uppercase ? value.uppercased() : value)
    }

    private static func toneTargetIndex(in output: [Character]) -> Int? {
        let vowels = output.indices.filter { isVowel(output[$0]) }
        guard !vowels.isEmpty else { return nil }
        if let marked = vowels.last(where: { "âêôơưă".contains(output[$0].lowercased()) }) {
            return marked
        }
        if vowels.count > 1 {
            let sequence = vowels.map { output[$0].lowercased() }.joined()
            if sequence.hasPrefix("oa") || sequence.hasPrefix("oe") || sequence.hasPrefix("uy") {
                return vowels[0]
            }
        }
        return vowels.last
    }

    private static func isVowel(_ character: Character) -> Bool {
        "aăâeêioôơuưy".contains(character.lowercased())
    }

    private static func applyTone(_ tone: Character, to character: Character) -> Character {
        let mark: String
        switch tone.lowercased() {
        case "s": mark = "\u{301}"
        case "f": mark = "\u{300}"
        case "r": mark = "\u{309}"
        case "x": mark = "\u{303}"
        case "j": mark = "\u{323}"
        default: return character
        }
        let composed = (String(character) + mark).precomposedStringWithCanonicalMapping
        return Character(composed)
    }
}
