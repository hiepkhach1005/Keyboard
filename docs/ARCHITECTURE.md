# Architecture

```text
KeyboardApp (SwiftUI settings/onboarding)
  -> SharedSettings
  -> KeyboardUIComponents (preview)

KeyboardExtension (UIInputViewController)
  -> KeyboardUIComponents
  -> InputCore
  -> SharedSettings
  -> DocumentProxyAdapter

InputCore
  -> key/layer models
  -> adaptive layout calculations
  -> key gesture state machine
  -> swipe path decoder
  -> offline suggestion engine (weighted lexicon, next-word candidates, swipe ranking)
  -> Telex composer

AppleTargets/KeyboardExtension
  -> AppleTextCheckerProvider (`UITextChecker`, on-device only)
```

Dependencies point inward: platform UI depends on deterministic core logic, never the reverse.

## Core contracts

- `KeyDefinition`: ID, primary/alternate output and legends, role, width weight, accessibility text.
- `KeyboardContext`: language, shift, keyboard/return traits, available size, layout preference.
- `LayoutMetrics`: frames, gaps, center gap, radii, legend scale and hit geometry.
- `KeyGestureState`: idle, pressing primary, alternate armed, cancelled, committed.
- `CompositionState`: source/rendered token plus a bounded host-context fingerprint.

```text
touch -> gesture state machine -> KeyIntent -> InputCoordinator
                                             |-> TelexComposer
                                             |-> control/settings
TelexComposer -> abstract text edits -> DocumentProxyAdapter -> UITextDocumentProxy
```

Swipe recognition is a surface-level simultaneous gesture that shares a
consumption marker with key gestures, so one drag cannot also commit its first
key as a tap. The decoder exposes a collapsed key sequence, then the offline
provider ranks it with normalized edit distance, subsequence shape, and
project-authored frequency weights (for example, `helo` -> `hello` and
`vuong` -> `vương`). Candidate ranking receives only the current token and
immediately previous word. Prefix candidates are merged from Apple's on-device
`UITextChecker` when that language is available and the bundled provider; next-
word candidates remain bundled and stateless. Theme selection is stored as a
semantic palette identifier in `SharedSettings` and resolved at the UI boundary.

The composer returns edits rather than calling UIKit. The main-actor adapter applies edits and rechecks host context.

## Settings and lifecycle

Use versioned App Group `UserDefaults` keys for enabled/active language, hold milliseconds, secondary legends, iPad preference, tone-placement preference, and appearance. Put identifiers in build configuration.

Treat extension memory/lifetime as constrained. Cancel timers and composition on cancellation/context changes. Recompute from the extension view's bounds. Expect secure fields, some phone pads, or opt-out apps to reject the extension. Keep the system input-mode control reachable.

Recommended baseline: iOS/iPadOS 17; availability-gate iOS/iPadOS 26 Liquid Glass. Confirm against installed Xcode during P0.
