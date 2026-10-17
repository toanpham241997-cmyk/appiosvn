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

    private let storeKey = "aujunpeak_chat_v3"

    init() {
        if let data = UserDefaults.standard.data(forKey: storeKey),
           let stored = try? JSONDecoder().decode([Conversation].self, from: data) {
            conversations = stored
        } else {
            conversations = [
                Conversation(id: "community", name: "Chat Cộng đồng", subtitle: "Người dùng đang hoạt động", icon: "person.3.fill", messages: [
                    ChatMessage(body: "Chào mừng đến khu cộng đồng Aujunpeak. Đây là bản chat demo lưu trên thiết bị.", sentByMe: false),
                    ChatMessage(body: "Bạn có thể gửi tin nhắn thử để xem giao diện trò chuyện.", sentByMe: false)
                ]),
                Conversation(id: "admin", name: "Chat với Admin", subtitle: "Hỗ trợ & phản hồi", icon: "person.crop.circle.badge.checkmark", messages: [
                    ChatMessage(body: "Xin chào! Đây là hộp thư Admin demo. Chúng tôi đã nhận tín hiệu thiết bị của bạn trên giao diện preview.", sentByMe: false)
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
            UserDefaults.standard.set(data, forKey: storeKey)
        }
    }
}
