# Apple-platform keyboard layout guide

These are project rules inspired by familiar iOS/iPadOS behavior. Apple does not publish internal system-keyboard geometry; numeric values here are tunable tokens, not official measurements.

Official references: [Creating a custom keyboard](https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard), [UIInputViewController](https://developer.apple.com/documentation/uikit/uiinputviewcontroller), [Designing for iPadOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-ipados), and [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility).

## Visual and geometry rules

- Center dominant primary legends; put smaller, secondary-contrast alternates below them.
- Use semantic roles and SF Symbols for action keys, plus VoiceOver text.
- Compute widths from actual view bounds, row weights, insets, gaps, and optional center gap; distribute rounding error deterministically.
- Starting tokens to validate: 5–7 pt row gap, 3–8 pt outer inset, 5–8 pt key radius. Derive key height from available height. Do not hard-code these as Apple standards.
- Settings controls generally target at least 44×44 pt. Dense keyboard visuals may use expanded unambiguous hit regions.

## Adaptive modes

- Compact/full: weighted familiar QWERTY rows with stable alphabet placement.
- iPad full: use width for useful punctuation/controls, not only stretched letters.
- iPad split: left/right groups plus empty center gap; place frequent keys near thumbs; duplicate semantic space/control keys only when unambiguous. `Auto` chooses split only when usable; manual Split gracefully falls back/explains narrow or floating configurations.

## Secondary interaction

Start the timer at touch-down. Leaving tolerance cancels/transfers per the gesture policy. At threshold enter `alternateArmed` with visible feedback. On release commit primary only if never armed; otherwise alternate. Commit once. Clamp delay to 150–1000 ms, default 350 ms pending usability testing.

Test compact/regular widths, rotation, multitasking, floating keyboard, light/dark, VoiceOver, Increase Contrast, Reduce Transparency, Reduce Motion, and left/right-hand reach.
