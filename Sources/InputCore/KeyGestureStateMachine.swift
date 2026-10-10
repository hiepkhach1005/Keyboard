import Foundation

public struct KeyGestureStateMachine: Sendable {
    public enum State: Equatable, Sendable {
        case idle
        case pressing
        case alternateArmed
        case committed
        case cancelled
    }

    public private(set) var state: State = .idle
    public let key: KeyDefinition
    public let holdDuration: TimeInterval
    private var didCommit = false

    public init(key: KeyDefinition, holdDuration: TimeInterval) {
        self.key = key
        self.holdDuration = min(max(holdDuration, 0.15), 1.0)
    }

    public mutating func touchDown() -> KeyIntent? {
        guard state == .idle else { return nil }
        state = .pressing
        return nil
    }

    public mutating func advance(elapsed: TimeInterval) -> KeyIntent? {
        guard state == .pressing, key.alternate != nil, elapsed >= holdDuration else { return nil }
        state = .alternateArmed
        return nil
    }

    public mutating func touchUp() -> KeyIntent? {
        guard !didCommit else { return nil }
        defer { didCommit = true; state = .committed }
        switch state {
        case .pressing, .idle:
            return intent(for: key.primary)
        case .alternateArmed:
            return intent(for: key.alternate ?? key.primary)
        case .committed, .cancelled:
            return nil
        }
    }

    public mutating func cancel() {
        guard state != .committed else { return }
        state = .cancelled
    }

    private func intent(for output: String) -> KeyIntent {
        switch key.role {
        case .character: return .insert(output)
        default: return .control(key.role)
        }
    }
}
