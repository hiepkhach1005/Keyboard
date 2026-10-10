# Test plan

## Automated

- Telex: transformations, tones, case, real-word corpus, boundaries, deletion, normalization, context mismatch.
- Gesture: quick tap, threshold edge, long hold, movement, cancellation, multi-touch policy, timer cleanup, exactly-once commit.
- Swipe: path sampling across English keys, duplicate-key collapse, short-drag rejection, exactly-once suppression of the starting tap, disabled-setting behavior.
- Suggestions: prefix ranking, next-word ranking after a boundary, Vietnamese diacritics, case preservation, candidate replacement, Apple `UITextChecker` fallback/merge when available, and offline/no-network guarantee.
- Swipe candidates: collapsed-repeat ranking (`helo` -> `hello`), Vietnamese diacritic folding (`vuong` -> `vương`), conservative rejection of noisy paths, and exactly-once insertion.
- Layout: deterministic frames, no overlap/out-of-bounds, empty split gap, compact fallback, stable ordering.
- Settings: defaults, 150–1000 ms clamp, schema migration, swipe/candidate toggles, theme persistence, App Group unavailable fallback.
- Integration: fake proxy edits/context, shared settings, lifecycle cancellation, globe/input-mode path.

## Manual matrix

Test multiple iPhones portrait/landscape; iPad portrait/landscape/full/split/Auto/narrow/floating; English and Telex; rapid input, swipe paths, candidate taps, and long-press limits; all themes; light/dark; VoiceOver, Reduce Motion/Transparency, Increase Contrast; rotation/resizing/background/switching/relaunch; representative host fields and traits.

Profile key latency, main-thread stalls, extension memory, and glass rendering. No per-key file/network I/O.

Record exact commands, destinations, OS/runtime, and results in history. Simulator evidence does not satisfy device-only checks.
