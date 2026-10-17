import SwiftUI
import UIKit

struct OverviewView: View {
    @Binding var tab: Int
    @EnvironmentObject private var monitor: DeviceMonitor
    @EnvironmentObject private var prefs: BoostPreferences
    @EnvironmentObject private var toast: ToastCenter

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                BrandHeader()
                heroCard
                chartsRow
                deviceCard
                actionPanel
                Spacer(minLength: 18)
            }
            .padding(.horizontal, 18)
            .padding(.top, 15)
        }
        .appPage()
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            Image("WropychHero")
                .resizable()
                .scaledToFill()
                .overlay {
                    LinearGradient(colors: [Color.black.opacity(0.08), Color.black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                }
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    SmallTag(title: "Wropych", color: .white)
                    SmallTag(title: prefs.preset.rawValue, color: .white)
                }
                Text("Aujunpeak Wropych VN")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                HStack(spacing: 10) {
                    tinyHeroButton("Function", icon: "switch.2") { tab = 2 }
                    tinyHeroButton("Game", icon: "gamecontroller.fill") { tab = 1 }
                    Spacer()
                }
            }
            .padding(18)
        }
        .frame(height: 218)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.white.opacity(0.25)))
        .shadow(color: Palette.text.opacity(0.12), radius: 16, y: 10)
    }

    private var chartsRow: some View {
        HStack(spacing: 12) {
            UsageChartCard(title: "RAM", color: Palette.purple, valueText: DeviceSnapshot.readableBytes(monitor.snapshot.totalRAM), progress: min(0.92, Double(monitor.snapshot.totalRAM) / Double(max(monitor.snapshot.totalRAM + monitor.snapshot.storageTotal, 1))))
            UsageChartCard(title: "CPU", color: Palette.blue, valueText: "\(monitor.snapshot.coreCount) lõi", progress: min(1, Double(monitor.snapshot.coreCount) / 8.0))
        }
    }

    private var deviceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Device")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Palette.text)
                    Text("thông tin thiết bị hiển thị gọn gàng")
                        .font(.system(size: 11))
                        .foregroundStyle(Palette.muted)
                }
                Spacer()
                Button {
                    UIPasteboard.general.string = monitor.snapshot.vendorID
                    toast.show("Đã sao chép IDFV thiết bị.", type: .success)
                } label: {
                    IconTile(symbol: "doc.on.doc", color: Palette.purple, size: 40)
                }
                .buttonStyle(.plain)
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                StatBadge(title: "Tên máy", value: monitor.snapshot.deviceName)
                StatBadge(title: "Model", value: monitor.snapshot.hardwareModel)
                StatBadge(title: "iOS", value: monitor.snapshot.systemVersion)
                StatBadge(title: "Pin", value: monitor.snapshot.battery.map { "\($0)%" } ?? "—")
                StatBadge(title: "Bộ nhớ trống", value: DeviceSnapshot.readableBytes(monitor.snapshot.storageFree))
                StatBadge(title: "IDFV", value: shortID(monitor.snapshot.vendorID))
            }
        }
        .luxeCard()
    }

    private var actionPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Control Center")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Palette.text)
                Spacer()
                SmallTag(title: "Preview", color: Palette.orange)
            }
            VStack(spacing: 6) {
                SwitchRow(title: "Aimlock Preview", subtitle: "giao diện công tắc trong app", icon: "scope", isOn: $prefs.aimAssist)
                    .onChange(of: prefs.aimAssist) { _, value in toast.show(value ? "Aimlock Preview đã bật." : "Aimlock Preview đã tắt.", type: .info) }
                Divider().overlay(Palette.line)
                SwitchRow(title: "Touch Sync", subtitle: "tối ưu cảm giác thao tác", icon: "hand.tap.fill", isOn: $prefs.touchSync)
                Divider().overlay(Palette.line)
                SwitchRow(title: "Head Trace", subtitle: "giao diện mô phỏng theo dõi mục tiêu", icon: "location.north.line.fill", isOn: $prefs.headTrace)
                Divider().overlay(Palette.line)
                SwitchRow(title: "Optimizer", subtitle: "tăng trải nghiệm trong chính app", icon: "bolt.fill", isOn: $prefs.optimizer)
            }
            HStack(spacing: 10) {
                actionButton(title: "Refresh", icon: "arrow.clockwise", tint: Palette.blue) {
                    monitor.refresh()
                    toast.show("Đã làm mới thông số thiết bị.")
                }
                actionButton(title: "Cache", icon: "trash.fill", tint: Palette.green) {
                    prefs.clearOwnCache()
                    toast.show("Đã xóa bộ đệm của Aujunpeak.")
                }
                actionButton(title: "Function", icon: "switch.2", tint: Palette.purple) {
                    tab = 2
                }
            }
        }
        .luxeCard()
    }

    private func tinyHeroButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(.white.opacity(0.16), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func actionButton(title: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                IconTile(symbol: icon, color: tint, size: 42)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Palette.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Palette.canvas, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func shortID(_ source: String) -> String {
        if source.count <= 14 { return source }
        let prefix = source.prefix(6)
        let suffix = source.suffix(4)
        return "\(prefix)…\(suffix)"
    }
}

struct UsageChartCard: View {
    let title: String
    let color: Color
    let valueText: String
    let progress: Double
    @State private var animated = 0.08

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Palette.text)
                Spacer()
                Circle().fill(color).frame(width: 8, height: 8)
            }
            ZStack {
                Circle().stroke(color.opacity(0.12), lineWidth: 11)
                Circle()
                    .trim(from: 0, to: animated)
                    .stroke(LinearGradient(colors: [color, Palette.cyan], startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 11, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 4) {
                    Text(valueText)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Palette.text)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Text("running")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Palette.muted)
                }
            }
            .frame(height: 108)
            miniBars
        }
        .frame(maxWidth: .infinity)
        .luxeCard()
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animated = max(0.12, min(progress, 0.96))
            }
        }
    }

    private var miniBars: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(0..<7, id: \.self) { index in
                Capsule()
                    .fill(index < Int((animated * 10).rounded()) ? color : color.opacity(0.16))
                    .frame(maxWidth: .infinity)
                    .frame(height: 16 + CGFloat((index * 9) % 38))
            }
        }
        .frame(height: 46)
    }
}
