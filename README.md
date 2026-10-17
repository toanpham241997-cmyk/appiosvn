# Aujunpeak VN — iOS SwiftUI App

Một ứng dụng mẫu iOS **giao diện nền trắng, hiện đại**, viết bằng **SwiftUI thuần**. Có sẵn **GitHub Actions** để build IPA tự động, không phụ thuộc CocoaPods hoặc dịch vụ bên ngoài.

## Các giao diện

1. **Login** — nhận diện thương hiệu, banner 3D-style, email/mật khẩu có xác thực định dạng, nút hiện/ẩn mật khẩu, truy cập demo.
2. **Dashboard** — thẻ chỉ số, biểu đồ Swift Charts, thao tác nhanh, thông báo, danh sách công việc.
3. **Explore UI** — thư viện 6 mẫu giao diện, tìm kiếm, lọc danh mục, yêu thích; màn hình chi tiết có segmented control, switch, slider, bộ đếm hoạt động.
4. **Tasks** — tạo, tìm, lọc, đánh dấu hoàn thành và xóa công việc; lưu lại trên thiết bị.
5. **Messages** — 3 cuộc hội thoại minh họa; gửi tin nhắn **nội bộ trên thiết bị**.
6. **Profile** — đổi tên hiển thị, các công tắc tùy chỉnh, giới thiệu, đăng xuất.

> **Giới hạn:** Đây là **UI demo ngoại tuyến**, không có backend, API đăng nhập, xác thực tài khoản thật hoặc gửi tin nhắn qua mạng. Thông tin đăng nhập **không được gửi hoặc lưu**. Dashboard có một số chỉ số minh họa. Các công việc, tin nhắn và yêu thích được lưu bằng `UserDefaults`.

## Môi trường

- iPhone với **iOS 17+**.
- Xcode 16 hoặc mới hơn và SwiftUI; không cần package ngoài.
- Project dùng [XcodeGen](https://github.com/yonaskolb/XcodeGen), sinh `.xcodeproj` từ `project.yml`.
- Để chạy trên iPhone cá nhân, cần cấu hình signing bằng Xcode/Apple ID theo quy định Apple.

## Cách build IPA bằng GitHub (không cần máy Mac riêng)

1. Tạo **repository mới** trên [github.com/new](https://github.com/new), ví dụ `Aujunpeak-iOS`.
2. Giải nén ZIP này rồi **upload toàn bộ nội dung thư mục `Aujunpeak-iOS` vào gốc repository**, **bao gồm thư mục ẩn `.github`**. Có thể dùng `git add .`, commit và push hoặc GitHub **Add file → Upload files**.
3. Trong repository, mở tab **Actions** → chọn **Build iOS IPA (unsigned)** → **Run workflow**. Hoặc push lên nhánh `main`, workflow cũng chạy.
4. Khi có dấu tick xanh, vào **Actions → lần chạy → Artifacts** → tải `AujunpeakVN-unsigned-ipa`.
5. Giải nén artifact ZIP của GitHub sẽ có file **`AujunpeakVN-unsigned.ipa`**.

**Lưu ý quan trọng:** File IPA **unsigned chưa ký mã** được đóng gói để kiểm thử pipeline/chuyển sang bước ký. **Không thể cài trực tiếp trên iPhone thông thường** như một IPA đã ký. GitHub không tự cấp chứng chỉ Apple. Muốn dùng máy thật/TestFlight/App Store, bạn phải ký ứng dụng hợp lệ (phần bên dưới).

## Build IPA đã ký để cài đặt cho thiết bị thử nghiệm

Chuẩn bị từ **Apple Developer Program**: chứng chỉ Apple Distribution có private key (`.p12`), mật khẩu `.p12`, một provisioning profile kiểu **Ad Hoc** khớp App ID và chứa UDID thiết bị thử nghiệm, Team ID và Bundle ID đã đăng ký. Tài khoản Apple Developer đủ quyền là yêu cầu của Apple, không phải phí từ dự án này.

Vào repository **Settings → Secrets and variables → Actions → New repository secret**, khai báo:

| Tên GitHub Secret | Nội dung |
|---|---|
| `IOS_CERTIFICATE_BASE64` | Nội dung `.p12` mã hóa base64 |
| `IOS_CERTIFICATE_PASSWORD` | Mật khẩu file `.p12` |
| `IOS_PROFILE_BASE64` | File provisioning `.mobileprovision` mã hóa base64 |
| `IOS_TEAM_ID` | Apple Developer Team ID |
| `IOS_BUNDLE_ID` | Bundle ID của profile (ví dụ `vn.aujunpeak.studio` nếu đã đăng ký) |
| `IOS_KEYCHAIN_PASSWORD` | Mật khẩu ngẫu nhiên riêng dùng cho keychain CI |

Trên Mac có thể chuyển file thành base64 bằng:

```bash
base64 -i certificate.p12 | pbcopy
base64 -i AdHoc.mobileprovision | pbcopy
```

Sau khi thêm secrets, vào **Actions → Build iOS IPA (signed) → Run workflow**. Kết quả là artifact `AujunpeakVN-signed-ipa` gồm IPA đã được ký nếu mọi điều kiện Apple provisioning đều khớp. Workflow dùng `release-testing` (Ad Hoc), dành cho **các iPhone có UDID được phép trong provisioning profile**. Nó **không tự phân phối App Store hoặc TestFlight**.

**Không bao giờ tải `.p12`, `.mobileprovision`, mật khẩu hoặc private key lên repository công khai.** Chỉ lưu nội dung bảo mật trong GitHub Secrets.

## Cách chạy bằng Xcode nếu có Mac

```bash
brew install xcodegen
xcodegen generate
open AujunpeakUI.xcodeproj
```

Chọn scheme `AujunpeakUI`, chọn Simulator để Run. Muốn cài máy thật, thiết lập Team và Signing trong Xcode.

## Trải nghiệm đăng nhập

- Chọn **Khám phá bản demo ngay** để vào app không cần thông tin.
- Hoặc nhập một địa chỉ email đúng định dạng và mật khẩu **ít nhất 6 ký tự** để thử giao diện xác thực local; không có tài khoản/máy chủ thật.
- Dữ liệu demo lưu trên thiết bị, có thể reset bằng cách xóa ứng dụng.

## Tùy biến

- Đổi tên hiển thị: `project.yml` → `INFOPLIST_KEY_CFBundleDisplayName`.
- Đổi định danh app: `project.yml` → `PRODUCT_BUNDLE_IDENTIFIER`; khi build signed phải khớp `IOS_BUNDLE_ID` và provisioning profile.
- Đổi màu, bo góc, bóng: `App/Theme.swift`.
- Thêm giao diện: `App/Screens/*.swift`.
- Đổi tên thương hiệu trong các Text SwiftUI.
- App icon: `App/Assets.xcassets/AppIcon.appiconset/AppIcon.png`.

## Cấu trúc

```
Aujunpeak-iOS/
├── .github/workflows/
│   ├── build-unsigned.yml
│   └── build-signed.yml
├── App/
│   ├── AujunpeakApp.swift
│   ├── DemoStore.swift
│   ├── Theme.swift
│   ├── Assets.xcassets/AppIcon.appiconset/
│   └── Screens/
│       ├── LoginView.swift
│       ├── HomeView.swift
│       ├── ExploreView.swift
│       ├── TasksView.swift
│       ├── InboxView.swift
│       └── ProfileView.swift
├── project.yml
└── README.md
```

### Về kết quả build

Mã nguồn được chuẩn bị để GitHub build trên macOS. Nếu chưa kết nối repository và chạy workflow, **chưa có IPA biên dịch thực tế**. Đường dẫn IPA và các artifact trong README là kết quả kỳ vọng sau khi GitHub Actions hoàn tất thành công.
