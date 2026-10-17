import SwiftUI
import UIKit

struct AccountView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var monitor: DeviceMonitor
    @EnvironmentObject private var toast: ToastCenter
    @State private var showLogout = false

    private var profile: AuthenticatedProfile? { session.profile }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                BrandHeader()
                profileHero
                infoGrid
                actionCard
            }
            .padding(.horizontal, 18)
            .padding(.top, 15)
        }
        .appPage()
        .confirmationDialog("Đăng xuất khỏi Aujunpeak?", isPresented: $showLogout, titleVisibility: .visible) {
            Button("Hủy", role: .cancel) {}
            Button("Đăng xuất", role: .destructive) {
                session.logout()
                toast.show("Đã đăng xuất khỏi bản preview.", type: .info)
            }
        }
    }

    private var profileHero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Palette.darkGradient)
            Circle().stroke(.white.opacity(0.08), lineWidth: 30)
                .frame(width: 180, height: 180)
                .offset(x: 210, y: -45)
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.white.opacity(0.16))
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 39))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 74, height: 74)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(profile?.displayName ?? "Player")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(profile?.provider ?? "Preview Sign In")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Palette.cyan)
                    }
                }
                HStack(spacing: 8) {
                    SmallTag(title: profile?.tier ?? "Preview", color: .white)
                    SmallTag(title: monitor.snapshot.hardwareModel, color: .white)
                }
            }
            .padding(20)
        }
        .frame(height: 190)
    }

    private var infoGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            accountCell("Tên máy", monitor.snapshot.deviceName, "iphone")
            accountCell("iOS", monitor.snapshot.systemVersion, "gearshape.2")
            accountCell("Model", monitor.snapshot.hardwareModel, "shippingbox")
            accountCell("IDFV", shortID(monitor.snapshot.vendorID), "number")
            accountCell("App", appVersion, "app.badge")
            accountCell("Thành viên từ", profile?.memberSince.formatted(date: .abbreviated, time: .omitted) ?? "Hôm nay", "calendar")
        }
    }

    private var actionCard: some View {
        VStack(spacing: 12) {
            Button {
                UIPasteboard.general.string = monitor.snapshot.vendorID
                toast.show("Đã sao chép IDFV.", type: .success)
            } label: {
                HStack(spacing: 12) {
                    IconTile(symbol: "doc.on.doc", color: Palette.purple, size: 40)
                    Text("Sao chép Device ID")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Palette.text)
                    Spacer()
                }
                .padding(12)
                .background(Palette.canvas, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)

            Button {
                showLogout = true
            } label: {
                HStack(spacing: 12) {
                    IconTile(symbol: "rectangle.portrait.and.arrow.right", color: Palette.red, size: 40)
                    Text("Đăng xuất")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Palette.red)
                    Spacer()
                }
                .padding(12)
                .background(Palette.canvas, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .luxeCard()
    }

    private func accountCell(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            IconTile(symbol: icon, color: Palette.purple, size: 38)
            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(Palette.muted)
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Palette.text)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
        .luxeCard(padding: 14)
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "3.0.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "4"
        return "\(v) (\(b))"
    }

    private func shortID(_ source: String) -> String {
        if source.count <= 14 { return source }
        return "\(source.prefix(6))…\(source.suffix(4))"
    }
}
