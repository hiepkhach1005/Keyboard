import Foundation

public struct KeyboardLayoutEngine: Sendable {
    public var horizontalInset: Double
    public var verticalInset: Double
    public var rowGap: Double
    public var centerGap: Double

    public init(horizontalInset: Double = 4, verticalInset: Double = 6, rowGap: Double = 6, centerGap: Double = 18) {
        self.horizontalInset = horizontalInset
        self.verticalInset = verticalInset
        self.rowGap = rowGap
        self.centerGap = centerGap
    }

    public func makeLayout(context: KeyboardContext) -> KeyboardLayout {
        let rows = Self.rows(for: context)
        let split = shouldSplit(context: context)
        let usableWidth = max(0, context.width - (horizontalInset * 2))
        let verticalContent = max(0, context.height - verticalInset * 2)
        let rowHeight = max(1, (verticalContent - rowGap * Double(max(0, rows.count - 1))) / Double(max(1, rows.count)))
        var frames: [KeyFrame] = []

        for (rowIndex, row) in rows.enumerated() {
            let alignmentInset = rowAlignmentInset(rowIndex: rowIndex, context: context, isSplit: split)
            let rowUsableWidth = max(0, usableWidth - alignmentInset * 2)
            let gapCount = max(0, row.keys.count - 1)
            let extraSplitGap = split ? centerGap : 0
            let contentWidth = max(0, rowUsableWidth - rowGap * Double(gapCount) - extraSplitGap)
            let totalWeight = max(1, row.keys.reduce(0) { $0 + $1.widthWeight })
            let splitIndex = split ? Int(ceil(Double(row.keys.count) / 2)) : row.keys.count
            var x = horizontalInset + alignmentInset

            for (column, key) in row.keys.enumerated() {
                let width = contentWidth * key.widthWeight / totalWeight
                frames.append(KeyFrame(
                    keyID: key.id,
                    row: rowIndex,
                    column: column,
                    x: x,
                    y: verticalInset + Double(rowIndex) * (rowHeight + rowGap),
                    width: width,
                    height: rowHeight
                ))
                x += width
                if column < row.keys.count - 1 {
                    x += rowGap
                    if split && column + 1 == splitIndex {
                        x += centerGap
                    }
                }
            }
        }

        return KeyboardLayout(rows: rows, frames: frames, isSplit: split, centerGap: split ? centerGap : 0)
    }

    private func rowAlignmentInset(rowIndex: Int, context: KeyboardContext, isSplit: Bool) -> Double {
        guard !isSplit, context.layer == .alphabetic, rowIndex == 1 else { return 0 }
        return min(18, max(10, context.width * 0.04))
    }

    private func shouldSplit(context: KeyboardContext) -> Bool {
        switch context.layoutPreference {
        case .full: return false
        case .split: return context.width >= 500
        case .auto: return context.isRegularWidth && context.width >= 650
        }
    }

    private static func rows(for context: KeyboardContext) -> [KeyboardRow] {
        switch context.layer {
        case .alphabetic:
            return alphabeticRows(
                shiftState: context.shiftState,
                showsInputModeSwitchKey: context.showsInputModeSwitchKey
            )
        case .numeric:
            return numericRows(showsInputModeSwitchKey: context.showsInputModeSwitchKey)
        case .symbols:
            return symbolRows(showsInputModeSwitchKey: context.showsInputModeSwitchKey)
        }
    }

    private static func alphabeticRows(
        shiftState: ShiftState,
        showsInputModeSwitchKey: Bool
    ) -> [KeyboardRow] {
        let symbolSecondaries: [String: String] = [
            "q": "1", "w": "2", "e": "3", "r": "4", "t": "5",
            "y": "6", "u": "7", "i": "8", "o": "9", "p": "0",
            "a": "@", "s": "#", "d": "$", "f": "_", "g": "&",
            "h": "-", "j": "+", "k": "(", "l": ")",
            "z": "*", "x": "\"", "c": "'", "v": ":", "b": ";",
            "n": "!", "m": "?"
        ]
        func character(_ value: Character) -> KeyDefinition {
            let lowercase = String(value)
            let primary = shiftState.usesUppercaseLetters ? lowercase.uppercased() : lowercase
            let alternate = symbolSecondaries[lowercase]
            return KeyDefinition(id: lowercase, primary: primary, alternate: alternate)
        }

        let first = Array("qwertyuiop").map(character)
        let second = Array("asdfghjkl").map(character)
        let third = [
            KeyDefinition(id: "shift", primary: shiftState == .capsLock ? "⇪" : "⇧", role: .shift, widthWeight: 1.35),
            character("z"), character("x"), character("c"), character("v"), character("b"), character("n"), character("m"),
            KeyDefinition(id: "backspace", primary: "⌫", role: .backspace, widthWeight: 1.35)
        ]
        var bottom = [
            KeyDefinition(id: "numeric", primary: "123", role: .numericMode, widthWeight: 1.25),
            KeyDefinition(id: "comma-bottom", primary: ","),
            KeyDefinition(id: "space", primary: "space", role: .space, widthWeight: 4.4),
            KeyDefinition(id: "period-bottom", primary: "."),
            KeyDefinition(id: "return", primary: "return", role: .returnKey, widthWeight: 1.4)
        ]
        if showsInputModeSwitchKey {
            bottom.insert(KeyDefinition(id: "globe", primary: "globe", role: .globe), at: 1)
        }
        return [KeyboardRow(keys: first), KeyboardRow(keys: second), KeyboardRow(keys: third), KeyboardRow(keys: bottom)]
    }

    private static func numericRows(showsInputModeSwitchKey: Bool) -> [KeyboardRow] {
        let row1 = keyRow("1234567890")
        let row2 = ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]
        let row3 = [
            KeyDefinition(id: "symbols", primary: "#+=", role: .symbolMode, widthWeight: 1.35),
            KeyDefinition(id: "period", primary: "."), KeyDefinition(id: "comma", primary: ","),
            KeyDefinition(id: "question", primary: "?"), KeyDefinition(id: "exclamation", primary: "!"),
            KeyDefinition(id: "apostrophe", primary: "'"),
            KeyDefinition(id: "backspace", primary: "⌫", role: .backspace, widthWeight: 1.35)
        ]
        return [KeyboardRow(keys: row1), KeyboardRow(keys: row2.map(symbolKey)), KeyboardRow(keys: row3), controlRow(showsInputModeSwitchKey: showsInputModeSwitchKey, leading: .alphabeticMode, label: "ABC")]
    }

    private static func symbolRows(showsInputModeSwitchKey: Bool) -> [KeyboardRow] {
        let row1 = ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="]
        let row2 = ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"]
        let row3 = [
            KeyDefinition(id: "numeric", primary: "123", role: .numericMode, widthWeight: 1.35),
            KeyDefinition(id: "period", primary: "."), KeyDefinition(id: "comma", primary: ","),
            KeyDefinition(id: "question", primary: "?"), KeyDefinition(id: "exclamation", primary: "!"),
            KeyDefinition(id: "apostrophe", primary: "'"),
            KeyDefinition(id: "backspace", primary: "⌫", role: .backspace, widthWeight: 1.35)
        ]
        return [KeyboardRow(keys: row1.map(symbolKey)), KeyboardRow(keys: row2.map(symbolKey)), KeyboardRow(keys: row3), controlRow(showsInputModeSwitchKey: showsInputModeSwitchKey, leading: .alphabeticMode, label: "ABC")]
    }

    private static func keyRow(_ characters: String) -> [KeyDefinition] {
        characters.map { symbolKey(String($0)) }
    }

    private static func symbolKey(_ value: String) -> KeyDefinition {
        KeyDefinition(id: "symbol-\(value)", primary: value)
    }

    private static func controlRow(showsInputModeSwitchKey: Bool, leading: KeyRole, label: String) -> KeyboardRow {
        var keys = [
            KeyDefinition(id: "mode", primary: label, role: leading, widthWeight: 1.25),
            KeyDefinition(id: "comma-bottom", primary: ","),
            KeyDefinition(id: "space", primary: "space", role: .space, widthWeight: 4.4),
            KeyDefinition(id: "period-bottom", primary: "."),
            KeyDefinition(id: "return", primary: "return", role: .returnKey, widthWeight: 1.4)
        ]
        if showsInputModeSwitchKey {
            keys.insert(KeyDefinition(id: "globe", primary: "globe", role: .globe), at: 1)
        }
        return KeyboardRow(keys: keys)
    }
}
