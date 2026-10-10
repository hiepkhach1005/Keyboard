# App Store release checklist

This repository is not submission-ready until every `BLOCKER` below is resolved and device evidence is recorded.

## Developer-owned inputs

- `BLOCKER` Working name `VuongKey` is configured; verify App Store name, trademark, and domain availability before release.
- `BLOCKER` Provide Apple Developer Team ID, app Bundle ID, extension Bundle ID, and App Group ID.
- `BLOCKER` Provide a real support URL/contact and host `docs/PRIVACY_POLICY.md` at a stable HTTPS URL.
- `BLOCKER` A working original VuongKey App Store icon is present; approve/finalize it and provide final screenshots for supported iPhone/iPad sizes.
- `BLOCKER` Enroll in the Apple Developer Program and accept current agreements in App Store Connect.

## Xcode project and signing

- Install the full current Xcode release and select it with `xcode-select`.
- Create the containing-app target and Custom Keyboard extension target.
- Add all `AppleTargets/KeyboardApp/**` files to the app target and `AppleTargets/KeyboardExtension/**` files to the extension target.
- Link local package products `InputCore` and `SharedSettings` to both relevant targets.
- Apply `Configuration/Shared.xcconfig`, then replace all `.example` IDs and required URL placeholders.
- Enable the same App Group capability for app and extension; ensure extension `RequestsOpenAccess` remains `false`.
- Add each `PrivacyInfo.xcprivacy` to the matching target resources.
- Archive with distribution signing and validate the archive before upload.

## Product validation

- Complete all P0–P5 acceptance criteria in `tracking/BACKLOG.md`.
- Run unit tests with XCTest, UI tests, accessibility checks, extension lifecycle tests, and host-app integration.
- Test real iPhone and iPad devices, secure fields, blocked third-party-keyboard apps, floating keyboard, rotation, multitasking, and both languages.
- Confirm the globe control always progresses to another keyboard and core typing, swipe decoding, offline candidates, and themes work without Full Access or network.
- Confirm no typed/surrounding text appears in logs, diagnostics, screenshots, crash reports, App Group storage, or network traffic.

## App Store Connect

- Create an app record whose Bundle ID exactly matches Xcode.
- Add accurate description, keywords, category, age rating, support URL, privacy policy URL, screenshots, copyright, and review contact.
- App Privacy: if the shipped build stays exactly offline with no analytics/third-party collection, answer “No, we do not collect data from this app.” Re-audit before every submission.
- Complete export-compliance questions. `ITSAppUsesNonExemptEncryption` is currently `false`; change it if encryption behavior changes.
- Do not advertise Google-backed suggestions in the shipped offline build. Re-open the privacy, entitlement, licensing, and App Review review before adding any online provider.
- In Review Notes explain how to enable and select the keyboard, state that Full Access is not required, and provide a representative Telex test sequence.
- Upload to TestFlight, complete internal/external testing, then select the validated build for App Review.

## Suggested Review Notes

```text
This app contains a system-wide custom keyboard extension for English and Vietnamese Telex.

Enable it at Settings > General > Keyboard > Keyboards > Add New Keyboard > [APP NAME]. Full Access is not required and should remain off. In any text field, use the globe key to select [APP NAME]. The containing app includes Setup and Typing Test tabs for review.

Suggested test: type "tieengs Vieejt" in Vietnamese Telex mode, swipe across the letters in an English word, tap an offline candidate, and hold a key with a secondary legend. Core input works offline. The app does not collect or transmit typed text.
```

## Official Apple references

- [App Review Guidelines — Extensions and Keyboard Extensions](https://developer.apple.com/app-store/review/guidelines/#extensions)
- [Creating a custom keyboard](https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard)
- [Manage App Privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy)
- [Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files)
- [Submit an app for review](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app-for-review)
