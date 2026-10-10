# Repository instructions

## Mission

Build a privacy-first native custom keyboard for iPhone and iPad. It should feel familiar to Apple-keyboard users while adding visible secondary characters, configurable long press, English and Vietnamese Telex, and an ergonomic split iPad layout. “Apple-like” means familiar behavior and platform conventions, not copied proprietary assets or private APIs.

## Required context at session start

Before planning or editing, read `tracking/PROJECT_STATUS.md`, `tracking/BACKLOG.md`, the newest relevant entries in `tracking/HISTORY.md` and `tracking/DECISIONS.md`, then task-specific files under `docs/`. Inspect code and tests before trusting a “done” label. If tracking disagrees with the repository, correct tracking to observable reality.

## Product and engineering rules

- Use Swift and public Apple frameworks. Base the keyboard target on `UIInputViewController`; SwiftUI may be hosted inside it.
- Keep containing app and extension separate, with shared platform-light modules where practical.
- Default to offline operation and no Full Access. Never log typed/surrounding text, credentials, or clipboard contents.
- Store only settings in the App Group. A network feature requires explicit approval, privacy documentation, and a decision record.
- Key-down feedback must not wait for language processing, disk I/O, or animation completion.
- Use data-driven layouts, relative metrics, semantic colors, accessibility labels, Reduce Motion, Increase Contrast, and Reduce Transparency fallbacks.
- Support compact/regular widths, rotation, iPad multitasking, and floating keyboard. Split mode is a layout strategy, not a device check.
- Telex and long-press behavior require unit tests. Layout requires geometry/snapshot tests plus simulator/device notes.
- Do not claim pixel-perfect parity with Apple's private keyboard. Project tokens are not Apple specifications.
- Do not add third-party dependencies without clear need and user approval.

## Change discipline

- Work on one backlog item or stated slice at a time and preserve unrelated user changes.
- Run the available build/tests after meaningful changes. If no project exists, say so explicitly.
- Before ending a material session, update `tracking/PROJECT_STATUS.md` and append to `tracking/HISTORY.md`. History must list changed files, verification, risks, and one exact next step.
- A feature is done only when implementation, automated tests, relevant accessibility/privacy behavior, and tracking are updated.

## Code review rules

- Flag any gesture path that can emit both primary and alternate output.
- Flag text capture, persistence, analytics, or networking unless explicitly approved and documented.
- Flag layout constants that assume one screen size or ignore floating/multitasking widths.
- Flag Telex logic embedded in views or dependent on network services.
- Flag unavailable Liquid Glass APIs without availability guards/fallbacks.
- Flag completed tracking items without test evidence.
