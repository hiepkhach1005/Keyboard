# Liquid Glass guide

Liquid Glass communicates hierarchy and important interaction; it is not a texture for every key. Prioritize stable boundaries, contrast, performance, and input latency.

Apple references: [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass), [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views), and [Glass](https://developer.apple.com/documentation/swiftui/glass).

## Usage

- In the app, prefer standard navigation, toolbars, sheets, and controls. Use custom glass only on important grouped chrome; group related effects with `GlassEffectContainer`.
- In the extension, keep key faces inexpensive semantic surfaces. Glass may suit one candidate/mode bar, never one independent renderer per key.
- Avoid morphing animations during typing.
- Gate APIs with `if #available(iOS 26.0, *)`; use semantic materials/opaque colors earlier.
- Reduce Transparency increases opacity; Increase Contrast strengthens separation; Reduce Motion removes nonessential motion.

Review readability on light, dark, and busy backgrounds; bounded effect count; availability; accessibility adaptation; and typing latency/hitches.
