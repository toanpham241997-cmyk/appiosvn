import SwiftUI

struct MessagesView: View {
    @EnvironmentObject private var store: MessageStore

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    BrandHeader()
                    VStack(spacing: 12) {
                        ForEach(store.conversations) { item in
                            NavigationLink(value: item.id) {
                                HStack(spacing: 12) {
                                    IconTile(symbol: item.icon, color: item.id == "admin" ? Palette.purple : Palette.blue, size: 48)
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(item.name)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Palette.text)
                                        Text(item.subtitle)
                                            .font(.system(size: 11))
                                            .foregroundStyle(Palette.muted)
                                        Text(item.messages.last?.body ?? "")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Palette.text.opacity(0.75))
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(Palette.muted)
                                }
                                .padding(14)
                                .background(.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Palette.line))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 15)
            }
            .appPage()
            .navigationDestination(for: String.self) { id in
                MessageDetailView(conversationID: id)
            }
        }
    }
}

private struct MessageDetailView: View {
    let conversationID: String
    @EnvironmentObject private var store: MessageStore
    @EnvironmentObject private var toast: ToastCenter
    @State private var draft = ""

    private var conversation: Conversation? {
        store.conversations.first(where: { $0.id == conversationID })
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { reader in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(conversation?.messages ?? []) { message in
                            HStack {
                                if message.sentByMe { Spacer(minLength: 44) }
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(message.body)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(message.sentByMe ? .white : Palette.text)
                                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                                        .font(.system(size: 9))
                                        .foregroundStyle(message.sentByMe ? .white.opacity(0.75) : Palette.muted)
                                }
                                .padding(13)
                                .background(message.sentByMe ? Palette.purple : .white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                if !message.sentByMe { Spacer(minLength: 44) }
                            }
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: conversation?.messages.count) { _, _ in
                    if let last = conversation?.messages.last?.id {
                        withAnimation { reader.scrollTo(last, anchor: .bottom) }
                    }
                }
            }
            HStack(spacing: 10) {
                TextField("Nhập tin nhắn...", text: $draft, axis: .vertical)
                    .font(.system(size: 13))
                    .lineLimit(1...3)
                    .padding(13)
                    .background(Palette.canvas, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                Button {
                    let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else {
                        toast.show("Hãy nhập nội dung trước khi gửi.", type: .warning)
                        return
                    }
                    store.send(text, to: conversationID)
                    draft = ""
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Palette.gradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(.white)
        }
        .background(Palette.canvas.ignoresSafeArea())
        .navigationTitle(conversation?.name ?? "Tin nhắn")
        .navigationBarTitleDisplayMode(.inline)
    }
}
