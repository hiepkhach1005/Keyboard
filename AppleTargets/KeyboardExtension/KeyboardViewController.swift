import InputCore
import SharedSettings
import SwiftUI
import UIKit

final class KeyboardViewController: UIInputViewController {
    private enum KeyboardHeight {
        static let compactLandscape: CGFloat = 162
        static let compactPortrait: CGFloat = 208
        static let regular: CGFloat = 264
    }

    private let settingsStore = UserDefaultsSettingsStore(
        suiteName: SharedSettingsConfiguration.appGroupIdentifier()
    )
    private var hostingController: UIHostingController<KeyboardSurface>?
    private var keyboardHeightConstraint: NSLayoutConstraint?
    private var telexComposer = TelexComposer()
    private var suggestions: [String] = []
    private let suggestionEngine = SuggestionEngine()
    private let appleTextCheckerProvider = AppleTextCheckerProvider()
    private lazy var inputModeController = WeakInputModeController(self)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        installKeyboardHeightConstraint()

        let host = UIHostingController(rootView: makeSurface())
        host.view.backgroundColor = .clear
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        host.didMove(toParent: self)
        hostingController = host
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateKeyboardHeight()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        telexComposer.reset()
        refreshSuggestions()
        hostingController?.rootView = makeSurface()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.updateKeyboardHeight()
        }
    }

    private func installKeyboardHeightConstraint() {
        let constraint = view.heightAnchor.constraint(equalToConstant: preferredKeyboardHeight())
        constraint.priority = UILayoutPriority(999)
        constraint.isActive = true
        keyboardHeightConstraint = constraint
        preferredContentSize.height = constraint.constant
    }

    private func updateKeyboardHeight() {
        let height = preferredKeyboardHeight()
        guard keyboardHeightConstraint?.constant != height else { return }
        keyboardHeightConstraint?.constant = height
        preferredContentSize.height = height
    }

    private func preferredKeyboardHeight() -> CGFloat {
        let settings = settingsStore.load()
        let suggestionBarHeight: CGFloat = settings.nextWordSuggestionsEnabled ? 32 : 0
        if traitCollection.verticalSizeClass == .compact {
            return KeyboardHeight.compactLandscape + suggestionBarHeight
        }
        if traitCollection.horizontalSizeClass == .regular, view.bounds.width >= 600 {
            return KeyboardHeight.regular + suggestionBarHeight
        }
        return KeyboardHeight.compactPortrait + suggestionBarHeight
    }

    private func makeSurface() -> KeyboardSurface {
        KeyboardSurface(
            settings: settingsStore.load(),
            // Keep one familiar input-mode/emoji control in the key row. iOS also
            // owns the separate bottom safe-area globe on Face ID devices.
            showsInputModeSwitchKey: true,
            inputModeController: inputModeController,
            suggestions: suggestions,
            onInsert: { [weak self] text in self?.insert(text) },
            onDelete: { [weak self] in self?.deleteBackward() },
            onSwipe: { [weak self] word in self?.insertSwipe(word) },
            onSelectSuggestion: { [weak self] suggestion in self?.replaceCurrentWord(with: suggestion) }
        )
    }

    private func insert(_ text: String, refreshSurface: Bool = true) {
        let settings = settingsStore.load()
        guard settings.activeLanguage == KeyboardLanguage.vietnameseTelex.rawValue,
              text.count == 1,
              let input = text.first else {
            telexComposer.reset()
            textDocumentProxy.insertText(text)
            if refreshSurface { refreshSuggestions() }
            return
        }
        reconcileComposerWithDocument()
        apply(telexComposer.handle(input))
        if refreshSurface { refreshSuggestions() }
    }

    private func deleteBackward() {
        if !telexComposer.source.isEmpty, reconcileComposerWithDocument() {
            apply(telexComposer.backspace())
        } else {
            textDocumentProxy.deleteBackward()
        }
        refreshSuggestions()
    }

    private func insertSwipe(_ word: String) {
        guard !word.isEmpty else { return }
        let settings = settingsStore.load()
        let language = KeyboardLanguage(rawValue: settings.activeLanguage) ?? .english
        let candidate = suggestionEngine.swipeCandidates(
            keySequence: word,
            language: language,
            limit: 1
        ).first ?? word
        replaceCurrentWord(with: preserveSwipeCase(candidate, matching: word))
    }

    private func replaceCurrentWord(with suggestion: String) {
        guard !suggestion.isEmpty else { return }
        telexComposer.reset()
        let context = textDocumentProxy.documentContextBeforeInput ?? ""
        let token = currentToken(in: context)
        for _ in token.prefix {
            textDocumentProxy.deleteBackward()
        }
        textDocumentProxy.insertText(suggestion + " ")
        refreshSuggestions()
    }

    private func refreshSuggestions() {
        let settings = settingsStore.load()
        guard settings.nextWordSuggestionsEnabled else {
            suggestions = []
            hostingController?.rootView = makeSurface()
            updateKeyboardHeight()
            return
        }
        let context = textDocumentProxy.documentContextBeforeInput ?? ""
        let token = currentToken(in: context)
        let language = KeyboardLanguage(rawValue: settings.activeLanguage) ?? .english
        let offline = suggestionEngine.suggestions(
            prefix: token.prefix,
            previousWord: token.previousWord,
            language: language
        )
        let apple = appleTextCheckerProvider.suggestions(
            prefix: token.prefix,
            language: language,
            limit: 3
        )
        suggestions = mergeCandidates(apple + offline, limit: 3)
        hostingController?.rootView = makeSurface()
        updateKeyboardHeight()
    }

    private func mergeCandidates(_ values: [String], limit: Int) -> [String] {
        var result: [String] = []
        for value in values where !value.isEmpty {
            guard !result.contains(where: { $0.caseInsensitiveCompare(value) == .orderedSame }) else { continue }
            result.append(value)
            if result.count == limit { break }
        }
        return result
    }

    private func preserveSwipeCase(_ candidate: String, matching path: String) -> String {
        guard let first = path.first, first.isUppercase else { return candidate }
        return candidate.first?.isUppercase == true ? candidate : candidate.capitalized
    }

    private func currentToken(in context: String) -> (prefix: String, previousWord: String?) {
        let words = context.split { character in
            character.isWhitespace || character.isPunctuation || character.isSymbol
        }.map(String.init)
        let endsWithBoundary = context.last.map {
            $0.isWhitespace || $0.isPunctuation || $0.isSymbol
        } ?? true
        if endsWithBoundary {
            return ("", words.last)
        }
        return (words.last ?? "", words.dropLast().last)
    }

    @discardableResult
    private func reconcileComposerWithDocument() -> Bool {
        guard !telexComposer.renderedText.isEmpty else { return true }
        guard let context = textDocumentProxy.documentContextBeforeInput,
              context.hasSuffix(telexComposer.renderedText) else {
            telexComposer.reset()
            return false
        }
        return true
    }

    private func apply(_ edit: TextEdit) {
        for _ in 0..<edit.deleteBackwardCount {
            textDocumentProxy.deleteBackward()
        }
        if !edit.insertion.isEmpty {
            textDocumentProxy.insertText(edit.insertion)
        }
    }
}

struct KeyboardSurface: View {
    let settings: KeyboardSettings
    let showsInputModeSwitchKey: Bool
    let inputModeController: WeakInputModeController
    let suggestions: [String]
    let onInsert: (String) -> Void
    let onDelete: () -> Void
    let onSwipe: (String) -> Void
    let onSelectSuggestion: (String) -> Void

    @State private var layer: KeyboardLayerKind = .alphabetic
    @State private var shiftState: ShiftState = .lowercase
    @State private var preview: KeyPreview?
    @StateObject private var swipeSession = SwipeGestureSession()

    var body: some View {
        let palette = KeyboardThemePalette(theme: KeyboardTheme(rawValue: settings.theme) ?? .system)
        VStack(spacing: 0) {
            if settings.nextWordSuggestionsEnabled {
                SuggestionBar(
                    suggestions: suggestions,
                    palette: palette,
                    onSelect: onSelectSuggestion
                )
                .frame(height: 32)
            }
            GeometryReader { proxy in
                let context = KeyboardContext(
                    width: proxy.size.width,
                    height: proxy.size.height,
                    language: KeyboardLanguage(rawValue: settings.activeLanguage) ?? .english,
                    layoutPreference: LayoutPreference(rawValue: settings.ipadLayoutPreference) ?? .auto,
                    isRegularWidth: proxy.size.width >= 600,
                    showsInputModeSwitchKey: showsInputModeSwitchKey,
                    layer: layer,
                    shiftState: shiftState
                )
                let layout = KeyboardLayoutEngine().makeLayout(context: context)
                ZStack {
                    palette.background
                    ForEach(layout.frames, id: \.keyID) { frame in
                        if let key = layout.rows[frame.row].keys.first(where: { $0.id == frame.keyID }) {
                            keyView(for: key, frame: frame, palette: palette)
                                .frame(width: frame.width, height: frame.height)
                                .position(x: frame.x + frame.width / 2, y: frame.y + frame.height / 2)
                                .accessibilityLabel(key.accessibilityLabel)
                        }
                    }
                    if let preview {
                        KeyPreviewBubble(text: preview.text, palette: palette)
                            .position(
                                x: preview.frame.x + preview.frame.width / 2,
                                y: max(36, preview.frame.y - 18)
                            )
                            .allowsHitTesting(false)
                            .zIndex(100)
                    }
                }
                .simultaneousGesture(swipeGesture(for: layout))
            }
        }
    }

    @ViewBuilder
    private func keyView(for key: KeyDefinition, frame: KeyFrame, palette: KeyboardThemePalette) -> some View {
        if key.role == .globe {
            SystemInputModeKey(controller: inputModeController, palette: palette)
        } else {
            KeyboardKeyButton(
                key: key,
                holdDuration: Double(settings.longPressDurationMilliseconds) / 1000,
                showAlternate: settings.showSecondaryLegends,
                palette: palette,
                swipeSession: swipeSession,
                onPreview: { text in
                    preview = text.map { KeyPreview(text: $0, frame: frame) }
                },
                onIntent: handle
            )
        }
    }

    private func swipeGesture(for layout: KeyboardLayout) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard settings.swipeTypingEnabled else { return }
                if swipeSession.didConsume { swipeSession.reset() }
                let point = SwipePoint(x: value.location.x, y: value.location.y)
                if swipeSession.points.isEmpty {
                    swipeSession.points = [point]
                    return
                }
                if let last = swipeSession.points.last {
                    let dx = point.x - last.x
                    let dy = point.y - last.y
                    if (dx * dx + dy * dy).squareRoot() >= 2 {
                        swipeSession.points.append(point)
                    }
                }
                guard let first = swipeSession.points.first else { return }
                let dx = point.x - first.x
                let dy = point.y - first.y
                if !swipeSession.isActive, (dx * dx + dy * dy).squareRoot() >= 18 {
                    swipeSession.isActive = true
                }
            }
            .onEnded { _ in
                guard settings.swipeTypingEnabled, swipeSession.isActive else {
                    swipeSession.reset()
                    return
                }
                let word = SwipeTypingEngine().decode(points: swipeSession.points, layout: layout)
                if word.isEmpty {
                    swipeSession.reset()
                } else {
                    // Keep the consumed marker until the key's own gesture
                    // ends, preventing a swipe from also committing its first
                    // key as a normal tap.
                    swipeSession.didConsume = true
                    onSwipe(word)
                }
            }
    }

    private func handle(_ intent: KeyIntent) {
        switch intent {
        case .insert(let text):
            onInsert(text)
            if shiftState == .uppercase { shiftState = .lowercase }
        case .control(.backspace): onDelete()
        case .control(.space): onInsert(" ")
        case .control(.returnKey): onInsert("\n")
        case .control(.shift): advanceShiftState()
        case .control(.numericMode): layer = .numeric
        case .control(.symbolMode): layer = .symbols
        case .control(.alphabeticMode): layer = .alphabetic
        default: break
        }
    }

    private func advanceShiftState() {
        switch shiftState {
        case .lowercase: shiftState = .uppercase
        case .uppercase: shiftState = .capsLock
        case .capsLock: shiftState = .lowercase
        }
    }
}

private struct KeyPreview: Equatable {
    let text: String
    let frame: KeyFrame
}

private final class SwipeGestureSession: ObservableObject {
    var points: [SwipePoint] = []
    var isActive = false
    var didConsume = false

    func reset() {
        points.removeAll(keepingCapacity: true)
        isActive = false
        didConsume = false
    }
}

private struct KeyboardThemePalette {
    let background: Color
    let key: Color
    let pressed: Color
    let foreground: Color
    let secondary: Color
    let accent: Color

    init(theme: KeyboardTheme) {
        switch theme {
        case .system:
            background = Color(uiColor: .secondarySystemBackground)
            key = Color(uiColor: .tertiarySystemBackground)
            pressed = Color(uiColor: .systemGray3)
            foreground = Color(uiColor: .label)
            secondary = Color(uiColor: .secondaryLabel)
            accent = .blue
        case .midnight:
            background = Color(red: 0.035, green: 0.043, blue: 0.075)
            key = Color(red: 0.10, green: 0.12, blue: 0.18)
            pressed = Color(red: 0.18, green: 0.22, blue: 0.32)
            foreground = .white
            secondary = Color.white.opacity(0.62)
            accent = Color(red: 0.44, green: 0.56, blue: 1)
        case .ocean:
            background = Color(red: 0.035, green: 0.11, blue: 0.16)
            key = Color(red: 0.08, green: 0.24, blue: 0.32)
            pressed = Color(red: 0.12, green: 0.37, blue: 0.47)
            foreground = .white
            secondary = Color.white.opacity(0.68)
            accent = Color(red: 0.28, green: 0.85, blue: 0.92)
        case .royal:
            background = Color(red: 0.075, green: 0.04, blue: 0.18)
            key = Color(red: 0.17, green: 0.09, blue: 0.36)
            pressed = Color(red: 0.29, green: 0.15, blue: 0.52)
            foreground = .white
            secondary = Color.white.opacity(0.68)
            accent = Color(red: 0.53, green: 0.45, blue: 1)
        case .forest:
            background = Color(red: 0.035, green: 0.12, blue: 0.08)
            key = Color(red: 0.08, green: 0.24, blue: 0.16)
            pressed = Color(red: 0.13, green: 0.38, blue: 0.24)
            foreground = .white
            secondary = Color.white.opacity(0.68)
            accent = Color(red: 0.42, green: 0.92, blue: 0.60)
        case .rose:
            background = Color(red: 0.17, green: 0.055, blue: 0.11)
            key = Color(red: 0.34, green: 0.12, blue: 0.22)
            pressed = Color(red: 0.52, green: 0.19, blue: 0.32)
            foreground = .white
            secondary = Color.white.opacity(0.72)
            accent = Color(red: 1, green: 0.56, blue: 0.68)
        case .highContrast:
            background = .black
            key = Color(white: 0.12)
            pressed = Color(white: 0.28)
            foreground = .white
            secondary = Color.white.opacity(0.85)
            accent = .yellow
        }
    }
}

private struct SuggestionBar: View {
    let suggestions: [String]
    let palette: KeyboardThemePalette
    let onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: 4) {
            if suggestions.isEmpty {
                Color.clear
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityLabel("Không có gợi ý")
            } else {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        onSelect(suggestion)
                    } label: {
                        Text(suggestion)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(palette.foreground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 26)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Gợi ý \(suggestion)")
                }
            }
        }
        .padding(.horizontal, 8)
        .background(palette.background)
        .overlay(alignment: .bottom) { Rectangle().fill(palette.secondary.opacity(0.18)).frame(height: 0.5) }
    }
}

private struct KeyPreviewBubble: View {
    let text: String
    let palette: KeyboardThemePalette

    var body: some View {
        Text(text)
            .font(.system(size: 30, weight: .regular))
            .foregroundStyle(palette.foreground)
            .frame(width: 58, height: 68)
            .background(palette.key)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: .black.opacity(0.22), radius: 3, y: 1)
    }
}

private struct KeyboardKeyButton: View {
    let key: KeyDefinition
    let holdDuration: TimeInterval
    let showAlternate: Bool
    let palette: KeyboardThemePalette
    let swipeSession: SwipeGestureSession
    let onPreview: (String?) -> Void
    let onIntent: (KeyIntent) -> Void

    @State private var isPressed = false
    @State private var isAlternateArmed = false
    @State private var isCancelled = false
    @State private var didRepeat = false
    @State private var holdTask: Task<Void, Never>?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            keyCapContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if showAlternate, let alternate = key.alternate {
                Text(alternate)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(isAlternateArmed ? palette.foreground : palette.secondary)
                    .padding(.trailing, 5)
                    .padding(.bottom, 3)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isPressed ? palette.pressed : palette.key)
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if !isPressed {
                        isPressed = true
                        isCancelled = false
                        isAlternateArmed = false
                        didRepeat = false
                        if key.role == .character { onPreview(key.primary) }
                        scheduleHoldOrRepeat()
                    }
                    if abs(value.translation.width) > 28 || abs(value.translation.height) > 28 {
                        isCancelled = true
                        holdTask?.cancel()
                        onPreview(nil)
                    }
                }
                .onEnded { _ in
                    holdTask?.cancel()
                    guard !isCancelled, !didRepeat, !swipeSession.isActive, !swipeSession.didConsume else {
                        resetGesture()
                        return
                    }
                    let output = isAlternateArmed ? (key.alternate ?? key.primary) : key.primary
                    if key.role == .character {
                        onIntent(.insert(output))
                    } else {
                        onIntent(.control(key.role))
                    }
                    resetGesture()
                }
        )
    }

    @ViewBuilder
    private var keyCapContent: some View {
        switch key.role {
        case .returnKey:
            Image(systemName: "arrow.turn.down.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(palette.foreground)
        case .backspace:
            Image(systemName: "delete.left")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(palette.foreground)
        case .shift:
            Image(systemName: key.primary == "⇪" ? "capslock.fill" : "shift")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(palette.foreground)
        default:
            Text(key.primary)
                .font(.system(size: key.role == .character ? 21 : 16, weight: .regular))
                .foregroundStyle(palette.foreground)
        }
    }

    private func scheduleHoldOrRepeat() {
        if key.role == .backspace {
            holdTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(360))
                guard !Task.isCancelled, !isCancelled else { return }
                while !Task.isCancelled, !isCancelled {
                    didRepeat = true
                    onIntent(.control(.backspace))
                    try? await Task.sleep(for: .milliseconds(75))
                }
            }
            return
        }
        guard key.alternate != nil else { return }
        let delay = max(0.15, min(1.0, holdDuration))
        holdTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(Int(delay * 1000)))
            guard !Task.isCancelled, !isCancelled else { return }
            isAlternateArmed = true
            onPreview(key.alternate)
        }
    }

    private func resetGesture() {
        isPressed = false
        isAlternateArmed = false
        isCancelled = false
        didRepeat = false
        holdTask = nil
        onPreview(nil)
    }
}

final class WeakInputModeController {
    weak var value: UIInputViewController?

    init(_ value: UIInputViewController?) {
        self.value = value
    }
}

private struct SystemInputModeKey: UIViewRepresentable {
    let controller: WeakInputModeController
    let palette: KeyboardThemePalette

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "face.smiling"), for: .normal)
        button.tintColor = UIColor(palette.foreground)
        button.backgroundColor = UIColor(palette.key)
        button.layer.cornerRadius = 7
        button.accessibilityLabel = "Change keyboard; hold for Emoji and keyboard list"
        if let controller = controller.value {
            button.addTarget(
                controller,
                action: #selector(UIInputViewController.handleInputModeList(from:with:)),
                for: .allTouchEvents
            )
        }
        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        uiView.tintColor = UIColor(palette.foreground)
        uiView.backgroundColor = UIColor(palette.key)
    }
}
