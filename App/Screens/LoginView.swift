import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var toast: ToastCenter
    @State private var key = ""
    @State private var showKey = false
    @FocusState private var keyFocused: Bool

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 11) {
                        BrandMark(size: 42)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("AUJUNPEAK").font(.system(size: 17, weight: .black, design: .rounded))
                                .tracking(1.6).foregroundStyle(Palette.text)
                            Text("PRIVATE ACCESS").font(.system(size: 9, weight: .bold))
                                .tracking(2.3).foregroundStyle(Palette.muted)
                        }
                        Spacer()
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 18)).foregroundStyle(Palette.green)
                    }
                    .padding(.top, 27)

                    Spacer(minLength: 45)
                    ZStack {
                        Circle().fill(Palette.purple.opacity(0.045)).frame(width: 258, height: 258)
                        Circle().stroke(Palette.purple.opacity(0.13), lineWidth: 1)
                            .frame(width: 223, height: 223)
                        Circle().stroke(Palette.blue.opacity(0.11), style: StrokeStyle(lineWidth: 1.4, dash: [4, 6]))
                            .frame(width: 184, height: 184)
                        RoundedRectangle(cornerRadius: 34)
                            .fill(Palette.gradient).frame(width: 112, height: 112)
                            .rotationEffect(.degrees(-9))
                            .shadow(color: Palette.purple.opacity(0.26), radius: 24, y: 13)
                        Image(systemName: "bolt.shield.fill")
                            .font(.system(size: 50, weight: .light))
                            .foregroundStyle(.white)
                        Image(systemName: "sparkle")
                            .font(.system(size: 23)).foregroundStyle(Palette.blue)
                            .offset(x: -108, y: -80)
                        Image(systemName: "sparkle")
                            .font(.system(size: 15)).foregroundStyle(Palette.purple)
                            .offset(x: 115, y: 67)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 9) {
                        HStack(spacing: 8) {
                            Circle().fill(Palette.green).frame(width: 7, height: 7)
                            Text("PREVIEW MEMBER AREA").font(.system(size: 10, weight: .bold))
                                .tracking(1.8).foregroundStyle(Palette.purple)
                        }
                        Text("Đăng nhập bằng key")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .tracking(-1).foregroundStyle(Palette.text)
                        Text("Không gian điều khiển game của riêng bạn.")
                            .font(.system(size: 13)).foregroundStyle(Palette.muted)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 25)

                    VStack(alignment: .leading, spacing: 11) {
                        Text("ACCESS KEY").font(.system(size: 11, weight: .bold))
                            .tracking(1.4).foregroundStyle(Palette.text)
                        HStack(spacing: 12) {
                            Image(systemName: "key.horizontal.fill")
                                .foregroundStyle(Palette.purple)
                            Group {
                                if showKey {
                                    TextField("Nhập key của bạn", text: $key)
                                } else {
                                    SecureField("Nhập key của bạn", text: $key)
                                }
                            }
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(.system(size: 14, weight: .medium))
                            .focused($keyFocused)
                            .submitLabel(.go)
                            .onSubmit { Task { await signIn() } }
                            Button { showKey.toggle() } label: {
                                Image(systemName: showKey ? "eye.slash" : "eye")
                                    .foregroundStyle(Palette.muted)
                            }
                            .accessibilityLabel(showKey ? "Ẩn key" : "Hiện key")
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 58)
                        .background(Palette.canvas, in: RoundedRectangle(cornerRadius: 17))
                        .overlay(RoundedRectangle(cornerRadius: 17).stroke(keyFocused ? Palette.purple : Palette.line, lineWidth: 1.3))

                        PrimaryButton(title: "Đăng nhập", symbol: "arrow.right", busy: session.isChecking) {
                            keyFocused = false
                            Task { await signIn() }
                        }
                        .padding(.top, 7)
                        if let error = session.loginError {
                            Label(error, systemImage: "exclamationmark.circle.fill")
                                .font(.system(size: 12)).foregroundStyle(Palette.red)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 5)
                        }
                    }

                    Spacer(minLength: 38)
                    HStack(spacing: 7) {
                        Image(systemName: "lock.shield")
                        Text("Xem trước offline · Không cần API hoặc máy chủ")
                    }
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Palette.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 27)
                .frame(minHeight: geo.size.height, alignment: .top)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.white.ignoresSafeArea())
        }
    }
    private func signIn() async {
        await session.login(key: key)
        if session.isLoggedIn {
            key = ""
            toast.show("Đăng nhập xem trước thành công. Chào mừng bạn!")
        } else if let message = session.loginError {
            toast.show(message, type: .error)
        }
    }
}
