import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xff) / 255,
                  green: Double((hex >> 8) & 0xff) / 255,
                  blue: Double(hex & 0xff) / 255,
                  opacity: 1)
    }
}

enum Palette {
    static let text = Color(hex: 0x11182B)
    static let muted = Color(hex: 0x8793A9)
    static let purple = Color(hex: 0x6555F5)
    static let blue = Color(hex: 0x3C88FF)
    static let cyan = Color(hex: 0x24D0FF)
    static let green = Color(hex: 0x10C58A)
    static let orange = Color(hex: 0xF8A34F)
    static let red = Color(hex: 0xF26176)
    static let line = Color(hex: 0xE7ECF7)
    static let canvas = Color(hex: 0xF6F8FD)
    static let ice = Color(hex: 0xEEF4FF)
    static let lilac = Color(hex: 0xF1EEFF)
    static let gradient = LinearGradient(colors: [purple, blue], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let darkGradient = LinearGradient(colors: [Color(hex: 0x111A3A), Color(hex: 0x2E3072)], startPoint: .topLeading, endPoint: .bottomTrailing)
}

extension View {
    func luxeCard(padding: CGFloat = 16) -> some View {
        self.padding(padding)
            .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Palette.line, lineWidth: 1))
            .shadow(color: Palette.text.opacity(0.05), radius: 18, y: 10)
    }

    func appPage() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Palette.canvas.ignoresSafeArea())
    }
}

struct BrandMark: View {
    var size: CGFloat = 42
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                .fill(Palette.gradient)
            Image(systemName: "bolt.shield.fill")
                .font(.system(size: size * 0.40, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .shadow(color: Palette.purple.opacity(0.3), radius: 14, y: 7)
    }
}

struct BrandHeader: View {
    @EnvironmentObject private var toast: ToastCenter
    var body: some View {
        HStack(spacing: 12) {
            BrandMark(size: 40)
            HStack(spacing: 8) {
                SmallTag(title: "Preview", color: Palette.green)
                SmallTag(title: "Live UI", color: Palette.blue)
            }
            Spacer()
            Button {
                toast.show("Đã làm mới khu vực hiển thị.", type: .info)
            } label: {
                headerIcon("arrow.clockwise")
            }
            Button {
                toast.show("Bảng điều khiển đang hoạt động.", type: .success)
            } label: {
                headerIcon("bell.badge.fill")
            }
        }
    }

    private func headerIcon(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Palette.text)
            .frame(width: 42, height: 42)
            .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Palette.line))
    }
}

struct IconTile: View {
    let symbol: String
    var color: Color = Palette.purple
    var size: CGFloat = 42
    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.38, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: size * 0.32, style: .continuous))
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
                if busy {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: symbol)
                    Text(title)
                }
                Spacer()
            }
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(.white)
            .frame(height: 52)
            .background(Palette.gradient, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(busy)
    }
}

struct SmallTag: View {
    let title: String
    var color: Color = Palette.purple
    var body: some View {
        Text(title)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(color.opacity(0.11), in: Capsule())
    }
}

struct StatBadge: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.text)
                .lineLimit(1)
            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(Palette.muted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.canvas, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct SwitchRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            IconTile(symbol: icon, color: isOn ? Palette.purple : Palette.muted, size: 38)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 13, weight: .bold)).foregroundStyle(Palette.text)
                Text(subtitle).font(.system(size: 10)).foregroundStyle(Palette.muted)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

struct WingFlare: View {
    @State private var offset: CGFloat = 0
    var body: some View {
        HStack {
            wing(scale: 1)
            Spacer()
            wing(scale: -1)
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                offset = 8
            }
        }
    }

    private func wing(scale: CGFloat) -> some View {
        WingShape()
            .fill(LinearGradient(colors: [Color.white.opacity(0.0), Palette.cyan.opacity(0.18), Color.white.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
            .frame(width: 54, height: 80)
            .scaleEffect(x: scale, y: 1)
            .offset(x: scale * offset)
            .blur(radius: 0.3)
    }
}

struct WingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addCurve(to: CGPoint(x: rect.maxX, y: rect.minY + 8),
                   control1: CGPoint(x: rect.width * 0.28, y: rect.height * 0.1),
                   control2: CGPoint(x: rect.width * 0.7, y: rect.height * 0.05))
        p.addCurve(to: CGPoint(x: rect.width * 0.28, y: rect.maxY),
                   control1: CGPoint(x: rect.width * 0.95, y: rect.height * 0.55),
                   control2: CGPoint(x: rect.width * 0.56, y: rect.height * 0.95))
        p.addCurve(to: CGPoint(x: rect.minX, y: rect.midY),
                   control1: CGPoint(x: rect.width * 0.18, y: rect.height * 0.88),
                   control2: CGPoint(x: rect.width * 0.1, y: rect.height * 0.62))
        return p
    }
}
