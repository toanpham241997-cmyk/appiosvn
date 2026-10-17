import SwiftUI

struct ShowcaseItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let category: String
}

private let catalog: [ShowcaseItem] = [
    ShowcaseItem(id: "analytics", title: "Analytics", subtitle: "Dashboard & biểu đồ", icon: "chart.bar.xaxis", tint: UIStyle.blue, category: "Dashboard"),
    ShowcaseItem(id: "payments", title: "Payments", subtitle: "Tài chính & ví", icon: "creditcard.fill", tint: UIStyle.violet, category: "Dashboard"),
    ShowcaseItem(id: "commerce", title: "E-Commerce", subtitle: "Danh mục sản phẩm", icon: "bag.fill", tint: UIStyle.pink, category: "Thương mại"),
    ShowcaseItem(id: "fitness", title: "Wellness", subtitle: "Sức khỏe & thói quen", icon: "heart.text.square.fill", tint: UIStyle.green, category: "Đời sống"),
    ShowcaseItem(id: "music", title: "Music Player", subtitle: "Giải trí & media", icon: "music.note", tint: UIStyle.orange, category: "Đời sống"),
    ShowcaseItem(id: "travel", title: "Travel", subtitle: "Khám phá thế giới", icon: "airplane", tint: UIStyle.blue, category: "Đời sống")
]

struct ExploreView: View {
    @EnvironmentObject private var store: DemoStore
    @State private var query = ""
    @State private var filter = "Tất cả"
    @State private var selected: ShowcaseItem?
    @State private var showFavoritesOnly = false
    private let filters = ["Tất cả", "Dashboard", "Thương mại", "Đời sống"]

    private var filtered: [ShowcaseItem] {
        catalog.filter {
            (filter == "Tất cả" || $0.category == filter) &&
            (!showFavoritesOnly || store.favorites.contains($0.id)) &&
            (query.isEmpty || $0.title.localizedCaseInsensitiveContains(query) || $0.subtitle.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 21) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Explore UI").font(.system(size: 31, weight: .bold, design: .rounded)).foregroundStyle(UIStyle.ink)
                            Text("Bộ sưu tập giao diện đầy cảm hứng")
                                .font(.system(size: 13)).foregroundStyle(UIStyle.muted)
                        }
                        Spacer()
                        Button { showFavoritesOnly.toggle() } label: {
                            RoundIcon(icon: showFavoritesOnly ? "heart.fill" : "heart", tint: UIStyle.pink, background: .white, size: 45)
                        }
                        .accessibilityLabel("Lọc yêu thích")
                    }
                    HStack(spacing: 11) {
                        Image(systemName: "magnifyingglass").foregroundStyle(UIStyle.muted)
                        TextField("Tìm mẫu giao diện...", text: $query)
                            .font(.system(size: 14))
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal, 15)
                    .frame(height: 53)
                    .background(.white, in: RoundedRectangle(cornerRadius: 17))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 9) {
                            ForEach(filters, id: \.self) { item in
                                Button { filter = item } label: {
                                    Text(item)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(filter == item ? .white : UIStyle.muted)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 11)
                                        .background(filter == item ? UIStyle.blue : .white, in: Capsule())
                                }
                            }
                        }
                    }
                    SectionTitle(title: "Khám phá mẫu", subtitle: "Chạm vào từng mẫu để xem chi tiết")
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 13), GridItem(.flexible(), spacing: 13)], spacing: 13) {
                        ForEach(filtered) { item in
                            Button { selected = item } label: {
                                VStack(alignment: .leading, spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 17).fill(item.tint.opacity(0.10))
                                        Circle().fill(item.tint.opacity(0.10)).frame(width: 90).offset(x: 58, y: -35)
                                        Image(systemName: item.icon)
                                            .font(.system(size: 46, weight: .light))
                                            .foregroundStyle(item.tint)
                                    }
                                    .frame(height: 113)
                                    HStack(alignment: .center, spacing: 4) {
                                        Text(item.title).font(.system(size: 15, weight: .bold)).foregroundStyle(UIStyle.ink).lineLimit(1)
                                        Spacer(minLength: 0)
                                        Image(systemName: store.favorites.contains(item.id) ? "heart.fill" : "heart")
                                            .font(.system(size: 13))
                                            .foregroundStyle(UIStyle.pink)
                                    }
                                    Text(item.subtitle).font(.system(size: 11)).foregroundStyle(UIStyle.muted).lineLimit(1)
                                    AccentPill(text: "Xem thiết kế", icon: "arrow.up.right", color: item.tint)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .softCard(padding: 13)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    if filtered.isEmpty {
                        ContentUnavailableView("Không tìm thấy mẫu", systemImage: "square.grid.2x2", description: Text("Thử từ khóa hoặc bộ lọc khác."))
                    }
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            RoundIcon(icon: "wand.and.stars", tint: UIStyle.violet)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Thiết kế tinh giản").font(.system(size: 16, weight: .bold)).foregroundStyle(UIStyle.ink)
                                Text("Thành phần giao diện chuẩn SwiftUI")
                                    .font(.system(size: 12)).foregroundStyle(UIStyle.muted)
                            }
                        }
                        HStack(spacing: 10) {
                            AccentPill(text: "SwiftUI", icon: "swift", color: UIStyle.orange)
                            AccentPill(text: "iOS 17+", icon: "iphone", color: UIStyle.blue)
                        }
                    }
                    .softCard()
                }
                .padding(.horizontal, 20)
                .padding(.top, 23)
                .padding(.bottom, 35)
            }
            .background(BackgroundCanvas())
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $selected) { item in
                ShowcaseDetail(item: item)
                    .environmentObject(store)
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

struct ShowcaseDetail: View {
    @EnvironmentObject private var store: DemoStore
    @Environment(\.dismiss) private var dismiss
    let item: ShowcaseItem
    @State private var progress = 0.63
    @State private var switchValue = true
    @State private var selectedSegment = 0
    @State private var counter = 12

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 27).fill(item.tint.opacity(0.12))
                        Circle().stroke(item.tint.opacity(0.10), lineWidth: 38).frame(width: 220).offset(x: 140, y: -60)
                        Image(systemName: item.icon).font(.system(size: 73, weight: .ultraLight)).foregroundStyle(item.tint)
                    }
                    .frame(height: 184)
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.title).font(.system(size: 27, weight: .bold, design: .rounded)).foregroundStyle(UIStyle.ink)
                            Text(item.subtitle).font(.system(size: 13)).foregroundStyle(UIStyle.muted)
                        }
                        Spacer()
                        Button { store.toggleFavorite(item.id) } label: {
                            RoundIcon(icon: store.favorites.contains(item.id) ? "heart.fill" : "heart", tint: UIStyle.pink)
                        }
                    }
                    SectionTitle(title: "Interactive UI Kit", subtitle: "Thử các thành phần chức năng")
                    VStack(alignment: .leading, spacing: 19) {
                        Text("Chọn chế độ").font(.system(size: 13, weight: .semibold))
                        Picker("Chế độ", selection: $selectedSegment) {
                            Text("Cơ bản").tag(0)
                            Text("Nâng cao").tag(1)
                            Text("Pro").tag(2)
                        }
                        .pickerStyle(.segmented)
                        Toggle("Bật thông báo giao diện", isOn: $switchValue).tint(item.tint)
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Mức độ tương tác")
                                Spacer()
                                Text("\(Int(progress * 100))%").foregroundStyle(item.tint)
                            }.font(.system(size: 13, weight: .semibold))
                            Slider(value: $progress, in: 0...1).tint(item.tint)
                        }
                        HStack {
                            Text("Bộ đếm trực tiếp").font(.system(size: 13, weight: .semibold))
                            Spacer()
                            Button { counter = max(0, counter - 1) } label: { Image(systemName: "minus.circle.fill") }
                            Text("\(counter)").font(.system(size: 17, weight: .bold, design: .rounded)).frame(width: 30)
                            Button { counter += 1 } label: { Image(systemName: "plus.circle.fill") }
                        }
                        .tint(item.tint)
                    }
                    .softCard()
                    Text("Đây là bộ thành phần demo, không phải dịch vụ trực tuyến. Các tương tác ở trên có thể thử trực tiếp.")
                        .font(.system(size: 12)).foregroundStyle(UIStyle.muted)
                }
                .padding(20)
            }
            .background(BackgroundCanvas())
            .navigationTitle("Chi tiết giao diện")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Đóng") { dismiss() } } }
        }
    }
}
