import SwiftUI

struct InboxView: View {
    @EnvironmentObject private var store: DemoStore
    @State private var query = ""
    private var chats: [DemoChat] { store.chats.filter { query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) } }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Messages").font(.system(size: 31, weight: .bold, design: .rounded)).foregroundStyle(UIStyle.ink)
                            Text("Kết nối với không gian sáng tạo")
                                .font(.system(size: 13)).foregroundStyle(UIStyle.muted)
                        }
                        Spacer()
                        RoundIcon(icon: "bubble.left.and.bubble.right.fill", tint: UIStyle.blue, background: .white)
                    }
                    HStack(spacing: 11) {
                        Image(systemName: "magnifyingglass").foregroundStyle(UIStyle.muted)
                        TextField("Tìm cuộc hội thoại...", text: $query).font(.system(size: 14))
                    }
                    .padding(.horizontal, 16).frame(height: 53)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16))
                    SectionTitle(title: "Hộp thư của bạn", subtitle: "Hội thoại mô phỏng lưu tại thiết bị")
                    LazyVStack(spacing: 12) {
                        ForEach(chats) { chat in
                            NavigationLink(value: chat.id) {
                                HStack(spacing: 12) {
                                    RoundIcon(icon: chat.symbol, tint: chat.id == "team" ? UIStyle.violet : UIStyle.blue, background: UIStyle.ice, size: 53)
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text(chat.name).font(.system(size: 15, weight: .bold)).foregroundStyle(UIStyle.ink)
                                            Spacer()
                                            Text("Mẫu").font(.system(size: 10)).foregroundStyle(UIStyle.muted)
                                        }
                                        Text(chat.messages.last?.text ?? "Bắt đầu hội thoại")
                                            .font(.system(size: 12)).foregroundStyle(UIStyle.muted).lineLimit(1)
                                        Text(chat.role).font(.system(size: 10, weight: .medium)).foregroundStyle(UIStyle.blue)
                                    }
                                    Image(systemName: "chevron.right").font(.system(size: 11, weight: .semibold)).foregroundStyle(UIStyle.muted)
                                }
                                .softCard()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 34)
            }
            .background(BackgroundCanvas())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: String.self) { id in
                ChatDetailView(chatID: id)
            }
        }
    }
}

struct ChatDetailView: View {
    @EnvironmentObject private var store: DemoStore
    let chatID: String
    @State private var draft = ""
    @FocusState private var editing: Bool

    private var chat: DemoChat? { store.chats.first { $0.id == chatID } }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 13) {
                        Text("HỘI THOẠI DEMO • KHÔNG GỬI TỚI MÁY CHỦ")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(UIStyle.muted)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 17)
                        ForEach(chat?.messages ?? []) { msg in
                            HStack {
                                if msg.mine { Spacer(minLength: 55) }
                                Text(msg.text)
                                    .font(.system(size: 14))
                                    .foregroundStyle(msg.mine ? Color.white : UIStyle.ink)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 12)
                                    .background(msg.mine ? UIStyle.blue : Color.white, in: RoundedRectangle(cornerRadius: 18))
                                if !msg.mine { Spacer(minLength: 55) }
                            }
                            .id(msg.id)
                        }
                    }
                    .padding(16)
                }
                .onChange(of: chat?.messages.count) { _, _ in
                    if let lastID = chat?.messages.last?.id {
                        withAnimation { proxy.scrollTo(lastID, anchor: .bottom) }
                    }
                }
            }
            HStack(spacing: 11) {
                TextField("Viết tin nhắn...", text: $draft, axis: .vertical)
                    .lineLimit(1...3)
                    .focused($editing)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(UIStyle.ice, in: RoundedRectangle(cornerRadius: 16))
                Button {
                    store.send(draft, to: chatID)
                    draft = ""
                } label: {
                    Image(systemName: "arrow.up").font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 43, height: 43)
                        .background(UIStyle.blue, in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16).padding(.vertical, 11)
            .background(Color.white)
        }
        .background(BackgroundCanvas())
        .navigationTitle(chat?.name ?? "Tin nhắn")
        .navigationBarTitleDisplayMode(.inline)
    }
}
