import SharedSettings
import SwiftUI

struct KeyboardSettingsView: View {
    @EnvironmentObject private var model: KeyboardAppModel
    @State private var showResetConfirmation = false

    var body: some View {
        Form {
            Section("Ngôn ngữ") {
                Picker("Ngôn ngữ mặc định", selection: $model.settings.activeLanguage) {
                    Text("English").tag("english")
                    Text("Tiếng Việt — Telex").tag("vietnameseTelex")
                }
                Toggle("Đặt dấu theo kiểu hiện đại", isOn: $model.settings.modernVietnameseTonePlacement)
            }

            Section("Ký tự phụ") {
                Toggle("Hiện ký tự phụ dưới phím", isOn: $model.settings.showSecondaryLegends)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Thời gian nhấn giữ")
                        Spacer()
                        Text("\(model.settings.longPressDurationMilliseconds) ms")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: holdDurationBinding, in: 150...1000, step: 25)
                        .disabled(!model.settings.showSecondaryLegends)
                    HStack {
                        Text("Nhanh"); Spacer(); Text("Chậm")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .contain)
            }

            Section("Gõ thông minh") {
                Toggle("Vuốt để gõ", isOn: $model.settings.swipeTypingEnabled)
                Text("Kéo liên tục qua các chữ cái để nhập một từ. Vuốt được xử lý ngay trên thiết bị và không lưu đường vuốt.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Toggle("Gợi ý từ tiếp theo", isOn: $model.settings.nextWordSuggestionsEnabled)
                Text("Gợi ý kết hợp từ điển trên thiết bị của Apple (khi có) với bộ từ offline của VuongKey; không gửi nội dung bạn đang gõ ra ngoài.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Giao diện") {
                Picker("Theme bàn phím", selection: $model.settings.theme) {
                    ForEach(KeyboardTheme.allCases, id: \.rawValue) { theme in
                        Text(theme.displayName).tag(theme.rawValue)
                    }
                }
                ThemeChoicePreview(theme: KeyboardTheme(rawValue: model.settings.theme) ?? .system)
            }

            Section("iPad") {
                Picker("Bố cục", selection: $model.settings.ipadLayoutPreference) {
                    Text("Tự động").tag("auto")
                    Text("Đầy đủ").tag("full")
                    Text("Chia đôi").tag("split")
                }
                Text("Chế độ chia đôi tự thu gọn khi cửa sổ hoặc bàn phím nổi quá hẹp.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Dữ liệu") {
                Label("Chỉ lưu các tùy chọn này trong App Group", systemImage: "lock.shield")
                Label("Không lưu nội dung đã gõ", systemImage: "text.badge.xmark")
            }

            Section {
                Button("Khôi phục mặc định", role: .destructive) { showResetConfirmation = true }
            }
        }
        .navigationTitle("Tùy chỉnh")
        .confirmationDialog("Khôi phục toàn bộ tùy chọn?", isPresented: $showResetConfirmation) {
            Button("Khôi phục", role: .destructive) { model.resetSettings() }
            Button("Hủy", role: .cancel) {}
        }
    }

    private var holdDurationBinding: Binding<Double> {
        Binding(
            get: { Double(model.settings.longPressDurationMilliseconds) },
            set: { model.settings.longPressDurationMilliseconds = min(max(Int($0), 150), 1000) }
        )
    }
}

private struct ThemeChoicePreview: View {
    let theme: KeyboardTheme

    var body: some View {
        HStack(spacing: 6) {
            ForEach(swatches, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 18, height: 18)
            }
            Text(theme.displayName)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("Màu theme \(theme.displayName)")
    }

    private var swatches: [Color] {
        switch theme {
        case .system: return [.gray, .blue, .white]
        case .midnight: return [Color(red: 0.04, green: 0.05, blue: 0.1), .indigo, .white]
        case .ocean: return [Color(red: 0.03, green: 0.12, blue: 0.17), .teal, .cyan]
        case .royal: return [Color(red: 0.08, green: 0.04, blue: 0.18), .purple, .blue]
        case .forest: return [Color(red: 0.03, green: 0.12, blue: 0.08), .green, .mint]
        case .rose: return [Color(red: 0.17, green: 0.05, blue: 0.11), .pink, .orange]
        case .highContrast: return [.black, .white, .yellow]
        }
    }
}
