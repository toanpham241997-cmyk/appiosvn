import Foundation

struct ChatMessage: Codable, Identifiable {
    var id = UUID()
    var body: String
    var sentByMe: Bool
    var timestamp: Date = Date()
}

struct Conversation: Codable, Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let icon: String
    var messages: [ChatMessage]
}

@MainActor final class MessageStore: ObservableObject {
    @Published var conversations: [Conversation] = [] {
        didSet { persist() }
    }
    init() {
        if let data = UserDefaults.standard.data(forKey: "aujunpeak_chat_v2"),
           let stored = try? JSONDecoder().decode([Conversation].self, from: data) {
            conversations = stored
        } else {
            conversations = [
                Conversation(id: "welcome", name: "Aujunpeak Assistant", subtitle: "Thông báo trên thiết bị", icon: "sparkles", messages: [
                    ChatMessage(body: "Chào mừng đến Aujunpeak Game Space! Đây là hộp thư mẫu lưu trên iPhone, chưa có máy chủ chat.", sentByMe: false)
                ]),
                Conversation(id: "tips", name: "Game Tips", subtitle: "Mẹo chơi & thiết lập", icon: "gamecontroller.fill", messages: [
                    ChatMessage(body: "Mẹo: giữ kết nối ổn định và tránh quá nhiệt để chơi game thoải mái hơn.", sentByMe: false)
                ]),
                Conversation(id: "system", name: "System Center", subtitle: "Ghi chú hệ thống", icon: "cpu", messages: [
                    ChatMessage(body: "Thông tin CPU, RAM và IDFV được đọc cục bộ trên iOS.", sentByMe: false)
                ])
            ]
        }
    }
    func send(_ text: String, to id: String) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty, let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[index].messages.append(ChatMessage(body: clean, sentByMe: true))
    }
    private func persist() {
        if let data = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(data, forKey: "aujunpeak_chat_v2")
        }
    }
}
