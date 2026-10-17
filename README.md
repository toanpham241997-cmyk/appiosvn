# Aujunpeak VN v2.2 — OFFLINE PREVIEW LOGIN

**Bản này KHÔNG CẦN SERVER/API.** Key để vào app thử giao diện là:

```text
havanhuan
```

Đăng nhập: mở app → nhập `havanhuan` (đúng chữ thường, không khoảng trắng ở giữa) → **Đăng nhập**. Key sai sẽ báo lỗi; không có nút bỏ qua màn hình login. Không tạo tài khoản / KV / Cloudflare / npm cho bản này. Mỗi lần mở lại app có thể yêu cầu nhập lại key. Trang Tài khoản hiển thị rõ đây là **key xem trước**, không phải xác thực server. IDFV không được gửi đi khi đăng nhập bằng key offline.

**Cập nhật trên GitHub:** Tải ZIP này, giải nén và chép **nội dung bên trong** lên thư mục gốc repository, ghi đè file trùng tên. Với repository đã có v2.1, chỉ cần cập nhật `App/Services/KeyAuthentication.swift`, `App/Screens/LoginView.swift`, `App/Screens/AccountView.swift`, `project.yml`. Sau đó Actions → `Build iOS IPA (unsigned)` → Run workflow. IPA unsigned là artifact để kiểm tra CI, muốn cài trên iPhone thông thường vẫn cần bản đã ký.

**Sau này chuyển sang server:** Mở `App/Services/KeyAuthentication.swift`, đổi `authenticationMode = .localPreview` thành `.server`, điền `authBaseURL` là địa chỉ HTTPS API đã triển khai, build lại app. Backend mẫu vẫn nằm trong `Backend/cloudflare-worker`, nhưng *chưa được sử dụng* trong bản xem trước.

**Cảnh báo:** `havanhuan` được đặt thẳng trong mã nguồn ứng dụng để phục vụ xem trước nên không thể xem là khóa bảo mật; đừng dùng để thu phí hoặc cấp phép thương mại.

---

## Tài liệu chi tiết của phiên bản dùng server (tham khảo cho tương lai)

**Các chỉ dẫn bắt buộc cấu hình server bên dưới chỉ áp dụng sau khi chuyển sang `.server`, không áp dụng cho v2.2 preview.**

# Aujunpeak VN — Game Space v2.1 (SwiftUI, GitHub CI FIX)

Full source code for an iPhone app with white/purple premium UI, key-only login, a live device dashboard, App Store game discovery, in-app performance presets, local message UI and a detailed profile. **Contains source + GitHub Actions, not a precompiled IPA.**

## GitHub Actions compilation fix (2026-10-17)

If you previously uploaded Aujunpeak v1 to the **same repository**, using GitHub's Upload Files tool to add the v2 files does **not** delete the older files. The original XcodeGen configuration recursively compiled **every** `.swift` under `App/`, accidentally including `ExploreView`, `HomeView`, `InboxView`, `ProfileView`, `TasksView` and `DemoStore` from v1. This caused `cannot find UIStyle/RoundIcon/SectionTitle in scope` and duplicate `ChatDetailView`. A separate Xcode 16.4 error in `LoginView` was `background(_:ignoresSafeAreaEdges:) requires ... ShapeStyle`.

**v2.1 fixes both:** `project.yml` now lists the exact source files the v2 app needs, so even if obsolete v1 files remain on GitHub they are excluded from the build. `LoginView.swift` now uses `Color.white.ignoresSafeArea()`. `MessagesView.swift` uses a distinct detail-view name.

**Important upload steps for existing GitHub repositories:**

1. Unzip the new v2.1 archive. Upload its **contents** at the **root** of the same repo, not a nested `Aujunpeak-VN-v2.1-FIXED-source/` directory. Select **replace/overwrite** when GitHub asks about duplicate files. If your GitHub interface doesn't offer replacement, edit the three files `project.yml`, `App/Screens/LoginView.swift`, and `App/Screens/MessagesView.swift` directly using the fixed files.
2. Verify that GitHub's **root** `project.yml` contains `- path: App/Screens/OverviewView.swift` and **does not** contain `- path: App` by itself. This is the essential fix.
3. Optionally remove leftover files `App/DemoStore.swift`, `App/Screens/ExploreView.swift`, `HomeView.swift`, `InboxView.swift`, `ProfileView.swift`, and `TasksView.swift` from GitHub (these are no longer used). If you remove them, do so in a separate commit.
4. Open GitHub Actions and rerun **Build iOS IPA (unsigned)** on the newest commit. Check that the compiler list no longer contains old screens.

There is **no claim of a successful end-to-end iOS build** until GitHub Actions/Xcode actually runs on your repository. In this environment, Swift source syntax, project manifest and backend tests were checked.

## What is implemented

| Tab | Implemented functionality |
| --- | --- |
| Login | Compact white screen, **only key field + sign-in button**; key must be verified by HTTPS backend. No guest or demo bypass. Login state is not persisted: each new launch needs a key again. |
| Tổng quan | Gradient hero, total physical RAM, RAM used **by Aujunpeak**, active CPU core count, battery, real IDFV, storage free, thermal state, actions and toast feedback. |
| Game | Searches Apple's public iTunes Search API for live Vietnamese App Store listings, including Free Fire where listed; loads actual title, icon, publisher, store URL, rating; filters/search/refresh. |
| Tăng tốc | Three local UI presets (Cân bằng, Tập trung, Tối giản), reduce *in-app* effects, keep screen awake **while Aujunpeak is active**, compact game cards, clear **Aujunpeak's own URL cache**, refresh metrics, Free Fire setup guide. |
| Tin nhắn | Polished conversation list and thread UI. Local demo messages are stored only in this app's UserDefaults. **No server chat and no real message delivery.** |
| Tài khoản | Real device-provided name (may be generic on modern iOS), hardware identifier (e.g. iPhone17,x), iOS version, app version, IDFV, authenticated display name and key plan/expiry, logout. |

All app buttons are wired. Buttons that only affect this app are labeled accordingly. Toasts are animated and displayed after most interactions; the logout control uses a confirmation dialog.

## iOS limitations — important

- Ordinary sandboxed iOS apps **cannot increase the FPS of Free Fire, free other apps' RAM, alter game memory, inject into a game, or force CPU speed**. Presets in this repo only alter the Aujunpeak experience.
- Total RAM is the device's physical memory. RAM used is the **current Aujunpeak process footprint**, *not* total system RAM consumption. CPU shown is the active logical processor **count**, not a fabricated CPU %.
- Device ID is the **actual identifierForVendor (IDFV)** supplied by iOS. It is **not** UDID, IMEI, serial number or a permanent unique ID. The IDFV may change if all apps from this vendor are uninstalled and reinstalled.
- Game data requires an internet connection, App Store availability in Vietnam, and Apple's live API. Empty/error states are shown instead of fake games.
- The backend example binds a key to the first IDFV through Cloudflare KV, which has eventual consistency. For strict single-device guarantees, replace KV with strongly consistent storage and add server-side rate limiting.

## Configure secure key login — REQUIRED

The app **intentionally refuses to log in** until a real backend is configured. There are no embedded master keys or hardcoded demo keys.

A minimal Cloudflare Worker backend is included in `Backend/cloudflare-worker`.

1. Create a Cloudflare account, create a KV namespace, and update `Backend/cloudflare-worker/wrangler.toml` with its real namespace ID.
2. From `Backend/cloudflare-worker`, run `npm install` and `npx wrangler login`, then `npm run deploy`.
3. Create a high-entropy key locally using `npm run generate-key`. This prints:
   - `LOGIN KEY`: send it privately to a member.
   - `KV KEY`: hashed key prefixed with `key:`.
   - `KV VALUE`: JSON describing the member and expiry time.
4. In the Cloudflare dashboard, add `KV KEY` and `KV VALUE` to the configured namespace. **Do not store the plaintext LOGIN KEY in the repository.**
5. Open `App/Services/KeyAuthentication.swift` and change `AppConfig.authBaseURL` from `""` to your deployed HTTPS Worker base URL, e.g. `"https://your-worker.workers.dev"` (no `/api/activate` suffix). Then upload source to GitHub.
6. On the real iPhone, enter the generated `LOGIN KEY`. The app calls `POST /api/activate` via HTTPS. Invalid, disabled, expired, unrecognized or device-bound-to-another-IDFV keys are rejected.

`/health` returns an online status for connectivity testing. Usernames, tiers and expiry are read from the verified server response; a short **last 4** suffix is shown locally. The full key is not stored in persistent iOS preferences. Each new app launch prompts for a key again.

**Production hardening:** Add throttling/rate-limiting, lockout and abuse protection; replace Cloudflare KV with transactional storage for strictly enforced one-device licenses, consider secure server-issued sessions, and include a complete privacy policy. Apple review requires accurate App Privacy declarations and correct treatment of identifiers. The code is a starting backend, not a hardened commercial license system.

## Build IPA on GitHub Actions

1. Sign in to GitHub; create a repository. Upload **all contents of this folder** (ensure hidden `.github/workflows` is uploaded).
2. Go to **Actions → Build iOS IPA (unsigned) → Run workflow**, or push to `main`.
3. The workflow runs on `macos-15`, installs XcodeGen, generates `AujunpeakUI.xcodeproj` from `project.yml`, compiles Release with signing disabled and packages `AujunpeakVN-unsigned.ipa`.
4. After the action succeeds, open its **Artifacts** section to download the unsigned IPA. This build is for CI checking and is **not directly installable** on a normal iPhone.
5. For an installable IPA, configure `Build iOS IPA (signed)` with Apple Developer signing credentials and provisioning profile; use the appropriate distribution method for your devices.

Required GitHub **Actions secrets** for signed builds:

| Secret | Description |
| --- | --- |
| `IOS_CERTIFICATE_BASE64` | Base64 of Apple Distribution `.p12` |
| `IOS_CERTIFICATE_PASSWORD` | Password for `.p12` |
| `IOS_PROFILE_BASE64` | Base64 of matching provisioning profile |
| `IOS_TEAM_ID` | Apple Developer team ID |
| `IOS_BUNDLE_ID` | Bundle ID matching profile; update project as appropriate |
| `IOS_KEYCHAIN_PASSWORD` | Strong, temporary CI keychain password |

Signing setup must match Apple's current distribution options. For App Store/TestFlight workflows, adjust export method and credentials appropriately. GitHub Actions artifacts may be deleted after 14 days.

## Local Xcode build

- Xcode 16+ and iOS 17+ target.
- Install XcodeGen (`brew install xcodegen`), then run `xcodegen generate` at repo root.
- Open `AujunpeakUI.xcodeproj` in Xcode, select an Apple team, run on an iPhone or simulator.
- On simulator, some battery/model/IDFV readings differ from a physical iPhone.

## Security and data notes

- `UIDevice.identifierForVendor` is sent to the key backend for **device-bound key activation**. This is disclosed in `PrivacyInfo.xcprivacy` as collected Device ID for app functionality. Display/storage readings stay on device.
- Chat history and local preferences use UserDefaults and are not end-to-end encrypted messages or a chat service.
- App Store game imagery and metadata are provided by Apple; each result links to its corresponding App Store page. Observe Apple's rules when using artwork and store data.
- `App/PrivacyInfo.xcprivacy` includes required-reason API declarations for displaying disk space and reading/writing UserDefaults. You remain responsible for confirming the final App Store Connect privacy answers.

## Structure

```
App/
  AujunpeakApp.swift
  Theme.swift
  Components/ToastCenter.swift
  Services/{KeyAuthentication,DeviceInfo,BoostPreferences,GameCatalog,MessageStore}.swift
  Screens/{LoginView,OverviewView,GamesView,BoostView,MessagesView,AccountView}.swift
  Assets.xcassets/
  PrivacyInfo.xcprivacy
Backend/cloudflare-worker/{src/index.js,create-key.mjs,wrangler.toml,package.json}
.github/workflows/{build-unsigned.yml,build-signed.yml}
project.yml
```

## Verification performed in this environment

Static Swift syntax parser (`swiftc -frontend -parse`) and manifest/XML/YAML/source presence checks. **No Xcode runtime, device, signing identity or user GitHub repository was available**, so Xcode compilation and real IPA generation have not been independently confirmed here. The provided GitHub workflows compile and export the IPA once the project is placed in your repository.
