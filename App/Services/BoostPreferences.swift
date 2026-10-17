import SwiftUI
import UIKit

enum GamePreset: String, CaseIterable, Identifiable {
    case balanced = "Cân bằng"
    case focus = "Tập trung"
    case minimal = "Tối giản"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .balanced: return "slider.horizontal.3"
        case .focus: return "scope"
        case .minimal: return "leaf.fill"
        }
    }
    var description: String {
        switch self {
        case .balanced: return "Giao diện đầy đủ"
        case .focus: return "Ít yếu tố gây phân tâm"
        case .minimal: return "Giảm hiệu ứng trong Aujunpeak"
        }
    }
}

@MainActor final class BoostPreferences: ObservableObject {
    @AppStorage("game_preset") private var storedPreset: String = GamePreset.balanced.rawValue
    @AppStorage("reduce_in_app_effects") var reduceEffects = false { didSet { objectWillChange.send() } }
    @AppStorage("keep_screen_awake") var keepScreenAwake = false { didSet { applyIdleTimer(); objectWillChange.send() } }
    @AppStorage("compact_game_cards") var compactCards = false { didSet { objectWillChange.send() } }
    @Published var isClearing = false
    var preset: GamePreset {
        get { GamePreset(rawValue: storedPreset) ?? .balanced }
        set {
            storedPreset = newValue.rawValue
            if newValue == .minimal { reduceEffects = true; compactCards = true }
            if newValue == .balanced { reduceEffects = false; compactCards = false }
            objectWillChange.send()
        }
    }
    func applyIdleTimer() { UIApplication.shared.isIdleTimerDisabled = keepScreenAwake }
    func pauseIdleTimer() { UIApplication.shared.isIdleTimerDisabled = false }
    func clearOwnCache() {
        URLCache.shared.removeAllCachedResponses()
    }
}
