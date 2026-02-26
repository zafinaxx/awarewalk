import SwiftUI
import Observation

@MainActor
@Observable
final class ThemeManager {
    var activeThemeId: String = "apple_standard"
    var purchasedFamilies: Set<String> = ["apple"]
    var trialRecords: [String: Date] = [:]

    var activeTheme: HUDTheme {
        allThemes.first { $0.id == activeThemeId } ?? ThemeLibrary.appleStandard
    }

    var allThemes: [HUDTheme] {
        ThemeLibrary.allThemes
    }

    var allFamilies: [ThemeStyleFamily] {
        ThemeStyleFamily.allCases
    }

    init() {
        loadFromDefaults()
    }

    // MARK: - 主题族分组

    func themes(for family: ThemeStyleFamily) -> [HUDTheme] {
        allThemes.filter { $0.styleFamily == family }
    }

    // MARK: - 购买状态

    func isFamilyPurchased(_ family: ThemeStyleFamily) -> Bool {
        family.isFree || purchasedFamilies.contains(family.rawValue)
    }

    func isThemeAvailable(_ theme: HUDTheme) -> Bool {
        if !theme.isPremium { return true }
        if isFamilyPurchased(theme.styleFamily) { return true }
        return isTrialActive(for: theme)
    }

    // MARK: - 试用机制

    func startTrial(for theme: HUDTheme) {
        trialRecords[theme.id] = Date()
        saveToDefaults()
    }

    func isTrialActive(for theme: HUDTheme) -> Bool {
        guard let startDate = trialRecords[theme.id] else { return false }
        let elapsed = Date().timeIntervalSince(startDate)
        let trialDuration = TimeInterval(theme.trialDurationMinutes * 60)
        return elapsed < trialDuration
    }

    func trialTimeRemaining(for theme: HUDTheme) -> TimeInterval? {
        guard let startDate = trialRecords[theme.id] else { return nil }
        let elapsed = Date().timeIntervalSince(startDate)
        let trialDuration = TimeInterval(theme.trialDurationMinutes * 60)
        let remaining = trialDuration - elapsed
        return remaining > 0 ? remaining : nil
    }

    // MARK: - 选择主题

    func selectTheme(_ theme: HUDTheme) {
        guard isThemeAvailable(theme) else { return }
        activeThemeId = theme.id
        saveToDefaults()
    }

    func purchaseFamily(_ family: ThemeStyleFamily) {
        purchasedFamilies.insert(family.rawValue)
        saveToDefaults()
    }

    // MARK: - UserDefaults 持久化

    private func saveToDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(activeThemeId, forKey: "theme_activeId")
        defaults.set(Array(purchasedFamilies), forKey: "theme_purchased")
        let trialData = trialRecords.mapValues { $0.timeIntervalSince1970 }
        defaults.set(trialData, forKey: "theme_trials")
    }

    private func loadFromDefaults() {
        let defaults = UserDefaults.standard
        if let id = defaults.string(forKey: "theme_activeId") {
            activeThemeId = id
        }
        if let arr = defaults.stringArray(forKey: "theme_purchased") {
            purchasedFamilies = Set(arr)
        }
        if let dict = defaults.dictionary(forKey: "theme_trials") as? [String: Double] {
            trialRecords = dict.mapValues { Date(timeIntervalSince1970: $0) }
        }
    }
}
