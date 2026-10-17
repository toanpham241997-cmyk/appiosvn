import SwiftUI

struct BoostView: View {
    @EnvironmentObject private var prefs: BoostPreferences
    @EnvironmentObject private var toast: ToastCenter
    @State private var logs: [String] = [
        "system ready",
        "database sync ok",
        "function module online"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                BrandHeader()
                commandPanel
                functionSwitches
                databaseLayout
            }
            .padding(.horizontal, 18)
            .padding(.top, 15)
        }
        .appPage()
    }

    private var commandPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Log")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Palette.text)
                Spacer()
                Button {
                    logs.insert("manual refresh \(Date.now.formatted(date: .omitted, time: .shortened))", at: 0)
                    toast.show("Đã làm mới log.")
                } label: {
                    SmallTag(title: "refresh", color: Palette.blue)
                }
                .buttonStyle(.plain)
            }
            VStack(alignment: .leading, spacing: 8) {
                ForEach(logs.prefix(6), id: \.self) { item in
                    HStack(spacing: 10) {
                        Circle().fill(Palette.green).frame(width: 7, height: 7)
                        Text(item)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(Palette.text)
                        Spacer()
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0x101A31), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(alignment: .topLeading) {
                Text("terminal")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.62))
                    .padding(12)
            }
        }
        .luxeCard()
    }

    private var functionSwitches: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Switch")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Palette.text)
                Spacer()
                SmallTag(title: prefs.preset.rawValue, color: Palette.purple)
            }
            Group {
                SwitchRow(title: "Optimizer", subtitle: "nâng trải nghiệm trong app", icon: "bolt.fill", isOn: binding(\.optimizer, log: "optimizer"))
                Divider().overlay(Palette.line)
                SwitchRow(title: "Network Guard", subtitle: "duy trì kết nối ổn định", icon: "antenna.radiowaves.left.and.right", isOn: binding(\.networkGuard, log: "network guard"))
                Divider().overlay(Palette.line)
                SwitchRow(title: "FPS Overlay", subtitle: "hiển thị lớp UI mô phỏng", icon: "speedometer", isOn: binding(\.fpsOverlay, log: "fps overlay"))
                Divider().overlay(Palette.line)
                SwitchRow(title: "Keep Screen Awake", subtitle: "không tự tắt màn hình", icon: "iphone.and.arrow.forward", isOn: binding(\.keepScreenAwake, log: "idle timer"))
            }
            HStack(spacing: 10) {
                presetButton(.balanced)
                presetButton(.focus)
                presetButton(.minimal)
            }
        }
        .luxeCard()
    }

    private var databaseLayout: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data Layout")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Palette.text)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                dbCard("Profile DB", "cached", Palette.blue)
                dbCard("Touch Engine", "active", Palette.purple)
                dbCard("Route Table", "vn-01", Palette.green)
                dbCard("Game Access", "preview", Palette.orange)
            }
        }
        .luxeCard()
    }

    private func dbCard(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            IconTile(symbol: "cylinder.split.1x2.fill", color: color, size: 38)
            Text(title).font(.system(size: 12, weight: .bold)).foregroundStyle(Palette.text)
            Text(value).font(.system(size: 10)).foregroundStyle(Palette.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Palette.canvas, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func presetButton(_ preset: GamePreset) -> some View {
        Button {
            prefs.preset = preset
            logs.insert("preset -> \(preset.rawValue.lowercased())", at: 0)
            toast.show("Đã chuyển preset sang \(preset.rawValue).")
        } label: {
            Text(preset.rawValue)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(prefs.preset == preset ? .white : Palette.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(prefs.preset == preset ? Palette.gradient : LinearGradient(colors: [Color.white, Color.white], startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    if prefs.preset != preset {
                        RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Palette.line)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private func binding(_ keyPath: ReferenceWritableKeyPath<BoostPreferences, Bool>, log: String) -> Binding<Bool> {
        Binding(
            get: { prefs[keyPath: keyPath] },
            set: { value in
                prefs[keyPath: keyPath] = value
                logs.insert("\(log) -> \(value ? "on" : "off")", at: 0)
                toast.show("\(log.capitalized) \(value ? "bật" : "tắt").", type: .info)
            }
        )
    }
}
