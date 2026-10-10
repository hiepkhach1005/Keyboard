# Product specification

## Product promise

A fast, private, native iPhone/iPad keyboard with familiar Apple-platform ergonomics and four differentiators: visible secondary legends, configurable long press, reliable Vietnamese Telex, and thumb-friendly split iPad layout.

“Like Gboard” means quality, responsiveness, multilingual switching, and useful input behavior. It does not authorize copying Google branding, code, assets, or visual trade dress.

## MVP

- Keyboard extension with alphabetic/numeric/symbol layers; English and Vietnamese Telex; primary plus smaller secondary legend; tap/hold output; configurable hold delay; shift/caps, repeat delete, space, return variants, mode/language/globe controls; adaptive iPhone/iPad layout; `Full`/`Split`/`Auto` iPad mode; light/dark/accessibility fallbacks.
- Containing app with onboarding, keyboard-enable instructions, languages, hold delay, iPad preference, secondary-legend toggle, appearance preview, privacy explanation, and a clearly labeled in-app typing test.
- Offline core, no accounts, analytics, ads, or typed-text upload. Swipe typing, next-word candidates, and themes are opt-in settings but remain on-device.

## Out of scope for MVP

Cloud sync, remote AI, clipboard history, GIF search, marketplace themes, pixel-perfect cloning, and large learned language models. A Google-backed provider is deliberately deferred until an official API, licensing terms, privacy review, and explicit Full Access consent are available; the shipped candidate bar stays offline.

## Acceptance scenario

Enable the extension, switch languages, type English and a representative Telex corpus, use alternate keys at changed hold delays, and use the globe control. On iPad repeat in portrait, landscape, narrow multitasking, floating, full, and split layouts. Test light/dark/accessibility. Record simulator and device evidence separately.
