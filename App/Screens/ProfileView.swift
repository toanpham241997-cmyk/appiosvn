import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: DemoStore
    let onLogout: () -> Void
    @State private var showingEditName = false
    @State private var tempName = ""
    @State private var showAbout = false
    @State private var soundEnabled = true
    @State private var animationsEnabled = true

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    Text("My Profile")
                        .font(.system(size: 31, weight: .bold, design: .rounded))
                        .foregroundStyle(UIStyle.ink)
                        .padding(.top, 10)
                    VStack(spacing: 14) {
                        ZStack {
                            Circle().fill(UIStyle.gradient).frame(width: 83, height: 83)
                            Text(initials).font(.system(size: 26, weight: .bold, design: .rounded)).foregroundStyle(.white)
                        }
                        Text(store.userName).font(.system(size: 22, weight: .bold, design: .rounded)).foregroundStyle(UIStyle.ink)
                        Text("Aujunpeak VN • Demo member").font(.system(size: 12)).foregroundStyle(UIStyle.muted)
                        Button { tempName = store.userName; showingEditName = true } label: {
                            AccentPill(text: "Chỉnh sửa hồ sơ", icon: "pencil")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22)
                    .softCard(padding: 16)
                    SectionTitle(title: "Thiết lập ứng dụng")
                    VStack(spacing: 0) {
                        profileToggle(icon: "bell.badge", title: "Nhắc nhở trong bản demo", isOn: $store.pushEnabled, tint: UIStyle.violet)
                        Divider().padding(.leading, 50)
                        profileToggle(icon: "speaker.wave.2", title: "Âm thanh giao diện", isOn: $soundEnabled, tint: UIStyle.orange)
                        Divider().padding(.leading, 50)
                        profileToggle(icon: "sparkles", title: "Hiệu ứng chuyển động", isOn: $animationsEnabled, tint: UIStyle.pink)
                    }
                    .softCard()
                    SectionTitle(title: "Thông tin")
                    VStack(spacing: 0) {
                        Button { showAbout = true } label: { menuRow(icon: "info.circle", title: "Giới thiệu ứng dụng", subtitle: "Thông tin phiên bản", tint: UIStyle.blue) }
                        Divider().padding(.leading, 49)
                        menuRow(icon: "iphone.gen3", title: "Tương thích", subtitle: "iOS 17 trở lên", tint: UIStyle.green)
                        Divider().padding(.leading, 49)
                        menuRow(icon: "externaldrive", title: "Dữ liệu", subtitle: "Lưu cục bộ trên thiết bị", tint: UIStyle.violet)
                    }
                    .softCard()
                    Button(role: .destructive, action: onLogout) {
                        HStack(spacing: 9) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Đăng xuất bản demo")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
                    }
                    Text("Aujunpeak VN • SwiftUI Experience v1.0")
                        .font(.system(size: 11))
                        .foregroundStyle(UIStyle.muted)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20).padding(.bottom, 35)
            }
            .background(BackgroundCanvas())
            .toolbar(.hidden, for: .navigationBar)
            .alert("Chỉnh sửa tên", isPresented: $showingEditName) {
                TextField("Tên hiển thị", text: $tempName)
                Button("Hủy", role: .cancel) {}
                Button("Lưu") {
                    let t = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !t.isEmpty { store.userName = t }
                }
            } message: { Text("Tên được lưu cục bộ trên điện thoại.") }
            .alert("Aujunpeak VN", isPresented: $showAbout) {
                Button("Đã hiểu", role: .cancel) {}
            } message: {
                Text("Bộ giao diện iOS hiện đại xây dựng bằng SwiftUI. Phiên bản 1.0 là ứng dụng demo ngoại tuyến; chưa có đăng nhập máy chủ hoặc gửi tin nhắn trực tuyến.")
            }
        }
    }

    private var initials: String {
        let parts = store.userName.split(separator: " ")
        let letters = parts.prefix(2).compactMap(\.first)
        return letters.isEmpty ? "A" : String(letters).uppercased()
    }

    private func profileToggle(icon: String, title: String, isOn: Binding<Bool>, tint: Color) -> some View {
        HStack(spacing: 12) {
            RoundIcon(icon: icon, tint: tint, background: tint.opacity(0.10), size: 37)
            Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(UIStyle.ink)
            Spacer(minLength: 4)
            Toggle(title, isOn: isOn).labelsHidden().tint(UIStyle.blue)
        }
        .padding(.vertical, 10)
    }

    private func menuRow(icon: String, title: String, subtitle: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            RoundIcon(icon: icon, tint: tint, background: tint.opacity(0.10), size: 37)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(UIStyle.ink)
                Text(subtitle).font(.system(size: 11)).foregroundStyle(UIStyle.muted)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 11)).foregroundStyle(UIStyle.muted)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
