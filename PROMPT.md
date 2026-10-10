# Master implementation prompt

Copy the prompt below into Codex from the repository root.

---

You are the lead iOS/iPadOS engineer and interaction designer for this repository. Build a production-quality system-wide custom keyboard extension plus a containing settings app. Work autonomously in small, verifiable vertical slices and preserve existing user changes.

First read `AGENTS.md`, `.agents/skills/ios-keyboard-engineer/SKILL.md`, all tracking files, then relevant documents under `docs/`. Inspect the repository before deciding what exists. Source code and test results are evidence; plans are not.

Build a native keyboard that feels familiar to Apple-keyboard users without copying private assets or APIs. It must provide visible secondary legends below primary legends, configurable long-press delay, English and Vietnamese Telex, adaptive iPhone/iPad layouts, and an ergonomic iPad `Auto`/`Full`/`Split` mode. Include a containing app for onboarding, enable instructions, languages, hold delay, layout preference, appearance preview, privacy explanation, and a typing test field.

Core typing must work offline without Full Access. Do not collect or transmit typed text. Use `UIInputViewController`, `UITextDocumentProxy`, Swift, SwiftUI/UIKit, public APIs, and SF Symbols. Keep input logic independent from UI and host APIs.

Required behavior:

1. A tap commits exactly the primary output. A hold beyond the setting commits exactly the alternate output; it can never also emit primary.
2. Clamp hold delay to 150–1000 ms, initially defaulting to 350 ms, persisted through a settings-only App Group.
3. Switch English/Vietnamese from the keyboard and retain the Apple-provided globe/input-mode path.
4. Telex supports `aa/aw/dd/ee/oo/ow/uw`, `s/f/r/x/j`, removal with `z`, case, repeat behavior, punctuation boundaries, composition-aware deletion, and modern tone placement per `docs/TELEX_SPEC.md`.
5. Generate layouts from data and actual available width. Respond to supported keyboard traits. Never depend only on a model name or `UIScreen.main.bounds`.
6. Split iPad layout creates reachable left/right groups and an empty center gap, with graceful narrow/floating fallback.
7. Backspace tap/repeat cannot race composition state.
8. Provide VoiceOver labels/hints, readable contrast, generous hit behavior, and Reduce Motion/Transparency and Increase Contrast support.
9. Availability-gate Liquid Glass and use it sparingly for grouped chrome, never an expensive independent effect per key.

Separate key/layout models, layout engine, gesture state machine, Telex composer, document-proxy adapter, settings store, keyboard UI, and containing-app UI. Prefer pure deterministic functions for composer/layout logic.

Follow milestone order in `tracking/BACKLOG.md`. For each slice, state acceptance criteria, implement the smallest coherent change, add tests, build app/extension for available iPhone and iPad simulators, distinguish simulator from device evidence, and update status/history before stopping. Record durable changes in `tracking/DECISIONS.md`.

Do not mark features complete from documentation/mockups alone. If signing, App Group identifiers, Xcode, or device-only behavior blocks validation, continue safe testable work and record the exact blocker and next command.

Begin with the first unblocked P0 item. End with outcome, changed files, tests/builds and results, limitations, and the next executable step.

---

## Resume prompt

Use `$ios-keyboard-engineer`. Read the repository instructions/tracking, verify state against code/tests, continue the highest-priority unblocked backlog item, complete one coherent tested slice, and update status/history before stopping.
