import Foundation
import UIKit

// Chế độ xem trước: chưa gọi server/API. Chỉ dùng để thử giao diện.
// Khi triển khai key thật, đổi .localPreview thành .server và khai báo authBaseURL.
// KHÔNG dùng key hardcode trong bản phân phối thương mại: ai cũng có thể đọc key này.
enum AuthenticationMode { case localPreview, server }
enum AppConfig {
    static let authenticationMode: AuthenticationMode = .localPreview
    static let previewKey = "havanhuan"
    static let authBaseURL = "" // HTTPS Cloudflare Worker URL khi chuyển sang .server
}

struct AuthenticatedProfile {
    let displayName: String
    let tier: String
    let keySuffix: String
    let expiresAt: Date?
}

@MainActor final class SessionManager: ObservableObject {
    @Published private(set) var profile: AuthenticatedProfile?
    @Published var isChecking = false
    @Published var loginError: String?

    var isLoggedIn: Bool { profile != nil }

    func login(key: String) async {
        let normalized = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { loginError = "Vui lòng nhập key đăng nhập."; return }
        guard !isChecking else { return }
        loginError = nil

        // Xem trước offline: không cần Cloudflare, không gọi mạng hay gửi ID thiết bị.
        if AppConfig.authenticationMode == .localPreview {
            guard normalized == AppConfig.previewKey else {
                loginError = "Key không đúng. Vui lòng nhập chính xác key xem trước."
                return
            }
            profile = AuthenticatedProfile(
                displayName: "Aujunpeak Preview",
                tier: "Preview",
                keySuffix: String(normalized.suffix(4)),
                expiresAt: nil
            )
            return
        }

        await loginWithServer(key: normalized)
    }

    // Chưa sử dụng trong bản preview. Giữ sẵn để bổ sung máy chủ xác thực sau này.
    private func loginWithServer(key normalized: String) async {
        guard let root = URL(string: AppConfig.authBaseURL), root.scheme == "https", root.host != nil else {
            loginError = "Chưa cấu hình máy chủ xác thực. Xem README để kết nối key server."
            return
        }
        guard !isChecking else { return }
        isChecking = true
        loginError = nil
        defer { isChecking = false }
        do {
            let endpoint = root.appendingPathComponent("api/activate")
            var request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 15
            request.httpBody = try JSONEncoder().encode(ActivateRequest(
                key: normalized,
                vendorId: UIDevice.current.identifierForVendor?.uuidString ?? "",
                model: UIDevice.current.model
            ))
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw AuthError.server }
            let result = try JSONDecoder().decode(ActivateResponse.self, from: data)
            guard http.statusCode == 200, result.valid == true else {
                throw AuthError.rejected(result.message ?? "Key không hợp lệ hoặc đã hết hạn.")
            }
            let expiry = result.expiresAt.flatMap { ISO8601DateFormatter().date(from: $0) }
            if let expiry, expiry <= Date() { throw AuthError.rejected("Key đã hết hạn.") }
            profile = AuthenticatedProfile(
                displayName: result.displayName ?? "Aujunpeak Member",
                tier: result.tier ?? "Member",
                keySuffix: String(normalized.suffix(4)),
                expiresAt: expiry
            )
        } catch let error as AuthError {
            loginError = error.localizedDescription
        } catch {
            loginError = "Không kết nối được máy chủ key: \(error.localizedDescription)"
        }
    }

    func logout() { profile = nil; loginError = nil }
}

private struct ActivateRequest: Encodable {
    let key: String
    let vendorId: String
    let model: String
}
private struct ActivateResponse: Decodable {
    let valid: Bool
    let displayName: String?
    let tier: String?
    let expiresAt: String?
    let message: String?
}
private enum AuthError: LocalizedError {
    case server
    case rejected(String)
    var errorDescription: String? {
        switch self {
        case .server: return "Phản hồi máy chủ không hợp lệ."
        case .rejected(let message): return message
        }
    }
}
