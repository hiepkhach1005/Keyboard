# Privacy and platform limitations

- English/Telex typing, swipe decoding, next-word candidates, and themes are offline; the shipped build needs no Full Access.
- Prefix suggestions may use Apple's on-device `UITextChecker` lexicon when the selected language is available. The bundled trie/frequency provider remains the fallback, and no text is sent to a server.
- Never collect, persist, transmit, print, screenshot, or attach typed text or surrounding context to analytics, diagnostics, crash reports, or tracking.
- The App Group stores preferences only. Tests/previews use synthetic text.
- Both executable targets include a `PrivacyInfo.xcprivacy` declaring no tracking/no collection and the approved UserDefaults reason matching App Group preference sharing.
- Any future online/sync/clipboard feature needs separate opt-in scope, threat model, disclosures, minimization, retention, and App Store review.

The current candidate provider combines Apple's on-device lexicon with a bundled offline corpus. Do not call an unofficial Google autocomplete endpoint from the extension: a general official Google keyboard-prediction API, licensing terms, and a safe App Store disclosure are not established. A future online provider must be opt-in, clearly disclose that the current token/context leaves the device, require Full Access only for that mode, and be reviewed as a separate product decision.

Expected restrictions: the system keyboard handles secure entry; some phone pads and opt-out apps block third-party keyboards; the extension uses a limited `UITextDocumentProxy`; context may be nil/truncated/change; users must enable and can switch away from the keyboard. Explain and gracefully handle these boundaries, never bypass them.

References: [Creating a custom keyboard](https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard) and [UIInputViewController](https://developer.apple.com/documentation/uikit/uiinputviewcontroller).
