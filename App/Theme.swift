import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xff) / 255,
                  green: Double((hex >> 8) & 0xff) / 255,
                  blue: Double(hex & 0xff) / 255, opacity: 1)
    }
}

enum Palette {
    static let text = Color(hex: 0x151C31)
    static let muted = Color(hex: 0x8B96AD)
    static let purple = Color(hex: 0x6555F5)
    static let blue = Color(hex: 0x457DFF)
    static let cyan = Color(hex: 0x28C5DC)
    static let green = Color(hex: 0x14B995)
    static let orange = Color(hex: 0xF39C57)
    static let red = Color(hex: 0xEA5F76)
    static let line = Color(hex: 0xE9EDFA)
    static let canvas = Color(hex: 0xF6F8FD)
    static let lilac = Color(hex: 0xF0EFFF)
    static let gradient = LinearGradient(colors: [purple, blue], startPoint: .topLeading, endPoint: .bottomTrailing)
}

extension View {
    func luxeCard(padding: CGFloat = 17) -> some View {
        self.padding(padding)
            .background(.white, in: RoundedRectangle(cornerRadius: 23, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 23, style: .continuous).stroke(Palette.line, lineWidth: 1))
            .shadow(color: Palette.text.opacity(0.035), radius: 15, y: 6)
    }
    func appPage() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Palette.canvas.ignoresSafeArea())
    }
}

struct BrandMark: View {
    var size: CGFloat = 44
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                .fill(Palette.gradient)
            Image(systemName: "bolt.shield.fill")
                .font(.system(size: size * 0.43, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .shadow(color: Palette.purple.opacity(0.25), radius: 12, y: 5)
    }
}

struct BrandHeader: View {
    var eyebrow = "GAME CONTROL CENTER"
    var showBell = true
    @EnvironmentObject private var toast: ToastCenter
    var body: some View {
        HStack(spacing: 12) {
            BrandMark(size: 42)
            VStack(alignment: .leading, spacing: 3) {
                Text("AUJUNPEAK").font(.system(size: 17, weight: .black, design: .rounded))
                    .tracking(1.5).foregroundStyle(Palette.text)
                Text(eyebrow).font(.system(size: 9, weight: .bold))
                    .tracking(2).foregroundStyle(Palette.muted)
            }
            Spacer()
            if showBell {
                Button {
                    toast.show("Các thông báo hệ thống đang hoạt động", type: .info)
                } label: {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Palette.text)
                        .frame(width: 42, height: 42)
                        .background(.white, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Palette.line))
                }
                .accessibilityLabel("Thông báo")
            }
        }
    }
}

struct PageTitle: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.system(size: 29, weight: .bold, design: .rounded))
                .tracking(-0.8).foregroundStyle(Palette.text)
            Text(subtitle).font(.system(size: 13)).foregroundStyle(Palette.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SectionHeading: View {
    let title: String
    var trailing: String? = nil
    var body: some View {
        HStack {
            Text(title).font(.system(size: 17, weight: .bold)).foregroundStyle(Palette.text)
            Spacer()
            if let trailing {
                Text(trailing).font(.system(size: 11, weight: .semibold)).foregroundStyle(Palette.muted)
            }
        }
    }
}

struct IconTile: View {
    let symbol: String
    var color: Color = Palette.purple
    var size: CGFloat = 44
    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.40, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: size * 0.3))
    }
}

struct PrimaryButton: View {
    let title: String
    var symbol = "arrow.right"
    var busy = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Spacer()
                if busy { ProgressView().tint(.white) }
                else { Text(title); Image(systemName: symbol) }
                Spacer()
            }
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(.white)
            .frame(height: 53)
            .background(Palette.gradient, in: RoundedRectangle(cornerRadius: 17))
        }
        .disabled(busy)
        .buttonStyle(.plain)
    }
}

struct SmallTag: View {
    let title: String
    var color: Color = Palette.purple
    var body: some View {
        Text(title).font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 11).padding(.vertical, 6)
            .background(color.opacity(0.10), in: Capsule())
    }
}
