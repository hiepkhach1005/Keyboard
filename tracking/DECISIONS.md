# Decision log

Append durable decisions. If one changes, add a superseding entry.

## ADR-001 — Native extension architecture

- Date: 2026-08-22
- Status: accepted
- Decision: Native Swift containing app and `UIInputViewController` extension; testable shared input/layout/gesture modules; SwiftUI/UIKit only at boundaries.
- Reason: system-wide keyboards require the extension API, while pure logic makes Telex and gestures testable.

## ADR-002 — Offline, no Full Access by default

- Date: 2026-08-22
- Status: accepted
- Decision: English, Telex, settings, and layout work offline; MVP stores only preferences in the App Group.
- Reason: keyboard text is sensitive and requested core features need no network.

## ADR-003 — Familiar, not cloned

- Date: 2026-08-22
- Status: accepted
- Decision: Follow public APIs, platform patterns, semantics, and accessibility; do not copy private assets or claim exact Apple geometry.

## ADR-004 — Compatibility and Liquid Glass

- Date: 2026-08-22
- Status: proposed until first build
- Decision: iOS/iPadOS 17 deployment with availability-gated Liquid Glass on 26+, plus semantic/accessibility fallbacks. Confirm with installed Xcode SDK in P0.

## ADR-005 — Offline swipe and candidate bar; no unofficial Google endpoint

- Date: 2026-08-23
- Status: accepted
- Decision: Ship deterministic swipe decoding, bundled offline next-word candidates, and user-selectable themes without Full Access. Do not call a scraped or undocumented Google autocomplete endpoint.
- Reason: keyboard text is sensitive; a network provider would require explicit consent, Full Access, privacy disclosures, retention/minimization controls, and an official API/licensing path. The feature boundary stays provider-agnostic so an approved provider can be added later without changing gesture or UI contracts.

## ADR-006 — Apple on-device lexicon plus offline ranking

- Date: 2026-08-23
- Status: accepted
- Decision: Use public `UITextChecker` only as an on-device prefix-completion adapter at the extension boundary. Merge it with a project-authored weighted English/Vietnamese lexicon; rank swipe key paths with offline edit distance, subsequence matching, and frequency weights. Keep next-word candidates and all fallback behavior offline.
- Reason: this improves common prefix and swipe cases without Full Access, typed-text upload, undocumented endpoints, third-party dependencies, or uncertain corpus licenses. If Apple has no Vietnamese lexicon on a device, the bundled provider still returns deterministic candidates.
