import Foundation
import InputCore
import SharedSettings

@discardableResult
func check(_ condition: @autoclosure () -> Bool, _ message: String) -> Bool {
    guard condition() else {
        fputs("FAIL: \(message)\n", stderr)
        exit(1)
    }
    return true
}

func render(_ value: String) -> String {
    TelexComposer.render(Array(value))
}

check(render("aa") == "â", "aa -> â")
check(render("aw") == "ă", "aw -> ă")
check(render("dd") == "đ", "dd -> đ")
check(render("tieengs") == "tiếng", "tieengs -> tiếng")
check(render("Vieejt") == "Việt", "Vieejt -> Việt")
check(render("dduowngf") == "đường", "dduowngf -> đường")
check(render("hoaf") == "hòa", "hoaf -> hòa")
check(render("khoer") == "khỏe", "khoer -> khỏe")
check(render("thuyr") == "thủy", "thuyr -> thủy")
check(render("quoocs") == "quốc", "quoocs -> quốc")
check(render("zoo") == "zô", "zoo remains a word")
check(render("sa") == "sa", "tone key before a vowel remains literal")
check(render("ass") == "a", "repeated tone removes tone")

let key = KeyDefinition(id: "a", primary: "a", alternate: "@")
var gesture = KeyGestureStateMachine(key: key, holdDuration: 0.35)
_ = gesture.touchDown()
_ = gesture.advance(elapsed: 0.35)
check(gesture.touchUp() == .insert("@"), "long press alternate")
check(gesture.touchUp() == nil, "long press exactly once")

let layout = KeyboardLayoutEngine().makeLayout(
    context: KeyboardContext(width: 900, height: 280, layoutPreference: .split, isRegularWidth: true)
)
check(layout.isSplit, "split layout selected")
check(layout.frames.allSatisfy { $0.x >= 0 && $0.maxX <= 900 && $0.y >= 0 && $0.maxY <= 280 }, "frames within bounds")
let uppercase = KeyboardLayoutEngine().makeLayout(context: KeyboardContext(width: 390, height: 220, shiftState: .uppercase))
check(uppercase.rows[0].keys.first?.primary == "Q", "uppercase alphabetic layer")
let numeric = KeyboardLayoutEngine().makeLayout(context: KeyboardContext(width: 390, height: 220, layer: .numeric))
check(numeric.rows[0].keys.map(\.primary).joined() == "1234567890", "numeric layer")
let symbols = KeyboardLayoutEngine().makeLayout(context: KeyboardContext(width: 390, height: 220, layer: .symbols))
check(symbols.rows.flatMap(\.keys).contains { $0.primary == "€" }, "symbol layer")
let firstRow = KeyboardLayoutEngine().makeLayout(context: KeyboardContext(width: 390, height: 220))
let swipeFrames = firstRow.frames.filter { $0.row < 2 }
let swipePoints = swipeFrames.prefix(3).map { SwipePoint(x: $0.x + $0.width / 2, y: $0.y + $0.height / 2) }
check(SwipeTypingEngine().decode(points: swipePoints, layout: firstRow).count == 3, "swipe path decoding")
let suggestions = SuggestionEngine().suggestions(prefix: "tha", previousWord: nil, language: .english)
check(suggestions.first == "that", "offline candidate prefix")
let swipeCandidates = SuggestionEngine().swipeCandidates(keySequence: "helo", language: .english)
check(swipeCandidates.first == "hello", "swipe candidate ranking")
let vietnameseSwipeCandidates = SuggestionEngine().swipeCandidates(keySequence: "vuong", language: .vietnameseTelex)
check(vietnameseSwipeCandidates.first == "vương", "Vietnamese swipe candidate ranking")

let settings = KeyboardSettings(longPressDurationMilliseconds: 5000)
check(settings.longPressDurationMilliseconds == 1000, "settings clamp")
check(SharedSettingsConfiguration.appGroupIdentifier() == SharedSettingsConfiguration.fallbackAppGroupIdentifier, "App Group fallback")
print("CoreValidation: all checks passed")
