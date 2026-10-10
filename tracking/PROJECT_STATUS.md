# Project status

Last updated: 2026-08-23 (Asia/Ho_Chi_Minh)

## Current truth

- P0–P4 source implementation is in progress; core modules and a full containing-app flow are present.
- Prefix suggestions now merge Apple's on-device `UITextChecker` (when the selected language is available) with a weighted offline English/Vietnamese lexicon. Swipe paths are ranked offline with normalized edit distance, subsequence matching, and frequency weights; no network or Full Access is needed.
- Repo contains AI instructions, a repo-local skill, product/architecture/design specifications, and tracking.
- Swift Package/core source, executable validation, tests, Keyboard Extension source, containing-app onboarding/setup/test/settings/privacy screens, plist/entitlements, privacy manifests, and a shared Xcode scheme are present.
- `Keyboard.xcodeproj` now defines the containing app and embedded Custom Keyboard Extension, links the local `InputCore`/`SharedSettings` products, and applies shared configuration.
- Working product identity is `VuongKey` with `com.bavuong.vuongkey`, `com.bavuong.vuongkey.keyboard`, and `group.com.bavuong.vuongkey`; App Store/trademark availability is not yet verified.
- A working 1024×1024 VuongKey app icon and Asset Catalog are present. No distribution archive or TestFlight build exists yet; manual host-field keyboard verification is still pending.
- Full Xcode 26.6 and the iOS 26.5 platform/runtime are installed. The active `xcode-select` still points to Command Line Tools, so commands explicitly set `DEVELOPER_DIR`.
- The app and embedded keyboard extension compile successfully for an iPhone 17 simulator destination with iOS 26.5 and deployment target iOS 17.0.
- The connected iPhone 13 mini (`development iPhone`) runs iOS 18.5, is paired, has Developer Mode enabled, and exposes developer services.
- Team `YOUR_TEAM_ID` automatic development signing succeeds for both targets, including the shared App Group.
- VuongKey 1.0.0 (1), including the adaptive-height keyboard, Gboard-style secondary legends, key-press preview, system control icons, corrected Telex placement, swipe typing, offline candidates, selectable themes, and app icon, is installed and the containing app launches on the connected iPhone.
- Device screenshot comparison showed the initial corrected surface was still too tall. The controller now requests 208 pt compact portrait, 162 pt compact landscape, or 264 pt regular-width height; at 208 pt the four rows produce 44.5 pt keycaps with the current insets/gaps.
- The custom VI/EN key is removed. A native iOS input-mode/emoji control is kept in the key row; iOS also owns the separate safe-area globe on Face ID devices.
- Character keys now show small secondary legends at the lower trailing edge, a large press preview, and configurable long-press alternates. Return, Shift, and Delete use SF Symbols.
- Secondary legends now cover character keys in all three alphabetic rows and use the same Gboard-style number/symbol mapping in English and Vietnamese. Visible alternates no longer include `ă/đ/ê/ô/ư`; those remain available through Telex sequences. The bottom row is `123`, native input-mode/emoji control, comma, space, period, and Return.
- Telex accepts representative flexible tone orders such as `tieesng` and `tieengs`; delayed `w` also rewrites the nearest eligible vowel nucleus, so `vuongw` → `vương`, `vuongsw` → `vướng`, and `dduongwf` → `đường`. A partially marked `ưo` nucleus is normalized automatically, so both `vưong` and `vuwong` produce `vương` while preserving letter case.
- Swipe typing is implemented as an exactly-once surface gesture and now maps collapsed paths such as `helo` to `hello` and `vuong` to `vương`. Next-word candidates remain bundled offline for English and Vietnamese, while prefix candidates can use Apple's on-device lexicon. Swipe and candidate behavior can be disabled independently; theme choices are stored in App Group settings.

## Decisions in force

- Native Swift; `UIInputViewController` with reusable SwiftUI/UIKit components.
- Offline core without Full Access; no unofficial Google autocomplete endpoint is used.
- Apple `UITextChecker` is an on-device prefix provider only; the bundled provider is always the fallback and next-word ranking remains offline.
- Recommended iOS/iPadOS 17 baseline; Liquid Glass gated to 26+.
- Hold defaults to 350 ms, clamped 150–1000 ms.

## Active milestone

P1/P4 input and appearance — simulator compilation, device signing, installation, and core validation pass; manual host-field and iPad verification remain.

## Exact next step

Switch away from and back to VuongKey in an iPhone text field, then verify a swipe word, candidate replacement, each new setting toggle, and `vưong`/`vuwong`/`VƯONG` on device.

## Inputs/blockers

Manual on-device confirmation of the corrected keyboard surface, swipe gesture, candidate bar, and themes is still required. Support contact/URL and hosted privacy-policy URL are unknown. The working name, identifiers, and generated icon must be approved/confirmed for App Store release. A Google-backed provider remains blocked pending an official API, licensing, privacy, and Full Access decision. `docs/APP_STORE_RELEASE.md` records release blockers.

## Last verification

`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun swift test` passes 21 tests, including collapsed-repeat/Vietnamese swipe ranking, offline candidate ranking, theme/settings migration, automatic `ưo` → `ươ` normalization, and exact replacement edits. `swift run CoreValidation` passes. Simulator and signed generic iOS device builds succeed; the latest signed build installed successfully on the connected iPhone 13 mini and the containing app launched. Manual host-field verification remains pending.

## 2026-10-10 — Prepare public GitHub source publication

- Refreshed the root README with the product workflow, implemented features, source-build steps, and development-preview limitations.
- Added ignore rules for local metadata, build outputs, generated SARIF reports, signing material, environment files, and private configuration.
- Ran Gitleaks against the Git candidate file snapshot and reviewed findings; no actual credentials were identified.
- Checked README relative links and image references. Application behavior was not changed and app build/test suites were not run for this documentation/publication task.
- Git commits use the account's GitHub noreply address.
- Moved the local development team into ignored `Signing.local.xcconfig`; `xcodebuild -showBuildSettings` confirms the app and extension still resolve local signing settings. Public tracking uses generic team/device labels.
