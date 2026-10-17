import Foundation

enum LoginProvider: String, CaseIterable, Identifiable {
    case google = "Google"
    case github = "GitHub"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .google: return "globe"
        case .github: return "chevron.left.forwardslash.chevron.right"
        }
    }
}

struct AuthenticatedProfile {
    let displayName: String
    let tier: String
    let provider: String
    let memberSince: Date
}

@MainActor final class SessionManager: ObservableObject {
    @Published private(set) var profile: AuthenticatedProfile?
    @Published var isChecking = false
    @Published var loginError: String?

    var isLoggedIn: Bool { profile != nil }

    func signIn(with provider: LoginProvider) async {
        guard !isChecking else { return }
        loginError = nil
        isChecking = true
        defer { isChecking = false }
        try? await Task.sleep(for: .milliseconds(700))
        profile = AuthenticatedProfile(
            displayName: provider == .google ? "Google Player" : "GitHub Player",
            tier: "Preview Access",
            provider: provider.rawValue,
            memberSince: Date()
        )
    }

    func logout() {
        profile = nil
        loginError = nil
    }
}
