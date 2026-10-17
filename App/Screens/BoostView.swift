import SwiftUI

struct BoostView: View {
    @EnvironmentObject private var prefs: BoostPreferences
    @EnvironmentObject private var monitor: DeviceMonitor
    @EnvironmentObject private var toast: ToastCenter
    @State private var showGuide = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                BrandHeader(eyebrow: "PERSONAL GAME PRESETS")
                PageTitle(title: "Game Boost", subtitle: "Tùy chỉnh trải nghiệm trong Aujunpeak")
                boostHero
                SectionHeading(title: "Chế độ của bạn", trailing: "3 PRESETS")
                HStack(spacing: 9) {
                    ForEach(GamePreset.allCases) { preset in
                        Button {
                            prefs.preset = preset
                            toast.show("Đã bật preset \(preset.rawValue) cho Aujunpeak.")
                        } label: {
                            VStack(spacing: 11) {
                                Image(systemName: preset.icon)
                                    .font(.system(size: 23)).frame(height: 28)
                                Text(preset.rawValue).font(.system(size: 11, weight: .bold))
                                    .lineLimit(1).minimumScaleFactor(0.8)
                            }
                            .foregroundStyle(prefs.preset == preset ? Palette.purple : Palette.muted)
                            .frame(maxWidth: .infinity).frame(height: 79)
                            .background(prefs.preset == preset ? Palette.lilac : Color.white,
                                        in: RoundedRectangle(cornerRadius: 19))
                            .overlay(RoundedRectangle(cornerRadius: 19)
                                .stroke(prefs.preset == preset ? Palette.purple.opacity(0.35) : Palette.line))
                        }.buttonStyle(.plain)
                    }
                }
                Text(prefs.preset.description).font(.system(size: 11)).foregroundStyle(Palette.muted)
                SectionHeading(title: "Điều chỉnh trải nghiệm")
                VStack(spacing: 2) {
                    settingToggle("Giảm hiệu ứng", caption: "Hạn chế hiệu ứng không cần thiết trong Aujunpeak", icon: "sparkles", color: Palette.purple, isOn: $prefs.reduceEffects)
                    Divider().padding(.leading, 58)
                    settingToggle("Giữ màn hình sáng", caption: "Chỉ có hiệu lực khi Aujunpeak đang mở", icon: "sun.max.fill", color: Palette.orange, isOn: $prefs.keepScreenAwake)
                    Divider().padding(.leading, 58)
                    settingToggle("Thẻ game gọn", caption: "Rút gọn danh sách hiển thị trong Game Hub", icon: "rectangle.compress.vertical", color: Palette.blue, isOn: $prefs.compactCards)
                }.luxeCard(padding: 14)

                SectionHeading(title: "Công cụ hệ thống", trailing: "SAFE ACTIONS")
                VStack(spacing: 10) {
                    actionRow("Dọn bộ đệm mạng", subtitle: "Chỉ xóa cache thuộc Aujunpeak", icon: "trash.fill", tint: Palette.green) {
                        prefs.clearOwnCache()
                        toast.show("Đã xóa cache mạng của Aujunpeak.")
                    }
                    actionRow("Cập nhật trạng thái", subtitle: "Đọc lại pin, RAM, nhiệt và dung lượng", icon: "arrow.clockwise", tint: Palette.blue) {
                        monitor.refresh()
                        toast.show("Đã cập nhật thông số thiết bị.")
                    }
                    actionRow("Hướng dẫn Free Fire", subtitle: "Gợi ý tối ưu bằng cài đặt chính thức", icon: "gamecontroller.fill", tint: Palette.orange) {
                        showGuide = true
                    }
                }
                limitationNotice
                Spacer(minLength: 15)
            }.padding(.horizontal, 18).padding(.top, 15)
        }
        .appPage()
        .sheet(isPresented: $showGuide) { guideSheet }
    }

    private var boostHero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26).fill(
                LinearGradient(colors: [Color(hex: 0x191F45), Color(hex: 0x3E368C)],
                               startPoint: .topLeading, endPoint: .bottomTrailing))
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(.white.opacity(0.08)).frame(width: 93, height: 93)
                    Circle().stroke(Palette.cyan.opacity(0.45), lineWidth: 2).frame(width: 77, height: 77)
                    Image(systemName: "bolt.shield.fill")
                        .font(.system(size: 36, weight: .medium)).foregroundStyle(Palette.cyan)
                }
                VStack(alignment: .leading, spacing: 7) {
                    Text("CONTROL PRESET").font(.system(size: 10, weight: .bold))
                        .tracking(1.5).foregroundStyle(Palette.cyan)
                    Text(prefs.preset.rawValue)
                        .font(.system(size: 24, weight: .bold, design: .rounded)).foregroundStyle(.white)
                    Text("Thiết lập cho giao diện ứng dụng")
                        .font(.system(size: 10)).foregroundStyle(.white.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }.padding(18)
        }.frame(height: 145)
    }

    private func settingToggle(_ title: String, caption: String, icon: String,
                               color: Color, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            IconTile(symbol: icon, color: color, size: 42)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(Palette.text)
                Text(caption).font(.system(size: 10)).foregroundStyle(Palette.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 5)
            Toggle(title, isOn: isOn).labelsHidden().tint(Palette.purple)
                .onChange(of: isOn.wrappedValue) { _, value in
                    toast.show("\(title): \(value ? "Đã bật" : "Đã tắt")")
                }
        }.padding(.vertical, 10)
    }

    private func actionRow(_ title: String, subtitle: String, icon: String,
                           tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                IconTile(symbol: icon, color: tint)
                VStack(alignment: .leading, spacing: 5) {
                    Text(title).font(.system(size: 13, weight: .bold)).foregroundStyle(Palette.text)
                    Text(subtitle).font(.system(size: 10)).foregroundStyle(Palette.muted)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Palette.muted)
            }.luxeCard(padding: 14)
        }.buttonStyle(.plain)
    }

    private var limitationNotice: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Palette.blue).font(.system(size: 17))
            Text("iOS không cho phép Aujunpeak tăng FPS, giải phóng RAM hay can thiệp trực tiếp vào Free Fire và các ứng dụng khác. Các switch trên chỉ thay đổi trải nghiệm Aujunpeak.")
                .font(.system(size: 11)).foregroundStyle(Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }.luxeCard()
    }

    private var guideSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Label("Gợi ý cấu hình Free Fire", systemImage: "gamecontroller.fill")
                        .font(.system(size: 19, weight: .bold)).foregroundStyle(Palette.text)
                    Text("Các thiết lập dưới đây thực hiện trực tiếp trong iOS hoặc trong Free Fire; không thay đổi dữ liệu game.")
                        .font(.system(size: 12)).foregroundStyle(Palette.muted)
                    ForEach(Array([
                        ("Ổn định mạng", "Ưu tiên kết nối Wi-Fi ổn định hoặc mạng di động có tín hiệu tốt."),
                        ("Tiết kiệm pin", "Kiểm tra Chế độ nguồn điện thấp; cân đối pin và hiệu năng theo nhu cầu."),
                        ("Đồ họa trong game", "Trong Free Fire, chọn mức đồ họa phù hợp nhiệt độ và khả năng thiết bị."),
                        ("Giải phóng dung lượng", "Quản lý dung lượng qua Cài đặt iOS; không xóa dữ liệu game tùy tiện."),
                        ("Tránh quá nhiệt", "Khi thiết bị quá nóng, giảm độ sáng hoặc nghỉ để tránh giảm hiệu năng do nhiệt.")
                    ].enumerated()), id: \.offset) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                SmallTag(title: String(format: "%02d", item.offset + 1))
                                Text(item.element.0).font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Palette.text)
                            }
                            Text(item.element.1).font(.system(size: 12)).foregroundStyle(Palette.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }.luxeCard()
                    }
                }.padding(20)
            }
            .background(Palette.canvas)
            .navigationTitle("Game guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Đóng") { showGuide = false } } }
        }
        .presentationDragIndicator(.visible)
    }
}
