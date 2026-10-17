import SwiftUI
import UIKit

struct OverviewView: View {
    @Binding var tab: Int
    @EnvironmentObject private var monitor: DeviceMonitor
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var prefs: BoostPreferences
    @EnvironmentObject private var toast: ToastCenter

    private let columns = [GridItem(.flexible(), spacing: 11), GridItem(.flexible(), spacing: 11)]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 21) {
                BrandHeader()
                HStack(alignment: .firstTextBaseline) {
                    PageTitle(title: "Tổng quan", subtitle: "Game control center · iOS")
                    SmallTag(title: "LIVE", color: Palette.green)
                }
                hero
                SectionHeading(title: "Thông số thiết bị", trailing: "Dữ liệu thực từ iOS")
                LazyVGrid(columns: columns, spacing: 11) {
                    metric("RAM", value: DeviceSnapshot.readableBytes(monitor.snapshot.totalRAM), detail: "Tổng bộ nhớ vật lý", icon: "memorychip", tint: Palette.purple)
                    metric("CPU", value: "\(monitor.snapshot.coreCount) lõi", detail: "Số lõi khả dụng", icon: "cpu", tint: Palette.blue)
                    metric("Ứng dụng", value: monitor.snapshot.appMemory.map(DeviceSnapshot.readableBytes) ?? "—", detail: "RAM Aujunpeak sử dụng", icon: "chart.bar.fill", tint: Palette.green)
                    metric("Pin", value: monitor.snapshot.battery.map { "\($0)%" } ?? "—", detail: "Dung lượng pin", icon: "battery.75percent", tint: Palette.orange)
                }
                deviceIDCard
                SectionHeading(title: "Trung tâm thao tác", trailing: "Quick actions")
                LazyVGrid(columns: columns, spacing: 11) {
                    actionTile("Thư viện game", caption: "App Store Việt Nam", icon: "gamecontroller.fill", tint: Palette.blue) { tab = 1 }
                    actionTile("Game preset", caption: "Tùy chọn trong app", icon: "bolt.fill", tint: Palette.purple) { tab = 2 }
                    actionTile("Dọn cache app", caption: "Chỉ dữ liệu Aujunpeak", icon: "trash.slash.fill", tint: Palette.green) {
                        prefs.clearOwnCache()
                        toast.show("Đã xóa bộ đệm mạng của Aujunpeak.")
                    }
                    actionTile("Làm mới", caption: "Cập nhật thông số", icon: "arrow.clockwise", tint: Palette.orange) {
                        monitor.refresh()
                        toast.show("Đã cập nhật thông số thiết bị.")
                    }
                }
                if prefs.preset == .focus {
                    HStack(spacing: 11) {
                        IconTile(symbol: "scope", color: Palette.green)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Chế độ tập trung đang bật")
                                .font(.system(size: 12, weight: .bold)).foregroundStyle(Palette.text)
                            Text("Đã rút gọn các khu vực phụ trong Tổng quan.")
                                .font(.system(size: 11)).foregroundStyle(Palette.muted)
                        }
                    }.luxeCard()
                } else {
                    healthCard
                }
                Spacer(minLength: 15)
            }
            .padding(.horizontal, 18).padding(.top, 15)
        }
        .appPage()
    }

    private var hero: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 26).fill(Palette.gradient)
            Circle().stroke(.white.opacity(0.13), lineWidth: 29)
                .frame(width: 190, height: 190).offset(x: 205, y: -70)
            Circle().fill(.white.opacity(0.08))
                .frame(width: 115, height: 115).offset(x: 240, y: 90)
            VStack(alignment: .leading, spacing: 13) {
                HStack(spacing: 7) {
                    Image(systemName: "sparkle")
                    Text("AUJUNPEAK GAME SPACE")
                }
                .font(.system(size: 10, weight: .bold)).tracking(1.4)
                .foregroundStyle(.white.opacity(0.83))
                Text("Sẵn sàng cho\ntrận đấu tiếp theo?")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 8) {
                    Label(prefs.preset.rawValue, systemImage: "slider.horizontal.3")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(.white.opacity(0.19), in: Capsule())
                    Spacer()
                    Button { tab = 2 } label: {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 37, height: 37)
                            .background(.white.opacity(0.23), in: Circle())
                    }
                }.foregroundStyle(.white)
            }.padding(21)
        }
        .frame(height: 210).clipped()
    }

    private func metric(_ label: String, value: String, detail: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconTile(symbol: icon, color: tint, size: 39)
                Spacer()
                Circle().fill(Palette.green).frame(width: 6, height: 6)
            }
            Text(value).font(.system(size: 23, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.65).lineLimit(1).foregroundStyle(Palette.text)
            VStack(alignment: .leading, spacing: 4) {
                Text(label).font(.system(size: 12, weight: .bold)).foregroundStyle(Palette.text)
                Text(detail).font(.system(size: 10)).foregroundStyle(Palette.muted)
                    .lineLimit(2).fixedSize(horizontal: false, vertical: true)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 130)
            .luxeCard(padding: 15)
    }

    private var deviceIDCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconTile(symbol: "iphone.gen3.radiowaves.left.and.right", color: Palette.purple, size: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Device ID · IDFV")
                        .font(.system(size: 13, weight: .bold)).foregroundStyle(Palette.text)
                    Text("Định danh ứng dụng do iOS cung cấp")
                        .font(.system(size: 10)).foregroundStyle(Palette.muted)
                }
                Spacer()
                Button {
                    UIPasteboard.general.string = monitor.snapshot.vendorID
                    toast.show("Đã sao chép IDFV của thiết bị.")
                } label: {
                    Image(systemName: "doc.on.doc").foregroundStyle(Palette.purple)
                        .frame(width: 36, height: 36).background(Palette.lilac, in: RoundedRectangle(cornerRadius: 12))
                }.accessibilityLabel("Sao chép IDFV")
            }
            Text(monitor.snapshot.vendorID)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(Palette.text)
                .textSelection(.enabled)
                .lineLimit(2)
            Text("IDFV không phải UDID/IMEI và có thể thay đổi khi gỡ hết ứng dụng cùng nhà phát triển.")
                .font(.system(size: 10)).foregroundStyle(Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }.luxeCard()
    }

    private func actionTile(_ title: String, caption: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 15) {
                IconTile(symbol: icon, color: tint, size: 44)
                VStack(alignment: .leading, spacing: 5) {
                    Text(title).font(.system(size: 13, weight: .bold)).foregroundStyle(Palette.text)
                    Text(caption).font(.system(size: 10)).foregroundStyle(Palette.muted)
                        .lineLimit(2)
                }
                HStack {
                    Spacer()
                    Image(systemName: "arrow.up.right").font(.system(size: 11, weight: .bold))
                        .foregroundStyle(tint)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
            .luxeCard(padding: 15)
        }.buttonStyle(.plain)
    }

    private var healthCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeading(title: "Tình trạng hệ thống")
            HStack {
                Label("Nhiệt: \(monitor.snapshot.thermal)", systemImage: "thermometer.medium")
                Spacer()
                SmallTag(title: "THEO DÕI", color: Palette.green)
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Palette.text)
            Divider().overlay(Palette.line)
            HStack {
                Label("Bộ nhớ trống", systemImage: "internaldrive")
                Spacer()
                Text(DeviceSnapshot.readableBytes(monitor.snapshot.storageFree))
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Palette.text)
            Text("Các thống kê thể hiện giá trị iOS cung cấp; Aujunpeak không can thiệp hiệu năng của ứng dụng khác.")
                .font(.system(size: 10)).foregroundStyle(Palette.muted)
        }.luxeCard()
    }
}
