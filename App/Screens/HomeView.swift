import SwiftUI
import Charts

private struct WeekDay: Identifiable {
    let id: String
    let value: Double
}

struct HomeView: View {
    @EnvironmentObject private var store: DemoStore
    @Binding var selectedTab: Int
    @State private var showAnnouncement = false

    private let weekly: [WeekDay] = [WeekDay(id: "T2", value: 30), WeekDay(id: "T3", value: 47), WeekDay(id: "T4", value: 36), WeekDay(id: "T5", value: 76), WeekDay(id: "T6", value: 59), WeekDay(id: "T7", value: 88), WeekDay(id: "CN", value: 67)]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 23) {
                    HStack(spacing: 12) {
                        BrandMark(size: 49)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("XIN CHÀO 👋").font(.system(size: 10, weight: .bold)).tracking(1.5).foregroundStyle(UIStyle.muted)
                            Text(store.userName).font(.system(size: 21, weight: .bold, design: .rounded)).foregroundStyle(UIStyle.ink).lineLimit(1)
                        }
                        Spacer()
                        Button { showAnnouncement = true } label: {
                            ZStack(alignment: .topTrailing) {
                                RoundIcon(icon: "bell", tint: UIStyle.ink, background: .white, size: 46)
                                if !store.announcementsRead {
                                    Circle().fill(UIStyle.pink).frame(width: 9, height: 9).offset(x: -6, y: 5)
                                }
                            }
                        }
                        .accessibilityLabel("Thông báo")
                    }
                    heroCard
                    SectionTitle(title: "Tổng quan hôm nay", subtitle: "Thông số minh họa cho bộ giao diện")
                    HStack(spacing: 12) {
                        metricCard(value: "24.8K", label: "Lượt xem", icon: "eye.fill", tint: UIStyle.blue, change: "+12.8%")
                        metricCard(value: "1,284", label: "Tương tác", icon: "heart.fill", tint: UIStyle.pink, change: "+8.2%")
                    }
                    HStack(spacing: 12) {
                        metricCard(value: "96%", label: "Hiệu suất", icon: "bolt.fill", tint: UIStyle.orange, change: "+5.4%")
                        metricCard(value: "\(store.completedCount)/\(store.tasks.count)", label: "Việc đã xong", icon: "checkmark.seal.fill", tint: UIStyle.green, change: "Cập nhật")
                    }
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Thống kê hoạt động").font(.system(size: 17, weight: .bold)).foregroundStyle(UIStyle.ink)
                                Text("Biểu đồ dữ liệu mẫu • 7 ngày").font(.system(size: 11)).foregroundStyle(UIStyle.muted)
                            }
                            Spacer()
                            AccentPill(text: "Tuần này", icon: "calendar")
                        }
                        Chart(weekly) { item in
                            BarMark(x: .value("Ngày", item.id), y: .value("Hoạt động", item.value), width: .ratio(0.52))
                                .foregroundStyle(UIStyle.gradient)
                                .cornerRadius(7)
                        }
                        .chartYScale(domain: 0...100)
                        .chartYAxis(.hidden)
                        .chartXAxis(.visible)
                        .frame(height: 155)
                    }
                    .softCard()
                    SectionTitle(title: "Truy cập nhanh")
                    HStack(spacing: 12) {
                        quickAction(icon: "square.stack.3d.up", title: "UI Gallery", subtitle: "Khám phá", tint: UIStyle.violet) { selectedTab = 1 }
                        quickAction(icon: "checklist", title: "Công việc", subtitle: "Quản lý", tint: UIStyle.green) { selectedTab = 2 }
                        quickAction(icon: "bubble.left", title: "Tin nhắn", subtitle: "Trò chuyện", tint: UIStyle.orange) { selectedTab = 3 }
                    }
                    SectionTitle(title: "Công việc gần đây", action: "Xem tất cả", onAction: { selectedTab = 2 })
                    VStack(spacing: 0) {
                        ForEach(Array(store.tasks.prefix(3))) { task in
                            HStack(spacing: 12) {
                                Image(systemName: task.done ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(task.done ? UIStyle.green : UIStyle.muted)
                                    .font(.system(size: 20))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(task.title).font(.system(size: 13, weight: .semibold)).foregroundStyle(UIStyle.ink).lineLimit(1)
                                    Text(task.category).font(.system(size: 11)).foregroundStyle(UIStyle.muted)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 11, weight: .bold)).foregroundStyle(UIStyle.muted)
                            }
                            .padding(.vertical, 12)
                            if task.id != store.tasks.prefix(3).last?.id { Divider().overlay(UIStyle.line) }
                        }
                    }
                    .softCard()
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 35)
            }
            .background(BackgroundCanvas())
            .toolbar(.hidden, for: .navigationBar)
            .alert("Thông báo", isPresented: $showAnnouncement) {
                Button("Đã hiểu") { store.announcementsRead = true }
            } message: {
                Text("Chào mừng đến Aujunpeak VN! Đây là bản trải nghiệm giao diện iOS được xây dựng bằng SwiftUI.")
            }
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 27, style: .continuous).fill(UIStyle.gradient)
            Circle().stroke(.white.opacity(0.13), lineWidth: 25).frame(width: 195).offset(x: 215, y: -45)
            Circle().stroke(.white.opacity(0.11), lineWidth: 20).frame(width: 140).offset(x: 230, y: 100)
            VStack(alignment: .leading, spacing: 11) {
                Text("YOUR CREATIVE HUB").font(.system(size: 9, weight: .black)).tracking(2.1).foregroundStyle(.white.opacity(0.70))
                Text("Làm việc thông minh.\nSáng tạo không giới hạn.")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Button { selectedTab = 1 } label: {
                    HStack(spacing: 7) {
                        Text("Khám phá ngay")
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(UIStyle.blue)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 11)
                    .background(.white, in: Capsule())
                }
                .padding(.top, 3)
            }
            .padding(23)
        }
        .frame(height: 203)
        .clipShape(RoundedRectangle(cornerRadius: 27))
    }

    private func metricCard(value: String, label: String, icon: String, tint: Color, change: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                RoundIcon(icon: icon, tint: tint, background: tint.opacity(0.10), size: 39)
                Spacer(minLength: 2)
                Text(change).font(.system(size: 10, weight: .bold)).foregroundStyle(UIStyle.green)
            }
            Text(value).font(.system(size: 25, weight: .bold, design: .rounded)).foregroundStyle(UIStyle.ink).lineLimit(1).minimumScaleFactor(0.72)
            Text(label).font(.system(size: 12)).foregroundStyle(UIStyle.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard(padding: 15)
    }

    private func quickAction(icon: String, title: String, subtitle: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                RoundIcon(icon: icon, tint: tint, background: tint.opacity(0.11), size: 41)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.system(size: 12, weight: .bold)).foregroundStyle(UIStyle.ink).lineLimit(1).minimumScaleFactor(0.72)
                    Text(subtitle).font(.system(size: 10)).foregroundStyle(UIStyle.muted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .softCard(padding: 12)
        }
        .buttonStyle(.plain)
    }
}
