import SwiftUI
import Observation

@Observable
final class ThemeManager: Codable {
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
        save()
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
        save()
    }

    func purchaseFamily(_ family: ThemeStyleFamily) {
        purchasedFamilies.insert(family.rawValue)
        save()
    }

    // MARK: - 持久化

    private func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "ThemeManager")
        }
    }

    static func load() -> ThemeManager {
        guard let data = UserDefaults.standard.data(forKey: "ThemeManager"),
              let manager = try? JSONDecoder().decode(ThemeManager.self, from: data)
        else {
            return ThemeManager()
        }
        return manager
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case activeThemeId, purchasedFamilies, trialRecords
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        activeThemeId = try container.decode(String.self, forKey: .activeThemeId)
        purchasedFamilies = try container.decode(Set<String>.self, forKey: .purchasedFamilies)
        trialRecords = try container.decode([String: Date].self, forKey: .trialRecords)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(activeThemeId, forKey: .activeThemeId)
        try container.encode(purchasedFamilies, forKey: .purchasedFamilies)
        try container.encode(trialRecords, forKey: .trialRecords)
    }
}
