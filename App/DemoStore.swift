import Foundation
import SwiftUI

struct DemoTask: Codable, Identifiable {
    var id = UUID()
    var title: String
    var category: String
    var done: Bool = false
    var createdAt: Date = .now
}

struct DemoMessage: Codable, Identifiable {
    var id = UUID()
    var text: String
    var mine: Bool
    var date: Date = .now
}

struct DemoChat: Codable, Identifiable {
    var id: String
    var name: String
    var role: String
    var symbol: String
    var messages: [DemoMessage]
}

final class DemoStore: ObservableObject {
    @Published var tasks: [DemoTask] { didSet { save() } }
    @Published var chats: [DemoChat] { didSet { save() } }
    @Published var favorites: Set<String> { didSet { save() } }
    @Published var userName: String { didSet { UserDefaults.standard.set(userName, forKey: "name") } }
    @Published var announcementsRead = false
    @Published var pushEnabled = true

    init() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let decoded = try? JSONDecoder().decode([DemoTask].self, from: data) {
            tasks = decoded
        } else {
            tasks = [
                DemoTask(title: "Hoàn thiện giao diện đăng nhập", category: "Thiết kế", done: true),
                DemoTask(title: "Xem lại bộ thành phần UI", category: "Thiết kế"),
                DemoTask(title: "Kiểm thử luồng điều hướng", category: "Phát triển"),
                DemoTask(title: "Chuẩn bị bản build iOS", category: "Triển khai")
            ]
        }
        if let data = UserDefaults.standard.data(forKey: "chats"),
           let decoded = try? JSONDecoder().decode([DemoChat].self, from: data) {
            chats = decoded
        } else {
            chats = [
                DemoChat(id: "team", name: "Đội ngũ thiết kế", role: "Nhóm dự án", symbol: "person.2.fill", messages: [
                    DemoMessage(text: "Bộ giao diện mới trông rất ổn! ✨", mine: false),
                    DemoMessage(text: "Mình sẽ xem lại trong hôm nay.", mine: true)
                ]),
                DemoChat(id: "support", name: "Hỗ trợ Aujunpeak", role: "Trợ lý demo", symbol: "bubble.left.and.bubble.right.fill", messages: [
                    DemoMessage(text: "Chào bạn! Đây là cuộc hội thoại mẫu, chưa kết nối máy chủ.", mine: false)
                ]),
                DemoChat(id: "product", name: "Product Team", role: "Thành viên", symbol: "square.stack.3d.up.fill", messages: [
                    DemoMessage(text: "Trang tổng quan đã sẵn sàng để khám phá.", mine: false)
                ])
            ]
        }
        favorites = Set(UserDefaults.standard.stringArray(forKey: "favorites") ?? ["analytics", "payments"])
        userName = UserDefaults.standard.string(forKey: "name") ?? "Aujunpeak Member"
    }

    var completedCount: Int { tasks.filter(\.done).count }
    var completionPercent: Int { tasks.isEmpty ? 0 : Int(Double(completedCount) / Double(tasks.count) * 100) }

    func addTask(_ title: String, category: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        tasks.insert(DemoTask(title: trimmed, category: category), at: 0)
    }

    func toggleTask(_ id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].done.toggle()
    }

    func deleteTasks(at offsets: IndexSet, from filtered: [DemoTask]) {
        let ids = Set(offsets.map { filtered[$0].id })
        tasks.removeAll { ids.contains($0.id) }
    }

    func toggleFavorite(_ id: String) {
        if favorites.contains(id) { favorites.remove(id) } else { favorites.insert(id) }
    }

    func send(_ text: String, to id: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let i = chats.firstIndex(where: { $0.id == id }) else { return }
        chats[i].messages.append(DemoMessage(text: trimmed, mine: true))
    }

    private func save() {
        if let data = try? JSONEncoder().encode(tasks) { UserDefaults.standard.set(data, forKey: "tasks") }
        if let data = try? JSONEncoder().encode(chats) { UserDefaults.standard.set(data, forKey: "chats") }
        UserDefaults.standard.set(Array(favorites), forKey: "favorites")
    }
}
