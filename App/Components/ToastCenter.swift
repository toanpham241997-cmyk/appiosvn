import SwiftUI

enum ToastKind { case success, warning, info, error
    var tint: Color {
        switch self {
        case .success: return Palette.green
        case .warning: return Palette.orange
        case .info: return Palette.purple
        case .error: return Palette.red
        }
    }
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "sparkles"
        case .error: return "xmark.circle.fill"
        }
    }
}

struct ToastNotice: Identifiable {
    let id = UUID()
    let message: String
    let type: ToastKind
}

@MainActor final class ToastCenter: ObservableObject {
    @Published var current: ToastNotice?
    func show(_ message: String, type: ToastKind = .success) {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
            current = ToastNotice(message: message, type: type)
        }
    }
}

struct ToastBanner: View {
    @EnvironmentObject private var center: ToastCenter
    var body: some View {
        VStack {
            if let item = center.current {
                HStack(spacing: 12) {
                    Image(systemName: item.type.icon).font(.system(size: 20)).foregroundStyle(item.type.tint)
                    Text(item.message).font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Palette.text).fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 2)
                    Button { center.current = nil } label: {
                        Image(systemName: "xmark").font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Palette.muted)
                    }
                }
                .padding(15)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 19))
                .overlay(RoundedRectangle(cornerRadius: 19).stroke(item.type.tint.opacity(0.2)))
                .shadow(color: Palette.text.opacity(0.15), radius: 18, y: 9)
                .padding(.horizontal, 17)
                .transition(.move(edge: .top).combined(with: .opacity))
                .task(id: item.id) {
                    try? await Task.sleep(for: .seconds(3))
                    if center.current?.id == item.id {
                        withAnimation { center.current = nil }
                    }
                }
            }
            Spacer()
        }
        .padding(.top, 6)
        .allowsHitTesting(center.current != nil)
    }
}
