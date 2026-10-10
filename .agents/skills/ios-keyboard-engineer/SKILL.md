---
name: ios-keyboard-engineer
description: Build, debug, test, or review this repository's native iPhone/iPad custom keyboard, including Apple-like adaptive layouts, long-press secondary characters, English input, Vietnamese Telex, split iPad mode, settings, privacy, and Liquid Glass. Do not use for unrelated iOS applications.
---

# iOS Keyboard Engineer

Build a system-wide custom keyboard extension and its containing settings app with native Swift, SwiftUI, and UIKit. Preserve the user's intent, existing code, privacy defaults, and Apple extension constraints.

## Start every task

1. Read `AGENTS.md`.
2. Read `tracking/PROJECT_STATUS.md`, then the newest relevant entries in `tracking/HISTORY.md`, `tracking/DECISIONS.md`, and `tracking/BACKLOG.md`.
3. Inspect the repository and tests. Do not infer implementation status from plans or documentation.
4. Load only the reference relevant to the current task:
   - Product scope: `docs/PRODUCT_SPEC.md`
   - Architecture: `docs/ARCHITECTURE.md`
   - Layout: `docs/APPLE_LAYOUT_GUIDE.md`
   - Liquid Glass: `docs/LIQUID_GLASS_GUIDE.md`
   - Vietnamese input: `docs/TELEX_SPEC.md`
   - Privacy: `docs/PRIVACY_AND_LIMITATIONS.md`
   - Verification: `docs/TEST_PLAN.md`

## Implementation invariants

- Keep the input engine, layout model, gesture state machine, rendering, settings storage, and `UITextDocumentProxy` adapter separable and unit-testable.
- Represent layouts and alternate characters as data; do not scatter mappings through view code.
- Treat key interaction as a state machine. One gesture commits at most one intended output.
- Reconcile Telex state with `documentContextBeforeInput`; never assume host context stayed unchanged.
- Keep core typing offline. Do not request Full Access for core features.
- Adapt from actual available width and traits, not device model names or global screen bounds.
- Use public APIs and SF Symbols. Do not copy Apple or Google proprietary assets.
- Availability-gate Liquid Glass and keep a readable fallback. Do not apply glass independently to every key.
- Add deterministic tests for transformations and layout invariants before visual polish.

## Work and handoff

Implement the smallest vertical slice satisfying the selected backlog item. Run proportionate tests and record exact commands/results. Before ending a material session, update `tracking/PROJECT_STATUS.md`, append to `tracking/HISTORY.md`, and update decisions/backlog only when their truth changed. Never mark a feature complete unless its acceptance criteria were exercised; label simulator-only evidence accurately.
