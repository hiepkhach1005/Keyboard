import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Chính sách quyền riêng tư").font(.largeTitle.bold())
                Text("Cập nhật: 22/08/2026").font(.footnote).foregroundStyle(.secondary)

                PolicySection(title: "Tóm tắt", text: "Bàn phím được thiết kế để hoạt động ngoại tuyến. Chúng tôi không thu thập, lưu trữ, bán hoặc gửi nội dung bạn gõ khỏi thiết bị.")
                PolicySection(title: "Dữ liệu được lưu", text: "App chỉ lưu các tùy chọn như ngôn ngữ, thời gian nhấn giữ, hiển thị ký tự phụ và bố cục iPad trong App Group dùng chung giữa app và Keyboard Extension.")
                PolicySection(title: "Nội dung bàn phím", text: "Các ký tự và ngữ cảnh cần thiết cho việc ghép Telex chỉ được xử lý tạm thời trong bộ nhớ của Keyboard Extension. Nội dung này không được ghi log hay lưu bền vững.")
                PolicySection(title: "Mạng và Full Access", text: "Các chức năng cốt lõi không dùng mạng và không yêu cầu Allow Full Access. App hiện không tích hợp quảng cáo, analytics hay SDK theo dõi.")
                PolicySection(title: "Chia sẻ và lưu giữ", text: "Vì không thu thập dữ liệu người dùng nên không có dữ liệu cá nhân để chia sẻ, bán, lưu giữ hoặc yêu cầu xóa. Xóa app sẽ xóa dữ liệu cục bộ theo cơ chế của iOS.")
                PolicySection(title: "Thay đổi", text: "Nếu một phiên bản tương lai bổ sung tính năng online hoặc thu thập dữ liệu, chính sách và App Privacy trên App Store sẽ được cập nhật trước khi phát hành.")
                PolicySection(title: "Liên hệ", text: "Bạn có thể sử dụng mục Liên hệ hỗ trợ trên màn hình Thông tin để gửi câu hỏi về quyền riêng tư hoặc sản phẩm.")
            }
            .padding()
        }
        .navigationTitle("Quyền riêng tư")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PolicySection: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(text).foregroundStyle(.secondary)
        }
    }
}
