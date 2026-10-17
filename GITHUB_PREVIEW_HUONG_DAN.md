# Aujunpeak VN v2.2 — Cách sử dụng key xem trước

**Key đăng nhập: `havanhuan`**

1. Giải nén `Aujunpeak-VN-v2.2-PREVIEW-FULL-SOURCE.zip`.
2. Upload/ghi đè **nội dung** ZIP vào thư mục gốc repository (không lồng thư mục).
3. Nếu chỉ cập nhật từ v2.1, thay đúng **4 file** sau:
   - `App/Services/KeyAuthentication.swift`
   - `App/Screens/LoginView.swift`
   - `App/Screens/AccountView.swift`
   - `project.yml`
4. Vào GitHub → Actions → Build iOS IPA (unsigned) → Run workflow.
5. Sau khi cài bản IPA đã ký trên thiết bị, nhập `havanhuan` để vào ứng dụng.

Không cần Cloudflare hoặc chạy `npm run generate-key` trong chế độ preview. Đăng nhập offline chỉ phục vụ thử giao diện. App Store Game Hub vẫn cần mạng để lấy danh sách game thực.

Sau này muốn bật API: đổi `AppConfig.authenticationMode` sang `.server`, điền HTTPS `AppConfig.authBaseURL`, cấu hình backend rồi build lại.

**Lưu ý:** Không có chứng nhận build Xcode trong môi trường hiện tại; cần kiểm tra kết quả GitHub Actions.
