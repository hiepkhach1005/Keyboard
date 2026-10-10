import SwiftUI

struct TypingTestView: View {
    @State private var sampleText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                KeyboardFeaturePreview()
                Text("Chạm vào vùng dưới, sau đó nhấn giữ nút địa cầu 🌐 và chọn \(AppConfiguration.displayName).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                TextEditor(text: $sampleText)
                    .frame(minHeight: 180)
                    .padding(8)
                    .background(.background, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary))
                    .accessibilityLabel("Vùng gõ thử bàn phím")
                if sampleText.isEmpty {
                    Text("Gợi ý: thử gõ “tieengs Vieejt”, nhấn giữ phím có ký tự phụ và đổi thời gian giữ trong Tùy chỉnh.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Button("Xóa nội dung gõ thử", role: .destructive) { sampleText = "" }
                    .disabled(sampleText.isEmpty)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Gõ thử")
    }
}

private struct KeyboardFeaturePreview: View {
    @EnvironmentObject private var model: KeyboardAppModel
    private let keys = [
        PreviewKey(primary: "A", alternate: "ă"),
        PreviewKey(primary: "D", alternate: "đ"),
        PreviewKey(primary: "E", alternate: "ê"),
        PreviewKey(primary: "O", alternate: "ơ"),
        PreviewKey(primary: "U", alternate: "ư")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Xem trước").font(.headline)
                Spacer()
                Text("\(model.settings.longPressDurationMilliseconds) ms").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            HStack(spacing: 7) {
                ForEach(keys) { key in
                    VStack(spacing: 0) {
                        Text(key.primary).font(.headline)
                        if model.settings.showSecondaryLegends {
                            Text(key.alternate).font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(Color(uiColor: .tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(key.primary), nhấn giữ cho \(key.alternate)")
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct PreviewKey: Identifiable {
    let primary: String
    let alternate: String
    var id: String { primary }
}
