import SwiftUI

struct GamesView: View {
    @StateObject private var catalog = GameCatalog()
    @State private var searchText = ""
    @State private var selectedGame: StoreGame?
    @State private var showBoostOverlay = false
    @State private var boostingGameName = ""
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var toast: ToastCenter

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                BrandHeader()
                searchBar
                if catalog.loading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                LazyVStack(spacing: 12) {
                    ForEach(catalog.games) { game in
                        GameWingCard(game: game) {
                            startBoost(for: game)
                        }
                    }
                }
                if catalog.games.isEmpty && !catalog.loading {
                    Text(catalog.message ?? "Không có dữ liệu game")
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.muted)
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .luxeCard()
                }
                databaseStrip
            }
            .padding(.horizontal, 18)
            .padding(.top, 15)
        }
        .appPage()
        .task { await catalog.loadFeatured() }
        .refreshable {
            if searchText.isEmpty { await catalog.loadFeatured() }
            else { await catalog.search(searchText) }
        }
        .overlay {
            if showBoostOverlay {
                BoostLaunchOverlay(gameName: boostingGameName)
                    .transition(.opacity)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(Palette.muted)
            TextField("Tìm Free Fire, PUBG, Roblox...", text: $searchText)
                .font(.system(size: 13))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit { Task { await catalog.search(searchText) } }
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    Task { await catalog.loadFeatured() }
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(Palette.muted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Palette.line))
    }

    private var databaseStrip: some View {
        HStack(spacing: 10) {
            databaseChip("Game DB", "Live")
            databaseChip("Route", "VN")
            databaseChip("Boost", "Ready")
        }
    }

    private func databaseChip(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.system(size: 10)).foregroundStyle(Palette.muted)
            Text(value).font(.system(size: 12, weight: .bold)).foregroundStyle(Palette.text)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Palette.line))
    }

    private func startBoost(for game: StoreGame) {
        selectedGame = game
        boostingGameName = game.trackName
        withAnimation(.easeInOut(duration: 0.25)) {
            showBoostOverlay = true
        }
        Task {
            try? await Task.sleep(for: .seconds(1.8))
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showBoostOverlay = false
                }
                launchGame(game)
            }
        }
    }

    private func launchGame(_ game: StoreGame) {
        let lower = game.trackName.lowercased()
        let preferredScheme: String?
        if lower.contains("roblox") { preferredScheme = "roblox://" }
        else if lower.contains("genshin") { preferredScheme = "yuanshen://" }
        else { preferredScheme = nil }

        if let preferredScheme, let url = URL(string: preferredScheme) {
            openURL(url)
            toast.show("Đã gửi yêu cầu mở \(game.trackName).", type: .success)
            return
        }
        if let url = game.storeURL {
            openURL(url)
            toast.show("Đã mở liên kết của \(game.trackName).", type: .success)
        } else {
            toast.show("Chưa có liên kết để mở game này.", type: .warning)
        }
    }
}

private struct GameWingCard: View {
    let game: StoreGame
    let boostAction: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white)
            WingFlare()
            HStack(spacing: 12) {
                AsyncImage(url: game.iconURL) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.canvas)
                            .overlay(Image(systemName: "gamecontroller.fill").foregroundStyle(Palette.purple))
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(game.trackName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Palette.text)
                        .lineLimit(2)
                    Text(game.artistName)
                        .font(.system(size: 11))
                        .foregroundStyle(Palette.muted)
                        .lineLimit(1)
                    HStack(spacing: 8) {
                        SmallTag(title: game.primaryGenreName ?? "Game", color: Palette.blue)
                        SmallTag(title: ratingText, color: Palette.orange)
                    }
                }
                Spacer()
                Button(action: boostAction) {
                    VStack(spacing: 7) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text("Boost")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(width: 70, height: 70)
                    .background(Palette.gradient, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(14)
        }
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Palette.line))
        .shadow(color: Palette.text.opacity(0.04), radius: 14, y: 8)
    }

    private var ratingText: String {
        if let rating = game.averageUserRating {
            return String(format: "%.1f ★", rating)
        }
        return "New"
    }
}

private struct BoostLaunchOverlay: View {
    let gameName: String
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 16) {
                ZStack {
                    Circle().fill(Palette.lilac).frame(width: 98, height: 98)
                    Circle().trim(from: 0, to: animate ? 0.92 : 0.1)
                        .stroke(Palette.gradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 92, height: 92)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Palette.purple)
                }
                Text("Boosting \(gameName)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.text)
                VStack(alignment: .leading, spacing: 8) {
                    boostLine("memory remap")
                    boostLine("touch sync")
                    boostLine("route optimizer")
                }
            }
            .padding(24)
            .frame(maxWidth: 290)
            .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Palette.line))
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.4)) { animate = true }
        }
    }

    private func boostLine(_ title: String) -> some View {
        HStack(spacing: 10) {
            Circle().fill(Palette.green).frame(width: 8, height: 8)
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(Palette.text)
            Spacer()
        }
    }
}
