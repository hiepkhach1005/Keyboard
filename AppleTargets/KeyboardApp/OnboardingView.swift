import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var model: KeyboardAppModel
    @State private var page = 0

    var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $page) {
                OnboardingPage(icon: "keyboard.fill", title: "Gõ nhanh hơn bằng tiếng Việt", message: "Bàn phím hỗ trợ English, Vietnamese Telex, ký tự phụ và bố cục chia đôi trên iPad.", bullets: ["Hoạt động ngoại tuyến", "Không cần Full Access", "Tùy chỉnh thời gian nhấn giữ"]).tag(0)
                OnboardingPage(icon: "hand.raised.fill", title: "Riêng tư từ thiết kế", message: "Nội dung bạn gõ không được lưu, phân tích hay gửi khỏi thiết bị. App Group chỉ lưu tùy chọn bàn phím.", bullets: ["Không tài khoản", "Không quảng cáo", "Không theo dõi"]).tag(1)
                EnableKeyboardPage().tag(2)
                OnboardingPage(icon: "globe", title: "Chuyển sang bàn phím mới", message: "Mở một ô nhập văn bản, sau đó chạm hoặc nhấn giữ nút địa cầu và chọn \(AppConfiguration.displayName).", bullets: ["Đổi bàn phím bất cứ lúc nào", "Dùng tab Gõ thử để kiểm tra", "Không bật Full Access"]).tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            HStack(spacing: 12) {
                if page > 0 {
                    Button("Quay lại") { withAnimation { page -= 1 } }
                        .buttonStyle(.bordered)
                }
                Button(page == 3 ? "Hoàn tất" : "Tiếp tục") {
                    if page == 3 { model.completeOnboarding() }
                    else { withAnimation { page += 1 } }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

private struct OnboardingPage: View {
    let icon: String
    let title: String
    let message: String
    let bullets: [String]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 48)
                Image(systemName: icon).font(.system(size: 64, weight: .semibold)).foregroundStyle(.tint).accessibilityHidden(true)
                Text(title).font(.largeTitle.bold()).multilineTextAlignment(.center)
                Text(message).foregroundStyle(.secondary).multilineTextAlignment(.center)
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(bullets, id: \.self) { Label($0, systemImage: "checkmark.circle.fill") }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.background, in: RoundedRectangle(cornerRadius: 20))
            }
            .padding(24)
        }
    }
}

private struct EnableKeyboardPage: View {
    @EnvironmentObject private var model: KeyboardAppModel

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Image(systemName: "gearshape.2.fill").font(.system(size: 60)).foregroundStyle(.tint)
                Text("Bật bàn phím").font(.largeTitle.bold())
                Text("Nút dưới mở trang Settings công khai của app. Sau đó tiếp tục theo các bước bên dưới.").foregroundStyle(.secondary).multilineTextAlignment(.center)
                VStack(spacing: 0) {
                    InstructionStep(number: 1, text: "Mở Settings → General → Keyboard")
                    Divider().padding(.leading, 52)
                    InstructionStep(number: 2, text: "Chọn Keyboards → Add New Keyboard")
                    Divider().padding(.leading, 52)
                    InstructionStep(number: 3, text: "Chọn \(AppConfiguration.displayName)")
                    Divider().padding(.leading, 52)
                    InstructionStep(number: 4, text: "Giữ Allow Full Access ở trạng thái tắt")
                }
                .background(.background, in: RoundedRectangle(cornerRadius: 18))
                Button { Task { await model.openSystemSettings() } } label: {
                    Label("Mở Settings", systemImage: "gear").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
        }
    }
}

struct InstructionStep: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(number)").font(.headline).frame(width: 30, height: 30).background(Color.accentColor.opacity(0.14), in: Circle())
            Text(text).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 4)
        }
        .padding(14)
    }
}
