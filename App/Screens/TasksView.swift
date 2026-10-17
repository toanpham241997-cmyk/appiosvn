import SwiftUI

struct TasksView: View {
    @EnvironmentObject private var store: DemoStore
    @State private var search = ""
    @State private var currentFilter = "Tất cả"
    @State private var showNewTask = false
    private let filters = ["Tất cả", "Cần làm", "Hoàn thành"]

    private var filtered: [DemoTask] {
        store.tasks.filter { task in
            let matchStatus = currentFilter == "Tất cả" || (currentFilter == "Cần làm" && !task.done) || (currentFilter == "Hoàn thành" && task.done)
            return matchStatus && (search.isEmpty || task.title.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("My Tasks").font(.system(size: 31, weight: .bold, design: .rounded)).foregroundStyle(UIStyle.ink)
                            Text("Tập trung vào những điều quan trọng")
                                .font(.system(size: 13)).foregroundStyle(UIStyle.muted)
                        }
                        Spacer()
                        Button { showNewTask = true } label: { RoundIcon(icon: "plus", tint: .white, background: UIStyle.blue, size: 46) }
                            .accessibilityLabel("Thêm công việc")
                    }
                    VStack(alignment: .leading, spacing: 13) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("TIẾN ĐỘ CỦA BẠN").font(.system(size: 10, weight: .bold)).tracking(1.6).foregroundStyle(.white.opacity(0.7))
                                Text("\(store.completionPercent)% hoàn thành").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundStyle(.white)
                                Text("\(store.completedCount) trong \(store.tasks.count) công việc đã xong")
                                    .font(.system(size: 12)).foregroundStyle(.white.opacity(0.78))
                            }
                            Spacer()
                            ZStack {
                                Circle().stroke(.white.opacity(0.25), lineWidth: 8)
                                Circle()
                                    .trim(from: 0, to: Double(store.completionPercent) / 100)
                                    .stroke(.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                Image(systemName: "checkmark").font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                            }.frame(width: 78, height: 78)
                        }
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(UIStyle.gradient, in: RoundedRectangle(cornerRadius: 25))
                    HStack(spacing: 11) {
                        Image(systemName: "magnifyingglass").foregroundStyle(UIStyle.muted)
                        TextField("Tìm công việc...", text: $search).font(.system(size: 14))
                    }
                    .padding(.horizontal, 16).frame(height: 52)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16))
                    HStack(spacing: 9) {
                        ForEach(filters, id: \.self) { filter in
                            Button { currentFilter = filter } label: {
                                Text(filter).font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(currentFilter == filter ? .white : UIStyle.muted)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(currentFilter == filter ? UIStyle.blue : .white, in: Capsule())
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    SectionTitle(title: "Danh sách công việc", subtitle: "Tích để hoàn thành, vuốt trái để xóa")
                    LazyVStack(spacing: 11) {
                        ForEach(filtered) { task in
                            Button { withAnimation(.snappy) { store.toggleTask(task.id) } } label: {
                                HStack(spacing: 13) {
                                    Image(systemName: task.done ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 24)).foregroundStyle(task.done ? UIStyle.green : UIStyle.muted)
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(task.title).font(.system(size: 14, weight: .semibold))
                                            .strikethrough(task.done)
                                            .foregroundStyle(task.done ? UIStyle.muted : UIStyle.ink)
                                            .multilineTextAlignment(.leading)
                                        AccentPill(text: task.category, icon: task.category == "Thiết kế" ? "paintbrush" : "hammer", color: task.category == "Thiết kế" ? UIStyle.violet : UIStyle.blue)
                                    }
                                    Spacer()
                                    Menu {
                                        Button(role: .destructive) { store.tasks.removeAll { $0.id == task.id } } label: { Label("Xóa", systemImage: "trash") }
                                    } label: {
                                        Image(systemName: "ellipsis").font(.system(size: 17)).foregroundStyle(UIStyle.muted).frame(width: 28, height: 35)
                                    }
                                }
                                .softCard()
                            }
                            .buttonStyle(.plain)
                        }
                        if filtered.isEmpty {
                            ContentUnavailableView("Chưa có công việc", systemImage: "checkmark.circle", description: Text("Thêm công việc mới hoặc đổi bộ lọc."))
                        }
                    }
                    FilledAction(title: "Tạo công việc mới", icon: "plus") { showNewTask = true }
                }
                .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 35)
            }
            .background(BackgroundCanvas())
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showNewTask) { NewTaskView() }
        }
    }
}

struct NewTaskView: View {
    @EnvironmentObject private var store: DemoStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var category = "Thiết kế"

    var body: some View {
        NavigationStack {
            Form {
                Section("Thông tin") {
                    TextField("Tên công việc", text: $title)
                    Picker("Danh mục", selection: $category) {
                        Text("Thiết kế").tag("Thiết kế")
                        Text("Phát triển").tag("Phát triển")
                        Text("Triển khai").tag("Triển khai")
                        Text("Khác").tag("Khác")
                    }
                }
                Section {
                    Button {
                        store.addTask(title, category: category)
                        dismiss()
                    } label: {
                        Text("Lưu công việc").frame(maxWidth: .infinity).fontWeight(.semibold)
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Công việc mới")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Đóng") { dismiss() } } }
        }
        .presentationDetents([.medium, .large])
    }
}
