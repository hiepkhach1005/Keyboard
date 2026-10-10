# Session history

Append entries and keep newest at the top. Never rewrite past evidence.

## 2026-08-23 — Apple on-device completions and ranked swipe typing

### Outcome

Replaced the tiny candidate corpus with a project-authored weighted English/Vietnamese lexicon and next-word table. Prefix suggestions now merge Apple's public on-device `UITextChecker` results with the offline fallback; no Full Access, network call, or typed-text persistence was added. Swipe decoding now exposes the collapsed key path and ranks close words using normalized diacritic folding, Levenshtein distance, subsequence matching, and frequency weights, so paths such as `helo` and `vuong` resolve to `hello` and `vương`. Swipe insertion replaces the current token atomically and preserves capitalization.

### Changed files

- `Sources/InputCore/SuggestionEngine.swift`
- `Sources/InputCore/SwipeTypingEngine.swift`
- `AppleTargets/KeyboardExtension/AppleTextCheckerProvider.swift`
- `AppleTargets/KeyboardExtension/KeyboardViewController.swift`
- `Keyboard.xcodeproj/project.pbxproj`
- `Tests/InputCoreTests/InputCoreTests.swift`, `Sources/CoreValidation/main.swift`
- `AppleTargets/KeyboardApp/KeyboardSettingsView.swift`
- `docs/ARCHITECTURE.md`, `docs/PRIVACY_AND_LIMITATIONS.md`, `docs/TEST_PLAN.md`
- `tracking/PROJECT_STATUS.md`, `tracking/BACKLOG.md`, `tracking/DECISIONS.md`, `tracking/HISTORY.md`

### Verification

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun swift test` — 21 tests passed, 0 failures.
- `swift run CoreValidation` — all checks passed, including `helo` → `hello` and `vuong` → `vương` ranking.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project Keyboard.xcodeproj -scheme Keyboard -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -configuration Debug CODE_SIGNING_ALLOWED=NO build` — succeeded.
- iPad Pro 13-inch (M5) / iOS 26.5 simulator destination build — succeeded.
- Signed generic iOS device build — succeeded for iOS 17 deployment target.
- `devicectl device install app` — latest `com.bavuong.vuongkey` installed on the paired iPhone 13 mini; `devicectl device process launch` — containing app launched.

### Risks and exact next step

`UITextChecker` language availability and actual keyboard behavior still need host-field verification on the device; Vietnamese fallback remains available when Apple's Vietnamese lexicon is absent. Switch to VuongKey in an iPhone text field, test a prefix candidate, swipe `hello`, type `vuongw`, and toggle both smart-input settings. iPad/floating/accessibility matrices and App Store-owned metadata remain open.

## 2026-08-23 — Swipe typing, offline candidates, themes, and settings installed

### Outcome

Added a deterministic swipe-to-type path recognizer, an offline next-word candidate bar for English and Vietnamese Telex, independent settings toggles for both features, and six selectable keyboard palettes plus system/high-contrast fallbacks. Swipe consumption shares an exactly-once marker with key gestures so a drag cannot also commit its starting key as a tap. Candidate replacement edits the current token and adds a boundary without persisting text.

Google-backed suggestions were not shipped: no approved official general keyboard-prediction API/licensing/privacy contract is available, and an unofficial endpoint would require Full Access and App Store review. The provider boundary is documented for a future approved integration.

### Changed files

- `Sources/InputCore/SwipeTypingEngine.swift`
- `Sources/InputCore/SuggestionEngine.swift`
- `Sources/SharedSettings/KeyboardSettings.swift`
- `AppleTargets/KeyboardExtension/KeyboardViewController.swift`
- `AppleTargets/KeyboardApp/KeyboardSettingsView.swift`
- `Tests/InputCoreTests/InputCoreTests.swift`, `Tests/SharedSettingsTests/SharedSettingsTests.swift`
- `Sources/CoreValidation/main.swift`
- `docs/ARCHITECTURE.md`, `docs/PRODUCT_SPEC.md`, `docs/PRIVACY_AND_LIMITATIONS.md`, `docs/TEST_PLAN.md`, `docs/APP_STORE_RELEASE.md`
- `tracking/PROJECT_STATUS.md`, `tracking/BACKLOG.md`, `tracking/DECISIONS.md`, `tracking/HISTORY.md`

### Verification

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun swift test` — 20 tests passed, 0 failures.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun swift run CoreValidation` — all checks passed.
- iPhone 17 / iOS 26.5 simulator build — succeeded.
- Signed generic iOS device build — succeeded with deployment target iOS 17.0.
- Installed `com.bavuong.vuongkey` on the paired iPhone 13 mini / iOS 18.5 and launched the containing app successfully.

### Risks and exact next step

Build and automated checks do not replace host-field verification. Switch away from and back to VuongKey, then test a swipe word, tap a candidate, toggle swipe/candidates, change a theme, and verify `vưong`/`vuwong` in an iPhone text field. iPad/floating/accessibility matrices remain open.

## 2026-08-23 — Automatic `ưo` → `ươ` normalization installed on iPhone

### Outcome

Extended the Telex composer to normalize a partially marked Vietnamese vowel nucleus while typing: `vưong` now becomes `vương`. The same rule supports Telex-derived input (`vuwong` → `vương`), preserves uppercase (`VƯONG` → `VƯƠNG`), and keeps existing free-order input such as `truwowngf` → `trường` working.

### Changed files

- `Sources/InputCore/TelexComposer.swift`
- `Tests/InputCoreTests/InputCoreTests.swift`
- `docs/TELEX_SPEC.md`
- `tracking/PROJECT_STATUS.md`, `tracking/HISTORY.md`

### Verification

- `swift test` — 17 tests passed, including rendered results and the exact proxy replacement edit for `vư` + `o`.
- iPhone 17 / iOS 26.5 simulator build — succeeded with deployment target iOS 17.0.
- Signed generic iOS device build — succeeded.
- Installed `com.bavuong.vuongkey` on the paired iPhone 13 mini / iOS 18.5 and launched the containing app successfully.

### Risks and exact next step

Installation and unit tests do not replace a host-field check. Switch away from and back to VuongKey, then type `vưong`, `vuwong`, and `VƯONG` in an iPhone text field.

## 2026-08-23 — Delayed-`w` build installed on iPhone

### Outcome

Reconnected to the paired iPhone 13 mini, installed the already signed VuongKey build containing free-order trailing `w`, and launched the containing app successfully.

### Verification

- `devicectl list devices` — iPhone available and paired.
- `devicectl device install app` — installed `com.bavuong.vuongkey` successfully.
- `devicectl device process launch` — containing app launched successfully.

### Risks and exact next step

Installation does not prove host-field behavior. Switch away from and back to VuongKey, then type `vuongw`, `vuongsw`, and `dduongwf` in an iPhone text field.

## 2026-08-23 — Free-order trailing `w` for Telex

### Outcome

Extended the pure Telex composer so a delayed `w` searches backward to the nearest eligible `a/o/u` vowel nucleus after trailing consonants. The `uo` nucleus is transformed together, enabling `vuongw` → `vương`; tone keys remain order-flexible, including `vuongsw` → `vướng` and `dduongwf` → `đường`.

### Changed files

- `Sources/InputCore/TelexComposer.swift`
- `Tests/InputCoreTests/InputCoreTests.swift`
- `docs/TELEX_SPEC.md`
- `tracking/PROJECT_STATUS.md`, `tracking/HISTORY.md`

### Verification

- `swift test` — 16 tests passed, including render results and the exact proxy replacement edit for trailing `w`.
- iPhone 17 / iOS 26.5 simulator build — succeeded.
- Signed generic iOS device build — succeeded with deployment target iOS 17.0.
- Installation — not completed because the iPhone changed from connected/preparing to unavailable before `devicectl` installation.

### Risks and exact next step

The latest signed build is ready at `.build/device/Build/Products/Debug-iphoneos/Keyboard.app` but is not yet on the phone. Reconnect/unlock the iPhone, install it, switch back to VuongKey, and type `vuongw` in a host text field.

## 2026-08-23 — Removed Vietnamese letters from secondary legends

### Outcome

Changed Vietnamese alphabetic key legends to use the same number/symbol alternates as English. Removed visible and long-press alternates `ă`, `đ`, `ê`, `ô`, and `ư`; Vietnamese composition remains available through standard Telex input such as `aw`, `dd`, `ee`, `oo`, and `uw`.

### Changed files

- `Sources/InputCore/LayoutEngine.swift`
- `Tests/InputCoreTests/InputCoreTests.swift`
- `tracking/PROJECT_STATUS.md`, `tracking/HISTORY.md`

### Verification

- `swift test` — 15 tests passed, including explicit exclusion of all five Vietnamese quality letters from alternates.
- iPhone 17 / iOS 26.5 simulator build — succeeded.
- Signed iPhone device build — succeeded and installed on the connected iPhone 13 mini / iOS 18.5.

### Risks and exact next step

Long-press now inserts only the displayed symbol; Vietnamese quality letters must be entered using Telex. Switch away from and back to VuongKey, then confirm the legends and type `aw dd ee oo uw` in a text field.

## 2026-08-23 — Device-calibrated height, full legends, punctuation row

### Outcome

Used the user's side-by-side iPhone 13 mini screenshots to recalibrate the keyboard surface from 268 pt to 208 pt in portrait, with 162 pt compact landscape and 264 pt regular-width tokens. Added Gboard-style secondary legends across all three alphabetic rows while preserving Vietnamese long-press letters. Rebuilt the bottom row as `123`, native input-mode/emoji key, comma, space, period, and Return. The native control uses Apple's public input-mode API: tap advances and hold displays the keyboard list containing Emoji when enabled.

### Changed files

- `AppleTargets/KeyboardExtension/KeyboardViewController.swift`
- `Sources/InputCore/LayoutEngine.swift`
- `Tests/InputCoreTests/InputCoreTests.swift`
- `tracking/PROJECT_STATUS.md`, `tracking/HISTORY.md`

### Verification

- `swift test` — 15 tests passed.
- iPhone 17 / iOS 26.5 simulator build — succeeded with deployment target iOS 17.0.
- Signed physical-device build — succeeded.
- Updated app and embedded extension installed on the connected iPhone 13 mini / iOS 18.5; containing app launched.

### Risks and exact next step

iOS does not expose a public API for third-party keyboards to jump directly to Emoji; hold opens the system input-mode list instead. Switch away from and back to VuongKey in an iPhone text field, then capture one portrait screenshot to validate the 208 pt device-calibrated surface and new bottom row.

## 2026-08-23 — Apple-sized keyboard controls, Gboard legends, and press preview

### Outcome

Removed the dedicated VI/EN key, changed the always-present custom globe into the native iOS input-mode control shown only when required, widened the space row, converted Return/Shift/Delete to system icons, moved secondary legends to a compact Gboard-style lower position, and added an Apple-like key-press preview. Corrected Telex tone targeting for `nguyễn` and covered flexible tone order.

### Changed files

- `AppleTargets/KeyboardExtension/KeyboardViewController.swift`
- `Sources/InputCore/KeyboardModels.swift`, `Sources/InputCore/LayoutEngine.swift`, `Sources/InputCore/TelexComposer.swift`
- `Tests/InputCoreTests/InputCoreTests.swift`
- `tracking/PROJECT_STATUS.md`, `tracking/HISTORY.md`

### Verification

- `swift test` — 14 tests passed.
- iPhone 17 / iOS 26.5 simulator build — succeeded with deployment target iOS 17.0.
- Signed iPhone device build — succeeded.
- Updated app and embedded keyboard installed on the connected iPhone 13 mini running iOS 18.5; containing app launched.

### Resume point

Open a text field on the iPhone, switch away from and back to VuongKey, and visually verify the four rows, key popup, secondary legends, system input-mode key, Return icon, and Telex entry in portrait and landscape.

## 2026-08-23 — Keyboard clipping fixed and VuongKey icon installed

### Outcome

Diagnosed the device screenshot showing only scattered characters as a missing explicit `UIInputViewController` height request: SwiftUI received a near-zero height and text overflowed from one-point key frames. Added an adaptive extension height constraint (268 pt compact portrait, 216 pt compact landscape, 320 pt regular width), vertical layout insets, clipping, and familiar centering for the alphabetic home row. Generated an original VuongKey icon with the built-in image-generation tool, resized it to an opaque 1024×1024 PNG, added it to an AppIcon Asset Catalog, then rebuilt, signed, installed, and launched the corrected app on the connected iPhone.

### Verification

- `swift test` — passed package compilation with added layout in-bounds/home-row assertions.
- `swift run CoreValidation` — all checks passed.
- `swiftc -parse AppleTargets/KeyboardApp/*.swift AppleTargets/KeyboardExtension/*.swift` — passed.
- Simulator `xcodebuild` on iPhone 17 / iOS 26.5 — `BUILD SUCCEEDED`; app and extension compiled; Asset Catalog emitted iPhone and iPad icons.
- Physical iPhone 13 mini / iOS 18.5 `xcodebuild` — `BUILD SUCCEEDED` with automatic signing.
- `devicectl device install app` — corrected build installed successfully.
- `devicectl device process launch` — `com.bavuong.vuongkey` launched successfully.
- Final keyboard visual/interaction test — pending user confirmation in a host text field; installation and app launch do not prove extension geometry.

### Changed files

- `AppleTargets/KeyboardExtension/KeyboardViewController.swift`
- `Sources/InputCore/LayoutEngine.swift`
- `Tests/InputCoreTests/InputCoreTests.swift`
- `AppleTargets/KeyboardApp/Assets.xcassets/**`
- `Keyboard.xcodeproj/project.pbxproj`
- `docs/APP_STORE_RELEASE.md`
- `tracking/PROJECT_STATUS.md`, `tracking/BACKLOG.md`, `tracking/HISTORY.md`

### Icon generation

Built-in image generation was used with a `logo-brand` prompt for a centered white geometric V made from keyboard-key forms, a small crown notch, and a full-bleed royal-blue/indigo background. Constraints included no words, watermark, transparency, copied brand assets, border, or pre-rounded outer mask. Final workspace asset: `AppleTargets/KeyboardApp/Assets.xcassets/AppIcon.appiconset/VuongKey-AppIcon-1024.png`.

### Risks

The fixed constants are starting tokens validated by compilation and deterministic geometry only; portrait/landscape host-field screenshots are still required. The generated icon requires the user's aesthetic approval and normal App Store trademark/brand review.

### Resume point

Have the user switch away from and back to VuongKey in a text field, capture portrait and landscape screenshots, then tune height/key typography only if device evidence shows remaining issues.

## 2026-08-23 — VuongKey signed and installed on iPhone

### Outcome

Used Team `YOUR_TEAM_ID` and the new Apple Development identity to automatically provision, compile, and sign both the VuongKey app and keyboard extension for the connected iPhone 13 mini. Xcode created profiles for both bundle IDs with the shared App Group entitlement. Installed VuongKey 1.0.0 (1) successfully. iOS denied the first automated launch because the user has not yet explicitly trusted the development profile.

### Verification

- Physical-device `xcodebuild` with automatic provisioning — `BUILD SUCCEEDED`.
- `codesign --verify --strict` — app and extension valid and satisfy designated requirements.
- Entitlement inspection — both products contain `group.com.bavuong.vuongkey` and Team `YOUR_TEAM_ID`.
- `devicectl device install app` — installed `com.bavuong.vuongkey` successfully.
- `devicectl device info apps` — lists VuongKey 1.0.0 (1).
- Automated launch — denied with iOS security reason that the profile has not been explicitly trusted by the user.

### Changed files

- `Keyboard.xcodeproj/project.pbxproj` (Team/signing settings written by Xcode)
- `tracking/PROJECT_STATUS.md`, `tracking/HISTORY.md`

### Risks

The app/keyboard has not yet been opened or manually exercised on-device. Development-profile trust is a user-controlled security action. Final icon and App Store release inputs remain unresolved.

### Resume point

After the user trusts the developer profile under Settings > General > VPN & Device Management, launch `com.bavuong.vuongkey`, then enable VuongKey under Settings > General > Keyboard > Keyboards and perform the device smoke test.

## 2026-08-23 — Device Developer Mode verified; signing Team required

### Outcome

Verified that Developer Mode is enabled on the paired iPhone 13 mini and that developer disk-image services and the wired tunnel are available. Started a physical-device build with automatic provisioning and device registration enabled. Xcode resolved and prepared all targets but stopped at Apple signing because neither target has a Development Team and the keychain currently contains no valid code-signing identity. Opened `Keyboard.xcodeproj` in Xcode for the account/Team selection step.

### Verification

- `devicectl device info details` — Developer Mode enabled, paired, tunnel connected, DDI services available.
- Physical `xcodebuild` with `-allowProvisioningUpdates -allowProvisioningDeviceRegistration` — reached provisioning; failed with “Signing ... requires a development team” for `Keyboard` and `KeyboardExtension`.
- `security find-identity -v -p codesigning` — 0 valid identities before account setup.

### Changed files

- `tracking/PROJECT_STATUS.md`, `tracking/HISTORY.md`

### Risks

A Personal Team may not provision the App Groups capability. If the user has only a free Apple Account, a Debug-only no-App-Group configuration may be required for basic device testing; shared settings would not synchronize in that mode.

### Resume point

After the user signs into Xcode and selects the same Team for both targets, retry the physical build, inspect any App Group provisioning result, then install and launch the generated app.

## 2026-08-23 — First full Xcode build and physical-device preparation

### Outcome

Installed the Xcode iOS 26.5 platform/runtime, paired the connected iPhone 13 mini, and confirmed it runs iOS 18.5. Fixed Debug simulator architecture selection by enabling `ONLY_ACTIVE_ARCH`, then compiled the VuongKey containing app and embedded Keyboard Extension successfully with deployment target iOS 17.0. Device installation is paused only for the user-controlled Developer Mode step.

### Verification

- `xcodebuild -downloadPlatform iOS` — installed iOS 26.5 (23F77), arm64.
- `devicectl manage pair` — paired `development iPhone` successfully.
- Device details — iPhone 13 mini, iOS 18.5, Developer Mode disabled.
- `xcodebuild ... -destination 'platform=iOS Simulator,id=841F...' CODE_SIGNING_ALLOWED=NO build` — `BUILD SUCCEEDED`; app and extension compiled and embedded.
- Physical build/sign/install — not attempted past destination preparation because iOS explicitly reports Developer Mode disabled.

### Changed files

- `Keyboard.xcodeproj/project.pbxproj`
- `tracking/PROJECT_STATUS.md`, `tracking/BACKLOG.md`, `tracking/HISTORY.md`

### Risks

No local code-signing identity is currently listed. After Developer Mode is enabled, automatic provisioning may still require signing into an Apple Account in Xcode and selecting a Team/App Group for both targets.

### Resume point

After the user enables Developer Mode and reconnects/unlocks the iPhone, run the physical-device build with `-allowProvisioningUpdates`, resolve Team/App Group signing if requested, install the resulting app with `devicectl`, and launch `com.bavuong.vuongkey`.

## 2026-08-22 — VuongKey working identity and iOS 17 confirmation

### Outcome

Selected `VuongKey` as the working product name, derived from Nguyễn Bá Vương while remaining readable internationally. Configured the app display name, keyboard-extension display name, app Bundle ID `com.bavuong.vuongkey`, extension Bundle ID `com.bavuong.vuongkey.keyboard`, and App Group `group.com.bavuong.vuongkey`. Updated the settings fallback, setup instructions, App Store metadata draft, and release checklist. Retained the iOS/iPadOS 17.0 deployment target.

### Verification

- Apple Xcode system requirements for Xcode 26.6 list deployment, device, and Simulator support for iOS 15 or later; iOS 17 is supported.
- `plutil -lint` — project, app/extension Info.plists, and entitlements passed.
- `swift test` — passed package compilation.
- `swift run CoreValidation` — all checks passed.
- `swiftc -parse AppleTargets/KeyboardApp/*.swift AppleTargets/KeyboardExtension/*.swift` — passed.
- `rg` identity audit — no remaining example App Group/Bundle ID or final-name placeholders in active Apple target/source/release documentation.
- iOS 17 simulator/device runtime — not exercised because no iOS runtimes are currently installed.

### Changed files

- `AppleTargets/Configuration/Shared.xcconfig`
- `AppleTargets/KeyboardApp/AppConfiguration.swift`
- `AppleTargets/KeyboardExtension/Info.plist`
- `Sources/SharedSettings/SharedSettingsConfiguration.swift`
- `AppleTargets/README.md`
- `docs/APP_STORE_METADATA.md`, `docs/APP_STORE_RELEASE.md`
- `tracking/PROJECT_STATUS.md`, `tracking/HISTORY.md`

### Risks

The identifiers still need registration/availability confirmation under the user's Apple Developer Team. `VuongKey` App Store-name and trademark availability have not been cleared. The app still lacks a final icon.

### Resume point

Install iOS 17.x or the current iOS simulator runtime from Xcode Settings > Components, select the developer Team and shared App Group on both targets, then build and run VuongKey on an iOS 17 simulator or physical device.

## 2026-08-22 — Xcode app and keyboard-extension project generated

### Outcome

Added `Keyboard.xcodeproj` with a shared `Keyboard` scheme, containing-app and Custom Keyboard Extension targets, extension embedding, local Swift Package product links, target Info.plists/entitlements, privacy-manifest resources, and shared build configuration. Centralized placeholder display name, Bundle IDs, App Group, version, URLs, and Team field in `AppleTargets/Configuration/Shared.xcconfig`. Added exact iPhone installation steps to `AppleTargets/README.md`.

### Verification

- `plutil -lint Keyboard.xcodeproj/project.pbxproj` — passed.
- `plutil -lint` — app/extension Info.plists, entitlements, and privacy manifests passed.
- `swift test` — package compilation passed; XCTest remains unavailable in the Command Line Tools SDK.
- `swift run CoreValidation` — all checks passed.
- `swiftc -parse AppleTargets/KeyboardApp/*.swift AppleTargets/KeyboardExtension/*.swift` — passed.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -runFirstLaunch` — succeeded and installed Xcode's first-launch system components.
- `DEVELOPER_DIR=... xcodebuild -project Keyboard.xcodeproj -list` — passed; listed both targets and the shared scheme and resolved the local package.
- Generic iOS Simulator build — attempted, but stopped before compilation because the iOS 26.5 platform is not installed.
- Signing and device installation — not run because final identifiers/Team are unset and no connected device was supplied.

### Changed files

- `Keyboard.xcodeproj/**`
- `AppleTargets/Configuration/Shared.xcconfig`
- `AppleTargets/KeyboardApp/Info.plist`
- `AppleTargets/README.md`
- `tracking/PROJECT_STATUS.md`, `tracking/BACKLOG.md`, `tracking/HISTORY.md`

### Risks

The project is recognized by Xcode and its package graph resolves, but target compilation still awaits installation of the iOS 26.5 platform. Example identifiers cannot be signed as-is; App Group and Team must be configured for both targets. App icon and final release identity remain absent.

### Resume point

Install the iOS platform in Xcode Settings > Components, select full Xcode, replace example IDs, set the same Team and App Group on both targets, then run the `Keyboard` scheme on a connected iPhone and record the first compile/runtime errors or success.

## 2026-08-22 — Real containing app and App Store preparation

### Outcome

Replaced the single settings form with a complete containing-app flow: first-run onboarding, four-step enable guide, public Settings link, globe-switch instructions, typing test, live feature preview, shared preferences, reset, privacy policy, iOS limitations, and optional support/privacy website links. Added app/extension privacy manifests, fuller Info.plists, metadata/privacy/release documents, App Group configuration resolution, language switching, shift/caps, number/symbol layers, backspace repeat, settings reload, and initial Telex proxy integration with suffix reconciliation.

### Verification

- `swiftc -parse AppleTargets/KeyboardApp/*.swift AppleTargets/KeyboardExtension/*.swift` — passed syntax parsing for all Apple sources.
- `plutil -lint` — passed both Info.plists, both entitlements, and both privacy manifests.
- `swift test` — package compilation passed; local XCTest execution remains unavailable with Command Line Tools.
- `swift run CoreValidation` — all executable core checks passed.
- Full Xcode typecheck, simulator, device, archive, and App Store validation — not run because full Xcode/signing inputs are unavailable.

### Changed files

- `AppleTargets/KeyboardApp/**`, `AppleTargets/KeyboardExtension/**`, `AppleTargets/Configuration/Shared.xcconfig`
- `Sources/InputCore/LayoutEngine.swift`, `Sources/SharedSettings/SharedSettingsConfiguration.swift`
- `docs/APP_STORE_RELEASE.md`, `docs/APP_STORE_METADATA.md`, `docs/PRIVACY_POLICY.md`, `docs/PRIVACY_AND_LIMITATIONS.md`
- `Tests/SharedSettingsTests/SharedSettingsTests.swift`, tracking files

### Release blockers

Final brand/name, icon, Developer Team, bundle/App Group IDs, hosted privacy URL, support contact/URL, full Xcode target project, signing, device evidence, TestFlight, and App Review metadata remain developer-owned inputs or runtime work.

### Resume point

Install/select full Xcode, create/link both targets, provide the final identifiers and URLs, then run the containing app and enable/switch the keyboard in an iPhone simulator.

## 2026-08-22 — Extension gesture wiring prepared

### Outcome

Connected the Apple-target SwiftUI key surface to `KeyIntent`, secondary-legends visibility, configurable hold delay, movement cancellation, and exactly-once primary/alternate commit behavior. Added extension Info.plist, App Group entitlements, and shared Xcode configuration templates.

### Changed files

- `AppleTargets/KeyboardExtension/KeyboardViewController.swift`
- `AppleTargets/KeyboardExtension/Info.plist`
- `AppleTargets/KeyboardExtension/KeyboardExtension.entitlements`
- `AppleTargets/KeyboardApp/KeyboardApp.entitlements`
- `AppleTargets/Configuration/Shared.xcconfig`
- `AppleTargets/README.md`, `tracking/BACKLOG.md`

### Verification

- `plutil -lint` — all three plist/entitlement files passed.
- `swiftc -parse` — both Apple target Swift files passed syntax parsing.
- Core package and `CoreValidation` remain passing.
- Apple target compile/simulator/manual hold test — not run because full Xcode is unavailable.

### Resume point

Create/link the Xcode app and extension targets, replace the example App Group/bundle identifiers, compile the Apple sources, and test a real host text field.

## 2026-08-22 — Core implementation and validation

### Goal

Start P0/P1 by implementing the platform-neutral keyboard core and prepare Apple target sources.

### Outcome

Added Swift Package modules for data-driven keyboard models/layouts, long-press gesture state, Vietnamese Telex composition/edit operations, and shared settings. Added an executable smoke validator and XCTest sources guarded for the full Apple SDK. Added initial SwiftUI containing-app and `UIInputViewController` source under `AppleTargets/`.

### Changed files

- `Package.swift`, `.gitignore`
- `Sources/InputCore/**`, `Sources/SharedSettings/**`, `Sources/CoreValidation/main.swift`
- `Tests/**`
- `AppleTargets/**`
- `tracking/PROJECT_STATUS.md`, `tracking/BACKLOG.md`

### Verification

- `swift test` — passed package compilation. XCTest is unavailable in the current Command Line Tools SDK, so guarded XCTest classes were not executed locally.
- `swift run CoreValidation` — passed Telex corpus, tone toggle/removal, gesture exactly-once, split bounds, and settings clamp checks.
- `swift build` — passed.
- `xcodebuild -list` / simulator build — not run; current `xcode-select` is `/Library/Developer/CommandLineTools`.

### Risks/limitations

- No `.xcodeproj`, entitlements, signing, real App Group ID, simulator, or device evidence yet.
- Apple target source is prepared but not compiled in this environment.
- Long-press is modeled in `InputCore`; Apple-target wiring was prepared in the follow-up session entry above but awaits Xcode compilation.

### Resume point

Open this folder on a machine with full Xcode, create/link app and extension targets, replace `group.com.example.keyboard`, and run simulator builds before continuing UI integration.

## 2026-08-22 — AI workflow and specification scaffold

### Outcome

Created the master prompt, Codex instructions/config, reusable keyboard skill, Apple/Liquid Glass guidance, product/architecture/Telex/privacy/test specs, and durable tracking.

### Changed files

- `AGENTS.md`, `PROMPT.md`, `.codex/config.toml`
- `.agents/skills/ios-keyboard-engineer/**`
- `docs/**`, `tracking/**`

### Verification

- Bundled `quick_validate.py`: could not run because its environment lacks the `PyYAML` module (`ModuleNotFoundError: yaml`); no dependency was installed into the user's environment.
- Independent Ruby YAML/frontmatter checks: passed for `SKILL.md` and `agents/openai.yaml`.
- Referenced project-file existence check: passed for all instructions, docs, tracking, skill metadata, and config files.
- Xcode build/tests: not run because no Xcode project or Swift source exists.

### Not implemented

No app, extension, Telex engine, keyboard layout, gestures, settings UI, signing, or tests were implemented.

### Resume point

Start P0 in `tracking/BACKLOG.md`: scaffold buildable app, extension, shared core/settings, and tests.

## 2026-10-10 — Prepare public GitHub source publication

- Refreshed the root README with the product workflow, implemented features, source-build steps, and development-preview limitations.
- Added ignore rules for local metadata, build outputs, generated SARIF reports, signing material, environment files, and private configuration.
- Ran Gitleaks against the Git candidate file snapshot and reviewed findings; no actual credentials were identified.
- Checked README relative links and image references. Application behavior was not changed and app build/test suites were not run for this documentation/publication task.
- Git commits use the account's GitHub noreply address.
- Moved the local development team into ignored `Signing.local.xcconfig`; `xcodebuild -showBuildSettings` confirms the app and extension still resolve local signing settings. Public tracking uses generic team/device labels.
