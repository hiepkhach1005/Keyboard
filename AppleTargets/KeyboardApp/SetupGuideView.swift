import SwiftUI

struct SetupGuideView: View {
    @EnvironmentObject private var model: KeyboardAppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StatusCard()
                VStack(spacing: 0) {
                    InstructionStep(number: 1, text: "Settings → General → Keyboard")
                    Divider().padding(.leading, 52)
                    InstructionStep(number: 2, text: "Keyboards → Add New Keyboard")
                    Divider().padding(.leading, 52)
                    InstructionStep(number: 3, text: "Chọn \(AppConfiguration.displayName)")
                    Divider().padding(.leading, 52)
                    InstructionStep(number: 4, text: "Mở một ô nhập, nhấn giữ 🌐 và chọn bàn phím")
                }
                .background(.background, in: RoundedRectangle(cornerRadius: 18))

                Button { Task { await model.openSystemSettings() } } label: {
                    Label("Mở Settings", systemImage: "gear").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                GroupBox("Lưu ý") {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Không cần bật Allow Full Access", systemImage: "lock.shield")
                        Label("Secure text fields luôn dùng bàn phím hệ thống", systemImage: "key.fill")
                        Label("Một số app có thể chặn bàn phím bên thứ ba", systemImage: "app.badge.checkmark")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Thiết lập bàn phím")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Xem lại") { model.showOnboardingAgain() }
            }
        }
    }
}

private struct StatusCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "checklist")
                .font(.title)
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 6) {
                Text("Sẵn sàng để bật").font(.headline)
                Text("iOS không cung cấp API công khai đáng tin cậy để app xác nhận chính extension này đã được bật. Hãy kiểm tra trong Settings và dùng tab Gõ thử.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 18))
    }
}
