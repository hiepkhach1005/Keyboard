# Delivery backlog

Statuses: `todo`, `in_progress`, `blocked`, `done`. `done` requires history evidence.

## P0 — Foundation

- `in_progress` Scaffold Swift Package/core and Apple app/extension targets.
  - `Keyboard.xcodeproj`, shared scheme, configurable IDs, local package products, and extension embedding are present. Xcode project listing/package resolution and an iPhone 17 simulator build pass; iPad simulator matrix remains.
  - Acceptance: project lists; placeholder app/extension compile for available iPhone/iPad simulators; IDs are configurable placeholders.
- `done` Add `InputCore`, `SharedSettings`, executable validation, and Xcode-ready unit-test sources.
  - Evidence: `swift test` package compilation and `swift run CoreValidation` pass; XCTest execution awaits full Xcode SDK.
  - Acceptance: tests run with meaningful smoke tests; no circular dependencies.
- `in_progress` Add extension lifecycle and adaptive surface.
  - Source reloads App Group settings on appearance, hosts SwiftUI, requests adaptive keyboard height, handles globe/language controls, and performs initial proxy edits. Simulator and device builds pass; corrected host-field visual verification is pending.
  - Acceptance: controller hosts keyboard, reacts to bounds, and has functioning globe/input-mode control.

## P1 — Input foundation

- `in_progress` Data-driven English alphabetic/numeric/symbol layout model and adaptive geometry.
- `in_progress` Pure gesture state machine with exactly-once primary/alternate result.
- `in_progress` Wire secondary legends and configurable long press into the Apple extension UI.
  - Source now uses a bounded SwiftUI drag/hold gesture and `KeyIntent`; full Xcode compile/manual host verification is pending.
- `in_progress` Backspace repeat, shift/caps, space, return, numeric and symbol layers are implemented at source level; Xcode/runtime verification pending.
- `in_progress` Swipe typing path recognition is implemented as a deterministic, exactly-once surface gesture and now ranks collapsed paths against the offline lexicon; real-device latency and multi-touch verification remain.

Acceptance: timing/cancellation/control tests pass; simulator shows no double commit; delay persists/clamps.

## P2 — Vietnamese Telex

- `done` Pure composer and edit-operation model.
- `in_progress` Table corpus, tone placement, case, toggle/removal, boundaries.
- `in_progress` Proxy integration, composition deletion, and bounded suffix reconciliation are implemented at source level; host/runtime test matrix remains.

Acceptance: `docs/TELEX_SPEC.md` passes and manual context-loss scenarios do not persist user text.

## P3 — Adaptive iPad

- `in_progress` Width-driven full layout.
- `in_progress` `Auto`/`Full`/`Split` preference and split geometry.
- `todo` Portrait, landscape, narrow multitasking, floating verification.

Acceptance: no overlaps/out-of-bounds, empty center gap, recorded simulator matrix, explicit device status.

## P4 — App and appearance

- `in_progress` Onboarding, enable/switch guide, privacy screens, settings, preview, and test field are implemented at source level; Xcode/UI verification pending.
- `in_progress` Original VuongKey 1024×1024 icon is wired and emitted by Asset Catalog; final visual approval and App Store validation remain.
- `in_progress` Semantic light/dark UI uses standard components; explicit Liquid Glass/runtime fallback review pending.
- `in_progress` Core VoiceOver labels are present; full accessibility matrix pending.
- `in_progress` Offline next-word candidate strip, Apple on-device prefix completion, weighted swipe ranking, swipe/theme settings, and six custom palettes are implemented; host-field, accessibility, and iPad visual verification remain.

## P5 — Hardening

- `todo` Host/lifecycle integration, performance and memory profiling.
- `todo` Representative real-device verification.
- `in_progress` App Store privacy/signing/entitlement review; manifests, metadata drafts, policy, and release checklist added, developer-owned release inputs pending.
- `blocked` Google-backed next-word provider. No official general keyboard-prediction API/licensing/privacy contract is approved; keep the shipped provider offline until those inputs exist.
