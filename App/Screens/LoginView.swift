import SwiftUI

struct LoginView: View {
    let onLogin: (Bool) -> Void
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var rememberMe = true
    @State private var error: String? = nil
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 13) {
                        BrandMark(size: 47)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("AUJUNPEAK").font(.system(size: 16, weight: .black, design: .rounded)).tracking(2)
                            Text("CREATIVE SPACE").font(.system(size: 9, weight: .semibold)).tracking(2.7).foregroundStyle(UIStyle.muted)
                        }
                        Spacer()
                        Image(systemName: "sparkle").foregroundStyle(UIStyle.violet)
                    }
                    .padding(.top, 20)

                    visualPreview
                        .padding(.top, 31)
                        .padding(.bottom, 29)

                    Text("Chào mừng\ntrở lại 👋")
                        .font(.system(size: 35, weight: .bold, design: .rounded))
                        .tracking(-1.5)
                        .foregroundStyle(UIStyle.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Đăng nhập để khám phá không gian số hiện đại của bạn.")
                        .font(.system(size: 14))
                        .foregroundStyle(UIStyle.muted)
                        .padding(.top, 9)
                        .padding(.bottom, 26)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Địa chỉ email").font(.system(size: 13, weight: .semibold)).foregroundStyle(UIStyle.ink)
                        HStack(spacing: 12) {
                            Image(systemName: "envelope").foregroundStyle(UIStyle.muted)
                            TextField("name@example.com", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .password }
                        }
                        .padding(.horizontal, 15)
                        .frame(height: 54)
                        .background(UIStyle.ice, in: RoundedRectangle(cornerRadius: 16))

                        Text("Mật khẩu").font(.system(size: 13, weight: .semibold)).foregroundStyle(UIStyle.ink).padding(.top, 7)
                        HStack(spacing: 12) {
                            Image(systemName: "lock").foregroundStyle(UIStyle.muted)
                            Group {
                                if showPassword {
                                    TextField("Tối thiểu 6 ký tự", text: $password)
                                } else {
                                    SecureField("Tối thiểu 6 ký tự", text: $password)
                                }
                            }
                            .textContentType(.password)
                            .focused($focusedField, equals: .password)
                            Button { showPassword.toggle() } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundStyle(UIStyle.muted)
                            }
                            .accessibilityLabel(showPassword ? "Ẩn mật khẩu" : "Hiện mật khẩu")
                        }
                        .padding(.horizontal, 15)
                        .frame(height: 54)
                        .background(UIStyle.ice, in: RoundedRectangle(cornerRadius: 16))
                    }
                    HStack {
                        Toggle(isOn: $rememberMe) {
                            Text("Ghi nhớ phiên demo").font(.system(size: 12)).foregroundStyle(UIStyle.muted)
                        }
                        .toggleStyle(.checkboxLike)
                    }
                    .padding(.vertical, 15)

                    if let error {
                        Label(error, systemImage: "exclamationmark.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.red)
                            .padding(.bottom, 10)
                    }

                    FilledAction(title: "Đăng nhập", icon: "arrow.right", action: login)

                    Button { onLogin(rememberMe) } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "sparkles")
                            Text("Khám phá bản demo ngay")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(UIStyle.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                    }
                    Text("Bản mẫu giao diện • Đăng nhập minh họa, chưa có máy chủ")
                        .font(.system(size: 10))
                        .foregroundStyle(UIStyle.muted)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 18)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 27)
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height, alignment: .top)
            }
            .background(Color.white)
        }
    }

    private var visualPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 29, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: 0xEDEBFF), Color(hex: 0xF6F8FE), Color(hex: 0xFFF3F7)], startPoint: .topLeading, endPoint: .bottomTrailing))
            Circle().fill(UIStyle.violet.opacity(0.13)).frame(width: 170).offset(x: 142, y: -63)
            Circle().fill(UIStyle.blue.opacity(0.12)).frame(width: 115).offset(x: -135, y: 90)
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 13) {
                    Text("YOUR WORKSPACE").font(.system(size: 9, weight: .heavy)).tracking(1.4).foregroundStyle(UIStyle.muted)
                    Text("Design with\nfreedom.").font(.system(size: 22, weight: .bold, design: .rounded)).foregroundStyle(UIStyle.ink)
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                        Text("Made to inspire")
                    }
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(UIStyle.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(.white, in: Capsule())
                }
                Spacer(minLength: 0)
                VStack(spacing: 10) {
                    miniCard(icon: "chart.xyaxis.line", title: "Analytics", tint: UIStyle.blue, rotation: 7)
                    miniCard(icon: "square.grid.2x2.fill", title: "UI Kit", tint: UIStyle.pink, rotation: -6)
                }
            }
            .padding(20)
        }
        .frame(height: 184)
        .clipped()
    }

    private func miniCard(icon: String, title: String, tint: Color, rotation: Double) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            RoundIcon(icon: icon, tint: tint, background: tint.opacity(0.11), size: 31)
            Text(title).font(.system(size: 10, weight: .bold)).foregroundStyle(UIStyle.ink)
            RoundedRectangle(cornerRadius: 3).fill(tint.opacity(0.3)).frame(width: 58, height: 5)
        }
        .frame(width: 97, alignment: .leading)
        .padding(12)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: UIStyle.blue.opacity(0.10), radius: 13, y: 7)
        .rotationEffect(.degrees(rotation))
    }

    private func login() {
        guard email.contains("@"), email.contains("."), password.count >= 6 else {
            error = "Nhập email hợp lệ và mật khẩu từ 6 ký tự."
            return
        }
        error = nil
        focusedField = nil
        // Local preview only; no password is transmitted or stored.
        onLogin(rememberMe)
    }
}

private struct CheckboxLike: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button { configuration.isOn.toggle() } label: {
            HStack(spacing: 9) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .font(.system(size: 19))
                    .foregroundStyle(configuration.isOn ? UIStyle.blue : UIStyle.muted)
                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}

private extension ToggleStyle where Self == CheckboxLike {
    static var checkboxLike: CheckboxLike { CheckboxLike() }
}
