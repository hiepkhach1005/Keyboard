<p align="center">
  <img src="AppleTargets/KeyboardApp/Assets.xcassets/AppIcon.appiconset/VuongKey-AppIcon-1024.png" width="112" alt="VuongKey app icon">
</p>

# VuongKey

**English and Vietnamese. Tap, hold, or swipe. Keep your typing on your device.**

VuongKey is a native keyboard for iPhone and iPad, built around Vietnamese Telex, useful secondary characters, and offline suggestions. The containing app guides you through setup and lets you tune how the keyboard looks and feels.

![iOS and iPadOS 17+](https://img.shields.io/badge/iOS_%2F_iPadOS-17%2B-111827?logo=apple)
![Swift](https://img.shields.io/badge/Swift-native-F05138?logo=swift&logoColor=white)
![Development preview](https://img.shields.io/badge/status-development_preview-amber)

## A keyboard with room for your preferences

- **Vietnamese Telex and English.** Flexible tone-entry order, case preservation, and composition-aware edits.
- **More on each key.** Visible number and symbol legends, press previews, and a configurable long-press delay.
- **Offline swipe and suggestions.** Local swipe ranking and an English/Vietnamese lexicon, with Apple's on-device prefix completion where available.
- **Adapt to your layout.** Width-driven geometry and Full / Split / Auto layout preferences for iPad.
- **Make it yours.** Six custom palettes, system appearance, and independent swipe and suggestion settings.
- **Get set up inside the app.** Onboarding, enable/switch instructions, a typing test, settings, and a privacy screen.

**Full Access is not required.** The keyboard's core features work offline. Typed text is not uploaded, logged, or saved; the shared App Group stores settings.

## Try it from source

Requires **iOS/iPadOS 17+** and **Xcode with Swift 6 support and an iOS SDK**.

```sh
git clone https://github.com/hiepkhach1005/Keyboard.git
cd Keyboard
open Keyboard.xcodeproj
```

1. Select the **Keyboard** scheme and an iPhone simulator or connected device.
2. For a device build, select your development team for the app and keyboard extension. Configure the matching App Group and available bundle identifiers in `AppleTargets/Configuration/Shared.xcconfig`.
3. Run the containing app, then follow its setup guide. Enable VuongKey in **Settings → General → Keyboard → Keyboards → Add New Keyboard** and switch with the globe key.

Local signing overrides can go in `AppleTargets/Configuration/Signing.local.xcconfig`; this file is ignored by Git. See [Apple target setup](AppleTargets/README.md) and the [release checklist](docs/APP_STORE_RELEASE.md).

## Validate the core

```sh
swift build
swift test
swift run CoreValidation
```

The Swift package contains reusable input and settings modules; `Keyboard.xcodeproj` builds the app and extension. Core tests cover Telex, gestures, layout, swipe ranking, and settings.

## Development status

Source implementation, core validation, and previous simulator/device builds are recorded in [project status](tracking/PROJECT_STATUS.md). Broader host-app, iPad, accessibility, and release verification remain in progress. This is a development preview, not an App Store release or a claim of full Apple-keyboard parity.

Questions or a typing edge case? [Open an issue](https://github.com/hiepkhach1005/Keyboard/issues) with an example typed sequence, expected result, and device/OS version. Please use sample text rather than private messages or passwords.
