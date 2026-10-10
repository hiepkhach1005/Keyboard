import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var model: KeyboardAppModel

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Image(systemName: "keyboard.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.tint)
                    Text(AppConfiguration.displayName).font(.title2.bold())
                    Text("Phiên bản \(AppConfiguration.version)").font(.footnote).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }

            Section("Trợ giúp") {
                NavigationLink { SetupGuideView() } label: { Label("Hướng dẫn bật và chuyển bàn phím", systemImage: "questionmark.circle") }
                NavigationLink { PlatformLimitationsView() } label: { Label("Giới hạn của iOS", systemImage: "exclamationmark.triangle") }
                Button { model.showOnboardingAgain() } label: { Label("Xem lại giới thiệu", systemImage: "arrow.counterclockwise") }
            }

            Section("Riêng tư và hỗ trợ") {
                NavigationLink { PrivacyPolicyView() } label: { Label("Chính sách quyền riêng tư", systemImage: "hand.raised") }
                if let url = AppConfiguration.privacyPolicyURL {
                    Link(destination: url) { Label("Chính sách trên website", systemImage: "safari") }
                }
                if let url = AppConfiguration.supportURL {
                    Link(destination: url) { Label("Liên hệ hỗ trợ", systemImage: "envelope") }
                }
            }
        }
        .navigationTitle("Thông tin")
    }
}

struct PlatformLimitationsView: View {
    var body: some View {
        List {
            LimitationRow(icon: "lock.fill", title: "Ô mật khẩu", message: "iOS tự động chuyển về bàn phím hệ thống khi nhập nội dung bảo mật.")
            LimitationRow(icon: "phone.fill", title: "Một số bàn phím số", message: "Một số kiểu nhập số điện thoại có thể không cho phép bàn phím bên thứ ba.")
            LimitationRow(icon: "app.dashed", title: "Ứng dụng chủ quản", message: "Nhà phát triển app có thể chặn toàn bộ custom keyboard trong app của họ.")
            LimitationRow(icon: "globe", title: "Chuyển bàn phím", message: "Nút địa cầu luôn được giữ lại để bạn chuyển sang bàn phím khác.")
            LimitationRow(icon: "wifi.slash", title: "Hoạt động ngoại tuyến", message: "English và Vietnamese Telex hoạt động khi không có mạng và không cần Full Access.")
        }
        .navigationTitle("Giới hạn của iOS")
    }
}

private struct LimitationRow: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(message).font(.subheadline).foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: icon).foregroundStyle(.tint)
        }
        .padding(.vertical, 4)
    }
}
