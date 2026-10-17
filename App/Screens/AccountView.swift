import SwiftUI
import UIKit

struct AccountView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var monitor: DeviceMonitor
    @EnvironmentObject private var toast: ToastCenter
    @State private var showLogout = false
    @State private var showDeviceID = false
    private var profile: AuthenticatedProfile? { session.profile }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                BrandHeader(eyebrow: "MEMBER IDENTITY")
                PageTitle(title: "Tài khoản", subtitle: "Hồ sơ và thông tin iPhone hiện tại")
                profileHero
                SectionHeading(title: "Thiết bị đăng nhập", trailing: "LIVE DEVICE")
                VStack(spacing: 0) {
                    propertyRow("Tên thiết bị", value: monitor.snapshot.deviceName, icon: "iphone")
                    Divider().padding(.leading, 50)
                    propertyRow("Mã model", value: monitor.snapshot.hardwareModel, icon: "shippingbox")
                    Divider().padding(.leading, 50)
                    propertyRow("Hệ điều hành", value: monitor.snapshot.systemVersion, icon: "gearshape.2")
                    Divider().padding(.leading, 50)
                    propertyRow("Phiên bản ứng dụng", value: appVersion, icon: "app.badge")
                    Divider().padding(.leading, 50)
                    Button { showDeviceID = true } label: {
                        HStack(spacing: 12) {
                            IconTile(symbol: "number", color: Palette.purple, size: 39)
                            Text("Device ID (IDFV)").font(.system(size: 12, weight: .semibold)).foregroundStyle(Palette.text)
                            Spacer()
                            Text("Xem & sao chép").font(.system(size: 11)).foregroundStyle(Palette.purple)
                            Image(systemName: "chevron.right").font(.system(size: 10)).foregroundStyle(Palette.muted)
                        }.padding(.vertical, 10)
                    }.buttonStyle(.plain)
                }.luxeCard(padding: 14)
                SectionHeading(title: "Thông tin key", trailing: "XÁC THỰC SERVER")
                VStack(spacing: 0) {
                    propertyRow("Trạng thái", value: "Đã xác thực", icon: "checkmark.shield.fill")
                    Divider().padding(.leading, 50)
                    propertyRow("Loại tài khoản", value: profile?.tier ?? "—", icon: "crown")
                    Divider().padding(.leading, 50)
                    propertyRow("Mã key", value: "•••• •••• \(profile?.keySuffix ?? "")", icon: "key.fill")
                    Divider().padding(.leading, 50)
                    propertyRow("Hết hạn", value: profile?.expiresAt?.formatted(date: .abbreviated, time: .omitted) ?? "Theo máy chủ", icon: "calendar")
                }.luxeCard(padding: 14)
                Button { showLogout = true } label: {
                    HStack(spacing: 12) {
                        IconTile(symbol: "rectangle.portrait.and.arrow.right", color: Palette.red)
                        Text("Đăng xuất").font(.system(size: 14, weight: .bold)).foregroundStyle(Palette.red)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(Palette.muted)
                    }.luxeCard(padding: 14)
                }.buttonStyle(.plain)
                Text("Tên thiết bị có thể bị iOS giới hạn thành tên chung. Mã model là mã phần cứng do hệ điều hành cung cấp; IDFV không phải UDID/IMEI.")
                    .font(.system(size: 10)).foregroundStyle(Palette.muted)
                    .padding(.horizontal, 6)
                Spacer(minLength: 10)
            }.padding(.horizontal, 18).padding(.top, 15)
        }
        .appPage()
        .confirmationDialog("Đăng xuất khỏi Aujunpeak?", isPresented: $showLogout, titleVisibility: .visible) {
            Button("Hủy", role: .cancel) {}
            Button("Đăng xuất", role: .destructive) {
                session.logout()
                toast.show("Đã đăng xuất. Hãy nhập key để đăng nhập lại.", type: .info)
            }
        } message: { Text("Bạn cần nhập lại key để vào ứng dụng.") }
        .alert("IDFV của thiết bị", isPresented: $showDeviceID) {
            Button("Sao chép") {
                UIPasteboard.general.string = monitor.snapshot.vendorID
                toast.show("Đã sao chép mã IDFV.")
            }
            Button("Đóng", role: .cancel) {}
        } message: { Text(monitor.snapshot.vendorID) }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "2"
        return "\(v) (\(b))"
    }

    private var profileHero: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 26)
                .fill(LinearGradient(colors: [Color(hex: 0x151E43), Color(hex: 0x3C357E)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            Circle().stroke(.white.opacity(0.08), lineWidth: 27).frame(width: 180, height: 180)
                .offset(x: 220, y: -55)
            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 19).fill(.white.opacity(0.17))
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 37)).foregroundStyle(.white)
                    }.frame(width: 68, height: 68)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(profile?.displayName ?? "Member")
                            .font(.system(size: 19, weight: .bold, design: .rounded)).foregroundStyle(.white)
                            .lineLimit(1)
                        Text("VERIFIED MEMBER")
                            .font(.system(size: 10, weight: .bold)).tracking(1.7)
                            .foregroundStyle(Palette.cyan)
                    }
                }
                Rectangle().fill(.white.opacity(0.18)).frame(height: 1)
                HStack {
                    Label("\(profile?.tier ?? "Member") PLAN", systemImage: "crown.fill")
                    Spacer()
                    Label("ACTIVE", systemImage: "checkmark.seal.fill")
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.87))
            }.padding(22)
        }.frame(height: 173).clipped()
    }

    private func propertyRow(_ title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            IconTile(symbol: icon, color: Palette.purple, size: 39)
            Text(title).font(.system(size: 12, weight: .semibold)).foregroundStyle(Palette.text)
            Spacer(minLength: 8)
            Text(value).font(.system(size: 11, weight: .medium))
                .foregroundStyle(Palette.muted).lineLimit(2)
                .multilineTextAlignment(.trailing)
        }.padding(.vertical, 10)
    }
}
