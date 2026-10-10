import Foundation

public enum KeyboardLanguage: String, Codable, CaseIterable, Sendable {
    case english
    case vietnameseTelex
}

public enum LayoutPreference: String, Codable, CaseIterable, Sendable {
    case auto
    case full
    case split
}

public enum KeyboardLayerKind: String, Codable, CaseIterable, Sendable {
    case alphabetic
    case numeric
    case symbols
}

public enum ShiftState: String, Codable, CaseIterable, Sendable {
    case lowercase
    case uppercase
    case capsLock

    public var usesUppercaseLetters: Bool { self != .lowercase }
}

public enum KeyRole: String, Codable, Sendable {
    case character
    case shift
    case backspace
    case space
    case returnKey
    case language
    case globe
    case numericMode
    case alphabeticMode
    case symbolMode
}

public struct KeyDefinition: Hashable, Codable, Sendable {
    public let id: String
    public let primary: String
    public let alternate: String?
    public let role: KeyRole
    public let widthWeight: Double

    public init(
        id: String,
        primary: String,
        alternate: String? = nil,
        role: KeyRole = .character,
        widthWeight: Double = 1
    ) {
        self.id = id
        self.primary = primary
        self.alternate = alternate
        self.role = role
        self.widthWeight = widthWeight
    }

    public var accessibilityLabel: String {
        guard let alternate, !alternate.isEmpty else { return primary }
        return "\(primary), hold for \(alternate)"
    }
}

public struct KeyboardRow: Hashable, Codable, Sendable {
    public let keys: [KeyDefinition]

    public init(keys: [KeyDefinition]) {
        self.keys = keys
    }
}

public struct KeyboardContext: Hashable, Sendable {
    public var width: Double
    public var height: Double
    public var language: KeyboardLanguage
    public var layoutPreference: LayoutPreference
    public var isRegularWidth: Bool
    public var showsInputModeSwitchKey: Bool
    public var layer: KeyboardLayerKind
    public var shiftState: ShiftState

    public init(
        width: Double,
        height: Double,
        language: KeyboardLanguage = .english,
        layoutPreference: LayoutPreference = .auto,
        isRegularWidth: Bool = false,
        showsInputModeSwitchKey: Bool = true,
        layer: KeyboardLayerKind = .alphabetic,
        shiftState: ShiftState = .lowercase
    ) {
        self.width = width
        self.height = height
        self.language = language
        self.layoutPreference = layoutPreference
        self.isRegularWidth = isRegularWidth
        self.showsInputModeSwitchKey = showsInputModeSwitchKey
        self.layer = layer
        self.shiftState = shiftState
    }
}

public struct KeyFrame: Hashable, Sendable {
    public let keyID: String
    public let row: Int
    public let column: Int
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(keyID: String, row: Int, column: Int, x: Double, y: Double, width: Double, height: Double) {
        self.keyID = keyID
        self.row = row
        self.column = column
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public var maxX: Double { x + width }
    public var maxY: Double { y + height }
}

public struct KeyboardLayout: Hashable, Sendable {
    public let rows: [KeyboardRow]
    public let frames: [KeyFrame]
    public let isSplit: Bool
    public let centerGap: Double

    public init(rows: [KeyboardRow], frames: [KeyFrame], isSplit: Bool, centerGap: Double) {
        self.rows = rows
        self.frames = frames
        self.isSplit = isSplit
        self.centerGap = centerGap
    }
}

public enum KeyIntent: Hashable, Sendable {
    case insert(String)
    case control(KeyRole)
}

public struct TextEdit: Equatable, Sendable {
    public let deleteBackwardCount: Int
    public let insertion: String

    public init(deleteBackwardCount: Int = 0, insertion: String = "") {
        self.deleteBackwardCount = deleteBackwardCount
        self.insertion = insertion
    }
}
