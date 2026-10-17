import SwiftUI

struct GamesView: View {
    @StateObject private var catalog = GameCatalog()
    @State private var searchText = ""
    @State private var selection = "Đề xuất"
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var toast: ToastCenter
    @EnvironmentObject private var prefs: BoostPreferences

    private let tags = ["Đề xuất", "Bắn súng", "MOBA", "Sinh tồn", "Phiêu lưu", "Sandbox"]
    private let queries = ["Bắn súng": "shooting games", "MOBA": "moba",
                           "Sinh tồn": "survival", "Phiêu lưu": "adventure game", "Sandbox": "sandbox game"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 21) {
                BrandHeader(eyebrow: "APP STORE GAMES")
                PageTitle(title: "Game Hub", subtitle: "Khám phá game thật từ App Store Việt Nam")
                HStack(spacing: 9) {
                    Image(systemName: "magnifyingglass").foregroundStyle(Palette.muted)
                    TextField("Tìm Free Fire, PUBG, Roblox...", text: $searchText)
                        .font(.system(size: 13))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.search)
                        .onSubmit { Task { await catalog.search(searchText) } }
                    if !searchText.isEmpty {
                        Button { searchText = ""; Task { await catalog.loadFeatured() } } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(Palette.muted)
                        }
                    }
                    Button {
                        Task { await catalog.search(searchText) }
                    } label: {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(Palette.gradient, in: RoundedRectangle(cornerRadius: 11))
                    }.accessibilityLabel("Tìm game")
                }
                .padding(12).background(.white, in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Palette.line))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            Button {
                                selection = tag
                                searchText = ""
                                Task {
                                    if tag == "Đề xuất" { await catalog.loadFeatured() }
                                    else { await catalog.search(queries[tag] ?? tag) }
                                }
                            } label: {
                                Text(tag).font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(selection == tag ? Color.white : Palette.muted)
                                    .padding(.horizontal, 15).padding(.vertical, 11)
                                    .background(selection == tag ? Palette.purple : Color.white, in: Capsule())
                            }.buttonStyle(.plain)
                        }
                    }
                }
                if prefs.preset != .focus { featuredBanner }
                HStack {
                    SectionHeading(title: selection == "Đề xuất" ? "Game nổi bật" : "Danh mục \(selection)", trailing: "Nguồn: App Store")
                    if catalog.loading { ProgressView().scaleEffect(0.75) }
                }
                VStack(spacing: 10) {
                    ForEach(catalog.games) { game in
                        gameRow(game)
                    }
                    if catalog.games.isEmpty && !catalog.loading {
                        VStack(spacing: 10) {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 28)).foregroundStyle(Palette.purple)
                            Text(catalog.message ?? "Chưa có kết quả")
                                .font(.system(size: 12)).foregroundStyle(Palette.muted)
                                .multilineTextAlignment(.center)
                            Button("Thử lại") { Task { await catalog.loadFeatured() } }
                                .font(.system(size: 12, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24).luxeCard()
                    }
                }
                systemHub
                Spacer(minLength: 12)
            }.padding(.horizontal, 18).padding(.top, 15)
        }
        .appPage()
        .task { await catalog.loadFeatured() }
        .refreshable {
            if searchText.isEmpty { await catalog.loadFeatured() }
            else { await catalog.search(searchText) }
        }
    }

    private var featuredBanner: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 25)
                .fill(LinearGradient(colors: [Color(hex: 0x151F49), Color(hex: 0x46408C)], startPoint: .topLeading, endPoint: .bottomTrailing))
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 112, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.09))
                .rotationEffect(.degrees(-18)).offset(x: 210, y: 8)
            VStack(alignment: .leading, spacing: 10) {
                SmallTag(title: "DISCOVER · PLAY", color: Palette.cyan)
                Text("Your next favorite game")
                    .font(.system(size: 21, weight: .bold, design: .rounded)).foregroundStyle(.white)
                Text("Danh sách được truy xuất trực tiếp từ danh mục Apple.")
                    .font(.system(size: 11)).foregroundStyle(.white.opacity(0.75))
            }.padding(20)
        }.frame(height: 150).clipped()
    }

    private func gameRow(_ game: StoreGame) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: game.iconURL) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                case .failure: Image(systemName: "gamecontroller.fill").resizable().scaledToFit()
                    .padding(16).foregroundStyle(Palette.purple)
                case .empty: ProgressView()
                @unknown default: Color.clear
                }
            }
            .frame(width: prefs.compactCards ? 51 : 63, height: prefs.compactCards ? 51 : 63)
            .background(Palette.canvas)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            VStack(alignment: .leading, spacing: 5) {
                Text(game.trackName).font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Palette.text).lineLimit(2)
                Text(game.artistName).font(.system(size: 10)).foregroundStyle(Palette.muted).lineLimit(1)
                HStack(spacing: 5) {
                    Image(systemName: "star.fill").foregroundStyle(Palette.orange)
                    Text(game.averageUserRating.map { String(format: "%.1f", $0) } ?? "App Store")
                    if let genre = game.primaryGenreName {
                        Text("· \(genre)").lineLimit(1)
                    }
                }.font(.system(size: 10, weight: .medium)).foregroundStyle(Palette.muted)
            }
            Spacer(minLength: 0)
            Button {
                if let url = game.storeURL { openURL(url) }
                else { toast.show("Không tìm thấy liên kết App Store.", type: .warning) }
            } label: {
                Text("App Store")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Palette.purple)
                    .padding(.horizontal, 10).padding(.vertical, 9)
                    .background(Palette.lilac, in: Capsule())
            }
        }.luxeCard(padding: 12)
    }

    private var systemHub: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeading(title: "Game system hub", trailing: "IOS STATUS")
            HStack(spacing: 11) {
                IconTile(symbol: "shield.lefthalf.filled", color: Palette.green)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Danh mục chính thức").font(.system(size: 13, weight: .semibold)).foregroundStyle(Palette.text)
                    Text("Tên, icon và liên kết lấy từ API App Store")
                        .font(.system(size: 11)).foregroundStyle(Palette.muted)
                }
                Spacer()
                Image(systemName: "checkmark.seal.fill").foregroundStyle(Palette.green)
            }
            Divider().overlay(Palette.line)
            HStack(spacing: 11) {
                IconTile(symbol: "bolt.heart", color: Palette.blue)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Preset giao diện: \(prefs.preset.rawValue)")
                        .font(.system(size: 13, weight: .semibold)).foregroundStyle(Palette.text)
                    Text("Không sửa dữ liệu hoặc tốc độ game bên ngoài")
                        .font(.system(size: 11)).foregroundStyle(Palette.muted)
                }
                Spacer()
            }
        }.luxeCard()
    }
}
