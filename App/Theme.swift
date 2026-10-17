import SwiftUI

// MARK: - Design tokens
extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: 1
        )
    }
}

enum UIStyle {
    static let ink = Color(hex: 0x161C32)
    static let muted = Color(hex: 0x8490A9)
    static let blue = Color(hex: 0x5B5CFA)
    static let violet = Color(hex: 0x9466F8)
    static let ice = Color(hex: 0xF6F8FD)
    static let line = Color(hex: 0xEAEFFA)
    static let green = Color(hex: 0x22BE9D)
    static let orange = Color(hex: 0xFBAD5B)
    static let pink = Color(hex: 0xF174A7)
    static let gradient = LinearGradient(
        colors: [blue, violet], startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

struct SoftCard: ViewModifier {
    var padding: CGFloat = 17
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(UIStyle.line, lineWidth: 1))
            .shadow(color: UIStyle.ink.opacity(0.035), radius: 18, y: 7)
    }
}

extension View {
    func softCard(padding: CGFloat = 17) -> some View { modifier(SoftCard(padding: padding)) }
}

struct RoundIcon: View {
    let icon: String
    var tint: Color = UIStyle.blue
    var background: Color = Color(hex: 0xF0F0FF)
    var size: CGFloat = 48
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.38, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(background, in: RoundedRectangle(cornerRadius: size * 0.32, style: .continuous))
    }
}

struct SectionTitle: View {
    let title: String
    var subtitle: String? = nil
    var action: String? = nil
    var onAction: (() -> Void)? = nil
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 20, weight: .bold)).foregroundStyle(UIStyle.ink)
                if let subtitle { Text(subtitle).font(.system(size: 12)).foregroundStyle(UIStyle.muted) }
            }
            Spacer()
            if let action, let onAction {
                Button(action, action: onAction)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(UIStyle.blue)
            }
        }
    }
}

struct FilledAction: View {
    let title: String
    var icon: String = "arrow.right"
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Spacer()
                Text(title).font(.system(size: 15, weight: .bold))
                Image(systemName: icon).font(.system(size: 13, weight: .bold))
                Spacer()
            }
            .foregroundStyle(.white)
            .frame(height: 54)
            .background(UIStyle.gradient, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct AccentPill: View {
    let text: String
    let icon: String
    var color: Color = UIStyle.blue
    var body: some View {
        Label(text, systemImage: icon)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(color.opacity(0.10), in: Capsule())
    }
}

struct BackgroundCanvas: View {
    var body: some View {
        UIStyle.ice.ignoresSafeArea()
    }
}

struct BrandMark: View {
    var size: CGFloat = 54
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.30, style: .continuous)
                .fill(UIStyle.gradient)
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.system(size: size * 0.43, weight: .medium))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .shadow(color: UIStyle.blue.opacity(0.25), radius: 13, y: 7)
    }
}
