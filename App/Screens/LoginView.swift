import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var toast: ToastCenter

    var body: some View {
        GeometryReader { _ in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer(minLength: 24)
                    ZStack {
                        Circle().fill(Palette.purple.opacity(0.06)).frame(width: 280, height: 280)
                        Circle().stroke(Palette.blue.opacity(0.14), lineWidth: 1).frame(width: 220, height: 220)
                        RoundedRectangle(cornerRadius: 38, style: .continuous)
                            .fill(Palette.gradient)
                            .frame(width: 110, height: 110)
                            .rotationEffect(.degrees(-10))
                            .shadow(color: Palette.purple.opacity(0.25), radius: 25, y: 14)
                        Image(systemName: "bolt.shield.fill")
                            .font(.system(size: 54, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    VStack(spacing: 8) {
                        Text("Aujunpeak VN")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Palette.text)
                        Text("đăng nhập nhanh để xem toàn bộ giao diện preview")
                            .font(.system(size: 13))
                            .foregroundStyle(Palette.muted)
                            .multilineTextAlignment(.center)
                    }
                    VStack(spacing: 14) {
                        providerButton(.google, subtitle: "đăng nhập preview một chạm")
                        providerButton(.github, subtitle: "truy cập giao diện đầy đủ")
                    }
                    .luxeCard(padding: 18)

                    HStack(spacing: 10) {
                        SmallTag(title: "Google", color: Palette.red)
                        SmallTag(title: "GitHub", color: Palette.blue)
                        SmallTag(title: "Preview UI", color: Palette.green)
                    }

                    Text("Bản này dùng đăng nhập mô phỏng để xem trước giao diện. Bạn có thể bổ sung OAuth/API thật ở bước sau.")
                        .font(.system(size: 11))
                        .foregroundStyle(Palette.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
            }
        }
        .appPage()
        .onChange(of: session.isLoggedIn) { _, loggedIn in
            if loggedIn { toast.show("Đăng nhập thành công. Chào mừng bạn!", type: .success) }
        }
    }

    private func providerButton(_ provider: LoginProvider, subtitle: String) -> some View {
        Button {
            Task { await session.signIn(with: provider) }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Palette.canvas)
                    Image(systemName: provider.symbol)
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(provider == .google ? Palette.red : Palette.text)
                }
                .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Tiếp tục với \(provider.rawValue)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Palette.text)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Palette.muted)
                }
                Spacer()
                if session.isChecking {
                    ProgressView().tint(Palette.purple)
                } else {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Palette.purple)
                }
            }
            .padding(10)
            .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Palette.line))
        }
        .buttonStyle(.plain)
        .disabled(session.isChecking)
    }
}
