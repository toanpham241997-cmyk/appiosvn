import SwiftUI

struct MessagesView: View {
    @StateObject private var store = MessageStore()
    @State private var search = ""
    @EnvironmentObject private var toast: ToastCenter
    private var visible: [Conversation] {
        search.isEmpty ? store.conversations : store.conversations.filter {
            $0.name.localizedCaseInsensitiveContains(search) || $0.subtitle.localizedCaseInsensitiveContains(search)
        }
    }
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 21) {
                    BrandHeader(eyebrow: "COMMUNICATION SPACE")
                    HStack {
                        PageTitle(title: "Tin nhắn", subtitle: "Hộp thư nội bộ · Lưu trên thiết bị")
                        SmallTag(title: "LOCAL")
                    }
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").foregroundStyle(Palette.muted)
                        TextField("Tìm cuộc hội thoại", text: $search)
                            .font(.system(size: 13))
                    }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Palette.line))
                    featuredCard
                    SectionHeading(title: "Hội thoại", trailing: "\(visible.count) MỤC")
                    VStack(spacing: 10) {
                        ForEach(visible) { chat in
                            NavigationLink(value: chat.id) {
                                HStack(spacing: 12) {
                                    IconTile(symbol: chat.icon,
                                             color: chat.id == "welcome" ? Palette.purple : Palette.blue,
                                             size: 52)
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text(chat.name).font(.system(size: 13, weight: .bold))
                                                .foregroundStyle(Palette.text)
                                            Spacer()
                                            Text(chat.messages.last?.timestamp.formatted(date: .omitted, time: .shortened) ?? "")
                                                .font(.system(size: 9)).foregroundStyle(Palette.muted)
                                        }
                                        Text(chat.messages.last?.body ?? chat.subtitle)
                                            .font(.system(size: 11)).foregroundStyle(Palette.muted)
                                            .lineLimit(1)
                                    }
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10, weight: .bold)).foregroundStyle(Palette.muted)
                                }.luxeCard(padding: 14)
                            }.buttonStyle(.plain)
                        }
                    }
                    HStack(alignment: .top, spacing: 12) {
                        IconTile(symbol: "lock.shield.fill", color: Palette.green)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Riêng tư trên thiết bị").font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Palette.text)
                            Text("Tin nhắn tại đây chỉ được lưu cục bộ, không chuyển đến nhân viên hỗ trợ.")
                                .font(.system(size: 11)).foregroundStyle(Palette.muted)
                        }
                    }.luxeCard()
                }.padding(.horizontal, 18).padding(.top, 15)
            }
            .appPage()
            .navigationDestination(for: String.self) { id in
                GameSpaceChatDetailView(store: store, conversationID: id)
            }
        }
    }
    private var featuredCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(.white.opacity(0.18)).frame(width: 52, height: 52)
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 23)).foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text("Your message lounge")
                    .font(.system(size: 16, weight: .bold, design: .rounded)).foregroundStyle(.white)
                Text("Gọn gàng, dễ theo dõi, lưu riêng tư")
                    .font(.system(size: 10)).foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
        }
        .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.gradient, in: RoundedRectangle(cornerRadius: 23))
    }
}

private struct GameSpaceChatDetailView: View {
    @ObservedObject var store: MessageStore
    let conversationID: String
    @State private var draft = ""
    @EnvironmentObject private var toast: ToastCenter
    private var chat: Conversation? { store.conversations.first(where: { $0.id == conversationID }) }
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { reader in
                ScrollView {
                    LazyVStack(spacing: 13) {
                        Text("Tin nhắn chỉ lưu trong Aujunpeak trên thiết bị này")
                            .font(.system(size: 10)).foregroundStyle(Palette.muted)
                            .padding(.top, 16)
                        ForEach(chat?.messages ?? []) { message in
                            HStack {
                                if message.sentByMe { Spacer(minLength: 44) }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(message.body)
                                        .font(.system(size: 13))
                                        .foregroundStyle(message.sentByMe ? .white : Palette.text)
                                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                                        .font(.system(size: 9))
                                        .foregroundStyle(message.sentByMe ? .white.opacity(0.75) : Palette.muted)
                                }
                                .padding(13)
                                .background(message.sentByMe ? Palette.purple : Color.white,
                                            in: RoundedRectangle(cornerRadius: 18))
                                if !message.sentByMe { Spacer(minLength: 44) }
                            }.id(message.id)
                        }
                    }.padding(.horizontal, 17)
                }
                .onChange(of: chat?.messages.count) { _, _ in
                    if let last = chat?.messages.last?.id {
                        withAnimation { reader.scrollTo(last, anchor: .bottom) }
                    }
                }
            }
            HStack(spacing: 11) {
                TextField("Viết một tin nhắn...", text: $draft, axis: .vertical)
                    .font(.system(size: 13)).lineLimit(1...3)
                    .padding(13)
                    .background(Palette.canvas, in: RoundedRectangle(cornerRadius: 16))
                Button {
                    let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else {
                        toast.show("Hãy nhập nội dung trước khi gửi.", type: .warning)
                        return
                    }
                    store.send(trimmed, to: conversationID)
                    draft = ""
                    toast.show("Đã lưu tin nhắn trên thiết bị.")
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Palette.gradient, in: RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityLabel("Gửi tin nhắn")
            }
            .padding(.horizontal, 15).padding(.vertical, 10)
            .background(.white)
        }
        .background(Palette.canvas.ignoresSafeArea())
        .navigationTitle(chat?.name ?? "Tin nhắn")
        .navigationBarTitleDisplayMode(.inline)
    }
}
