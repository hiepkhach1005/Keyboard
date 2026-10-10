# Apple targets

This folder contains the source for the two Apple targets already wired by `Keyboard.xcodeproj`:

- `KeyboardApp/KeyboardApp.swift`: containing SwiftUI settings app.
- `KeyboardExtension/KeyboardViewController.swift`: Custom Keyboard extension entry point and SwiftUI surface.
- `KeyboardExtension/Info.plist`: extension point and no-Full-Access default.
- `*/Keyboard*.entitlements`: App Group capability templates.
- `Configuration/Shared.xcconfig`: deployment target and replaceable identifiers.
- `*/PrivacyInfo.xcprivacy`: no-tracking manifests and approved UserDefaults reasons.

The containing app now includes onboarding, enable/switch instructions, an in-app typing test, shared keyboard settings, privacy disclosure, platform limitations, and optional configured support/privacy links.

## Run on an iPhone

1. Open Xcode > Settings > Components and install the current iOS platform (this machine currently reports iOS 26.5 as missing), then run `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`.
2. `Configuration/Shared.xcconfig` currently uses the working identity `VuongKey`, app ID `com.bavuong.vuongkey`, extension ID `com.bavuong.vuongkey.keyboard`, and App Group `group.com.bavuong.vuongkey`. Confirm that these identifiers are available for your developer Team. The extension ID must begin with the app ID.
3. Open `Keyboard.xcodeproj`. In Signing & Capabilities, select the same development Team for both `Keyboard` and `KeyboardExtension`.
4. Add/select the same App Group on both targets. It must exactly equal `KEYBOARD_APP_GROUP`.
5. Connect and trust the iPhone, enable Developer Mode if prompted, select the `Keyboard` scheme and the iPhone destination, then press Run.
6. On the iPhone, open Settings > General > Keyboard > Keyboards > Add New Keyboard, select VuongKey, then use the globe key in a text field. Full Access is not required.

The local Swift package is already linked: the app uses `SharedSettings`; the extension uses `InputCore` and `SharedSettings`. The extension is embedded in the app, and both privacy manifests are resources of their corresponding targets.

The App Group, privacy URL, support URL, product identity, icon, signing team, and final bundle identifiers remain release inputs. Replace them before submission. Full Xcode 26.6 is installed and its first-launch components are initialized, but the iOS 26.5 platform is not installed yet, so simulator/device builds and signing remain pending.

Follow `docs/APP_STORE_RELEASE.md` before uploading any build.
