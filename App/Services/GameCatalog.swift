import Foundation

struct StoreGame: Decodable, Identifiable, Hashable {
    let trackId: Int
    let trackName: String
    let artistName: String
    let artworkUrl100: String?
    let trackViewUrl: String
    let primaryGenreName: String?
    let averageUserRating: Double?
    let version: String?
    var id: Int { trackId }
    var iconURL: URL? { artworkUrl100.flatMap(URL.init(string:)) }
    var storeURL: URL? { URL(string: trackViewUrl) }
}

private struct StoreResult: Decodable { let results: [StoreGame] }

@MainActor final class GameCatalog: ObservableObject {
    @Published var games: [StoreGame] = []
    @Published var loading = false
    @Published var message: String?
    private var revision = 0

    func loadFeatured() async {
        revision += 1
        let requestRevision = revision
        loading = true
        message = nil
        let searchTerms = ["Garena Free Fire", "PUBG MOBILE", "Roblox", "Liên Quân Mobile", "Call of Duty Mobile", "Genshin Impact"]
        let results = await withTaskGroup(of: (Int, StoreGame?).self) { group in
            for (index, term) in searchTerms.enumerated() {
                group.addTask {
                    let data = try? await Self.request(term: term, limit: 12)
                    let keyword = ["free fire", "pubg", "roblox", "liên quân", "call of duty", "genshin"][index]
                    let matching = data?.first(where: { $0.trackName.localizedLowercase.contains(keyword) })
                    return (index, matching)
                }
            }
            var collected: [(Int, StoreGame)] = []
            for await (index, game) in group {
                if let game { collected.append((index, game)) }
            }
            return collected.sorted { $0.0 < $1.0 }.map(\.1)
        }
        guard requestRevision == revision else { return }
        games = results
        loading = false
        if games.isEmpty { message = "Chưa tải được danh sách game từ App Store. Hãy thử làm mới." }
    }

    func search(_ query: String) async {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if term.isEmpty { await loadFeatured(); return }
        revision += 1
        let requestRevision = revision
        loading = true
        message = nil
        do {
            let result = try await Self.request(term: term, limit: 30)
            guard revision == requestRevision else { return }
            games = result
            if result.isEmpty { message = "Không tìm thấy game phù hợp trên App Store Việt Nam." }
        } catch {
            guard revision == requestRevision else { return }
            games = []
            message = "Không tải được App Store: \(error.localizedDescription)"
        }
        if revision == requestRevision { loading = false }
    }

    nonisolated private static func request(term: String, limit: Int) async throws -> [StoreGame] {
        var parts = URLComponents(string: "https://itunes.apple.com/search")!
        parts.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "country", value: "vn"),
            URLQueryItem(name: "media", value: "software"),
            URLQueryItem(name: "entity", value: "software"),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        var req = URLRequest(url: parts.url!)
        req.timeoutInterval = 16
        let (data, response) = try await URLSession.shared.data(for: req)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(StoreResult.self, from: data).results
    }
}
