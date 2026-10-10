import Foundation

/// A point sampled from the keyboard surface while the user drags across keys.
public struct SwipePoint: Equatable, Sendable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

/// Converts a continuous drag into a sequence of character keys.
///
/// This deliberately contains no dictionary or network dependency. A swipe is
/// a deterministic key-path recognizer; a suggestion provider can rank or
/// replace its result later without changing the gesture contract.
public struct SwipeTypingEngine: Sendable {
    public let minimumTravel: Double
    public let minimumDistinctKeys: Int

    public init(minimumTravel: Double = 24, minimumDistinctKeys: Int = 2) {
        self.minimumTravel = max(0, minimumTravel)
        self.minimumDistinctKeys = max(1, minimumDistinctKeys)
    }

    /// Returns the collapsed character path before language-model ranking.
    /// Keeping this separate lets the UI pass the path to an offline or
    /// approved future provider without changing gesture consumption rules.
    public func keySequence(points: [SwipePoint], layout: KeyboardLayout) -> String {
        guard points.count >= 2, travel(of: points) >= minimumTravel else { return "" }

        var keyIDs: [String] = []
        var outputs: [String] = []
        for point in points {
            guard let key = characterKey(at: point, layout: layout) else { continue }
            guard keyIDs.last != key.id else { continue }
            keyIDs.append(key.id)
            outputs.append(key.primary)
        }

        guard keyIDs.count >= minimumDistinctKeys else { return "" }
        return outputs.joined()
    }

    public func decode(points: [SwipePoint], layout: KeyboardLayout) -> String {
        keySequence(points: points, layout: layout)
    }

    private func characterKey(at point: SwipePoint, layout: KeyboardLayout) -> KeyDefinition? {
        for frame in layout.frames where frame.row < layout.rows.count {
            guard frame.column < layout.rows[frame.row].keys.count else { continue }
            guard frame.x...frame.maxX ~= point.x, frame.y...frame.maxY ~= point.y else { continue }
            let key = layout.rows[frame.row].keys[frame.column]
            return key.role == .character ? key : nil
        }
        return nil
    }

    private func travel(of points: [SwipePoint]) -> Double {
        zip(points, points.dropFirst()).reduce(0) { total, pair in
            let dx = pair.1.x - pair.0.x
            let dy = pair.1.y - pair.0.y
            return total + (dx * dx + dy * dy).squareRoot()
        }
    }
}
