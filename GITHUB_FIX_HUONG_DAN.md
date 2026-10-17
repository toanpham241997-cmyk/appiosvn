# SỬA LỖI BUILD AUJUNPEAK TRÊN GITHUB (V2.1)

## Phát hiện từ log của bạn

- `cannot find UIStyle / RoundIcon / SectionTitle` là do các màn hình **v1** vẫn nằm trong GitHub, rồi bị project.yml cũ tự động gom vào target v2.
- `invalid redeclaration of ChatDetailView` do `InboxView.swift` (v1) và `MessagesView.swift` (v2) cùng khai báo tên đó.
- `LoginView.swift:124` báo sai overload `background`: đã đổi thành `Color.white.ignoresSafeArea()`.

## Làm ngay (chỉ cần upload 3 file từ bản FIX vào GitHub)

1. Ở gốc repo thay **project.yml** (quan trọng nhất).
2. Thay **App/Screens/LoginView.swift**.
3. Thay **App/Screens/MessagesView.swift**.
4. Vào Actions, chọn Build iOS IPA (unsigned), bấm Re-run all jobs hoặc Run workflow trên commit mới.

Các file Swift cũ không còn được biên dịch vì `project.yml` v2.1 đã xác định chính xác từng file trong target. Có thể xóa chúng cho sạch repository, nhưng không bắt buộc.

Nếu upload cả ZIP: giải nén trước, chọn các file **bên trong** thư mục source rồi upload vào **root repository**, không tải nguyên file .zip lên và không tạo thư mục bọc ngoài.

Lưu ý: đây là bản sửa theo log Xcode 16.4, chưa được chạy xcodebuild trong môi trường hiện tại.
