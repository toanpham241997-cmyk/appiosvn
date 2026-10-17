import SwiftUI
import UIKit

enum GamePreset: String, CaseIterable, Identifiable {
    case balanced = "Balanced"
    case focus = "Tournament"
    case minimal = "Stealth"

    var id: String { rawValue }
}

@MainActor final class BoostPreferences: ObservableObject {
    @AppStorage("game_preset") private var storedPreset: String = GamePreset.balanced.rawValue
    @AppStorage("reduce_in_app_effects") var reduceEffects = false { didSet { objectWillChange.send() } }
    @AppStorage("keep_screen_awake") var keepScreenAwake = false { didSet { applyIdleTimer(); objectWillChange.send() } }
    @AppStorage("compact_game_cards") var compactCards = false { didSet { objectWillChange.send() } }

    @AppStorage("aim_assist_preview") var aimAssist = true { didSet { objectWillChange.send() } }
    @AppStorage("touch_sync_preview") var touchSync = true { didSet { objectWillChange.send() } }
    @AppStorage("head_trace_preview") var headTrace = false { didSet { objectWillChange.send() } }
    @AppStorage("optimizer_preview") var optimizer = true { didSet { objectWillChange.send() } }
    @AppStorage("network_guard_preview") var networkGuard = true { didSet { objectWillChange.send() } }
    @AppStorage("fps_overlay_preview") var fpsOverlay = false { didSet { objectWillChange.send() } }

    @Published var isClearing = false

    var preset: GamePreset {
        get { GamePreset(rawValue: storedPreset) ?? .balanced }
        set {
            storedPreset = newValue.rawValue
            switch newValue {
            case .balanced:
                reduceEffects = false
                compactCards = false
            case .focus:
                reduceEffects = false
                compactCards = true
                fpsOverlay = true
            case .minimal:
                reduceEffects = true
                compactCards = true
            }
            objectWillChange.send()
        }
    }

    func applyIdleTimer() { UIApplication.shared.isIdleTimerDisabled = keepScreenAwake }
    func pauseIdleTimer() { UIApplication.shared.isIdleTimerDisabled = false }
    func clearOwnCache() { URLCache.shared.removeAllCachedResponses() }
}
