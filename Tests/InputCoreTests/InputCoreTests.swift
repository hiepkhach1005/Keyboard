#if canImport(XCTest)
import XCTest
@testable import InputCore

final class InputCoreTests: XCTestCase {
    func testTelexQualityAndToneExamples() {
        XCTAssertEqual(render("aa"), "â")
        XCTAssertEqual(render("aw"), "ă")
        XCTAssertEqual(render("dd"), "đ")
        XCTAssertEqual(render("ee"), "ê")
        XCTAssertEqual(render("oo"), "ô")
        XCTAssertEqual(render("ow"), "ơ")
        XCTAssertEqual(render("uw"), "ư")
        XCTAssertEqual(render("as"), "á")
        XCTAssertEqual(render("af"), "à")
        XCTAssertEqual(render("ar"), "ả")
        XCTAssertEqual(render("ax"), "ã")
        XCTAssertEqual(render("aj"), "ạ")
    }

    func testModernTonePlacementRepresentativeWords() {
        XCTAssertEqual(render("tieesng"), "tiếng")
        XCTAssertEqual(render("tieengs"), "tiếng")
        XCTAssertEqual(render("Vieejt"), "Việt")
        XCTAssertEqual(render("dduowngf"), "đường")
        XCTAssertEqual(render("truwowngf"), "trường")
        XCTAssertEqual(render("nguyeenx"), "nguyễn")
        XCTAssertEqual(render("hoaf"), "hòa")
        XCTAssertEqual(render("khoer"), "khỏe")
        XCTAssertEqual(render("thuyr"), "thủy")
        XCTAssertEqual(render("quoocs"), "quốc")
    }

    func testDelayedWModifierSupportsFreeTypingOrder() {
        XCTAssertEqual(render("vuongw"), "vương")
        XCTAssertEqual(render("vuongsw"), "vướng")
        XCTAssertEqual(render("dduongwf"), "đường")

        var composer = TelexComposer()
        for character in "vuong" {
            _ = composer.handle(character)
        }
        XCTAssertEqual(
            composer.handle("w"),
            TextEdit(deleteBackwardCount: 5, insertion: "vương")
        )
    }

    func testPartiallyMarkedUOClusterNormalizesToUOWithHorns() {
        XCTAssertEqual(render("vưong"), "vương")
        XCTAssertEqual(render("vuwong"), "vương")
        XCTAssertEqual(render("VƯONG"), "VƯƠNG")
        XCTAssertEqual(render("truwowngf"), "trường")

        var composer = TelexComposer()
        _ = composer.handle("v")
        _ = composer.handle("ư")
        XCTAssertEqual(
            composer.handle("o"),
            TextEdit(deleteBackwardCount: 2, insertion: "vươ")
        )
    }

    func testToneReplacementAndRemoval() {
        XCTAssertEqual(render("ass"), "a")
        XCTAssertEqual(render("asf"), "à")
        XCTAssertEqual(render("asz"), "a")
        XCTAssertEqual(render("zoo"), "zô")
        XCTAssertEqual(render("sa"), "sa")
    }

    func testComposerEmitsReplacementEdits() {
        var composer = TelexComposer()
        XCTAssertEqual(composer.handle("a"), TextEdit(deleteBackwardCount: 0, insertion: "a"))
        XCTAssertEqual(composer.handle("a"), TextEdit(deleteBackwardCount: 1, insertion: "â"))
        XCTAssertEqual(composer.backspace(), TextEdit(deleteBackwardCount: 1, insertion: "a"))
        XCTAssertEqual(composer.renderedText, "a")
    }

    func testPunctuationCommitsTokenAndResets() {
        var composer = TelexComposer()
        _ = composer.handle("a")
        let edit = composer.handle(" ")
        XCTAssertEqual(edit, TextEdit(deleteBackwardCount: 1, insertion: "a "))
        XCTAssertEqual(composer.renderedText, "")
        XCTAssertEqual(composer.backspace(), TextEdit(deleteBackwardCount: 1, insertion: ""))
    }

    func testGestureCommitsPrimaryOrAlternateExactlyOnce() {
        let key = KeyDefinition(id: "a", primary: "a", alternate: "@")
        var tap = KeyGestureStateMachine(key: key, holdDuration: 0.35)
        _ = tap.touchDown()
        XCTAssertEqual(tap.touchUp(), .insert("a"))
        XCTAssertNil(tap.touchUp())

        var hold = KeyGestureStateMachine(key: key, holdDuration: 0.35)
        _ = hold.touchDown()
        XCTAssertNil(hold.advance(elapsed: 0.34))
        XCTAssertNil(hold.advance(elapsed: 0.35))
        XCTAssertEqual(hold.touchUp(), .insert("@"))
        XCTAssertNil(hold.touchUp())
    }

    func testGestureClampsUnsafeDurationAndCancellation() {
        let key = KeyDefinition(id: "a", primary: "a", alternate: "@")
        var cancelled = KeyGestureStateMachine(key: key, holdDuration: 9)
        XCTAssertEqual(cancelled.holdDuration, 1.0)
        _ = cancelled.touchDown()
        cancelled.cancel()
        XCTAssertNil(cancelled.touchUp())

        var minimum = KeyGestureStateMachine(key: key, holdDuration: 0)
        XCTAssertEqual(minimum.holdDuration, 0.15)
    }

    func testLayoutAdaptsAndKeepsSplitGapEmpty() {
        let engine = KeyboardLayoutEngine()
        let full = engine.makeLayout(context: KeyboardContext(width: 390, height: 220))
        XCTAssertFalse(full.isSplit)
        XCTAssertEqual(full.frames.count, full.rows.reduce(0) { $0 + $1.keys.count })
        XCTAssertTrue(full.frames.allSatisfy { $0.x >= 0 && $0.maxX <= 390 && $0.y >= 0 && $0.maxY <= 220 })

        let firstRowStart = full.frames.first { $0.row == 0 }?.x ?? 0
        let homeRowStart = full.frames.first { $0.row == 1 }?.x ?? 0
        XCTAssertGreaterThan(homeRowStart, firstRowStart)

        let split = engine.makeLayout(context: KeyboardContext(width: 900, height: 280, layoutPreference: .split, isRegularWidth: true))
        XCTAssertTrue(split.isSplit)
        XCTAssertEqual(split.centerGap, 18)
        XCTAssertTrue(split.frames.allSatisfy { $0.x >= 0 && $0.maxX <= 900 && $0.y >= 0 && $0.maxY <= 280 })
        let thirdRow = split.frames.filter { $0.row == 0 }
        let leftEnd = thirdRow.prefix(5).map(\.maxX).max() ?? 0
        let rightStart = thirdRow.suffix(from: 5).map(\.x).min() ?? 0
        XCTAssertGreaterThanOrEqual(rightStart - leftEnd, 18)
    }

    func testAlphabeticShiftAndModeLayers() {
        let engine = KeyboardLayoutEngine()
        let uppercase = engine.makeLayout(context: KeyboardContext(width: 390, height: 220, shiftState: .uppercase))
        XCTAssertEqual(uppercase.rows[0].keys.first?.primary, "Q")

        let numeric = engine.makeLayout(context: KeyboardContext(width: 390, height: 220, layer: .numeric))
        XCTAssertEqual(numeric.rows[0].keys.map(\.primary).joined(), "1234567890")
        XCTAssertTrue(numeric.rows.flatMap(\.keys).contains { $0.role == .alphabeticMode })

        let symbols = engine.makeLayout(context: KeyboardContext(width: 390, height: 220, layer: .symbols))
        XCTAssertTrue(symbols.rows.flatMap(\.keys).contains { $0.primary == "€" })
        XCTAssertTrue(symbols.rows.flatMap(\.keys).contains { $0.role == .numericMode })
    }

    func testBottomRowRemovesLanguageKeyAndOnlyShowsSystemGlobeWhenRequired() {
        let engine = KeyboardLayoutEngine()
        let required = engine.makeLayout(context: KeyboardContext(width: 390, height: 268))
        let requiredRoles = required.rows.last?.keys.map(\.role) ?? []
        XCTAssertFalse(requiredRoles.contains(.language))
        XCTAssertTrue(requiredRoles.contains(.globe))
        XCTAssertTrue(requiredRoles.contains(.returnKey))

        let optional = engine.makeLayout(context: KeyboardContext(
            width: 390,
            height: 268,
            showsInputModeSwitchKey: false
        ))
        let optionalRoles = optional.rows.last?.keys.map(\.role) ?? []
        XCTAssertFalse(optionalRoles.contains(.language))
        XCTAssertFalse(optionalRoles.contains(.globe))
        XCTAssertTrue(optionalRoles.contains(.returnKey))
    }

    func testGboardStyleLegendsCoverAllLetterRowsAndBottomHasPunctuation() {
        let engine = KeyboardLayoutEngine()
        let english = engine.makeLayout(context: KeyboardContext(width: 375, height: 208))
        for row in 0...2 {
            let characters = english.rows[row].keys.filter { $0.role == .character }
            XCTAssertTrue(characters.allSatisfy { $0.alternate != nil })
        }

        let bottom = english.rows.last?.keys ?? []
        XCTAssertEqual(bottom.map(\.id), ["numeric", "globe", "comma-bottom", "space", "period-bottom", "return"])
        XCTAssertEqual(bottom.first { $0.id == "comma-bottom" }?.primary, ",")
        XCTAssertEqual(bottom.first { $0.id == "period-bottom" }?.primary, ".")

        let vietnamese = engine.makeLayout(context: KeyboardContext(
            width: 375,
            height: 208,
            language: .vietnameseTelex
        ))
        XCTAssertEqual(vietnamese.rows.flatMap(\.keys).first { $0.id == "a" }?.alternate, "@")
        XCTAssertEqual(vietnamese.rows.flatMap(\.keys).first { $0.id == "d" }?.alternate, "$")
        XCTAssertEqual(vietnamese.rows.flatMap(\.keys).first { $0.id == "e" }?.alternate, "3")
        let removedVietnameseLegends: Set<String> = ["ă", "đ", "ê", "ô", "ư"]
        XCTAssertTrue(vietnamese.rows.flatMap(\.keys).allSatisfy {
            guard let alternate = $0.alternate else { return true }
            return !removedVietnameseLegends.contains(alternate.lowercased())
        })

        let letterKeyHeight = english.frames.first { $0.row == 0 }?.height ?? 0
        XCTAssertEqual(letterKeyHeight, 44.5, accuracy: 0.01)
    }

    func testSwipeTypingDecodesDistinctCharacterPathOnly() {
        let layout = KeyboardLayoutEngine().makeLayout(
            context: KeyboardContext(width: 390, height: 220)
        )
        let keyFrames = Dictionary(uniqueKeysWithValues: layout.frames.compactMap { frame -> (String, KeyFrame)? in
            guard frame.row == 0 || frame.row == 1 else { return nil }
            return (layout.rows[frame.row].keys[frame.column].primary, frame)
        })
        func center(_ key: String) -> SwipePoint {
            let frame = keyFrames[key]!
            return SwipePoint(x: frame.x + frame.width / 2, y: frame.y + frame.height / 2)
        }

        let points = [center("h"), center("e"), center("l"), center("l"), center("o")]
        XCTAssertEqual(SwipeTypingEngine().decode(points: points, layout: layout), "helo")
        XCTAssertEqual(
            SwipeTypingEngine().decode(points: [center("h")], layout: layout),
            ""
        )
    }

    func testSuggestionEngineSupportsPrefixAndNextWordCandidates() {
        let engine = SuggestionEngine()
        XCTAssertEqual(engine.suggestions(prefix: "tha", previousWord: nil, language: .english), ["that", "thank", "thanks"])
        XCTAssertEqual(engine.suggestions(prefix: "", previousWord: "xin", language: .vietnameseTelex), ["chào", "lỗi"])
        XCTAssertEqual(engine.suggestions(prefix: "Vư", previousWord: nil, language: .vietnameseTelex), ["Vương"])
    }

    func testSwipeCandidatesRankCollapsedRepeatsAndVietnameseDiacritics() {
        let engine = SuggestionEngine()
        XCTAssertEqual(engine.swipeCandidates(keySequence: "helo", language: .english).first, "hello")
        XCTAssertEqual(engine.swipeCandidates(keySequence: "vuong", language: .vietnameseTelex).first, "vương")
        XCTAssertTrue(engine.swipeCandidates(keySequence: "qz", language: .english).isEmpty)
    }

    private func render(_ input: String) -> String {
        TelexComposer.render(Array(input))
    }
}
#endif
