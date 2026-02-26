import SwiftUI
import Observation
import MapKit

@MainActor
@Observable
final class AppState {
    // MARK: - HUD 状态
    var isHUDActive = false
    var isNavigating = false
    var currentAlertLevel: AlertLevel = .none

    // MARK: - 导航状态
    var navigationState = NavigationState()
    var radarPoints: [RadarPoint] = []

    // MARK: - 主题系统
    var themeManager = ThemeManager()
    var currentTheme: HUDTheme { themeManager.activeTheme }

    // MARK: - 用户偏好
    var alertSensitivity: AlertSensitivity = .normal
    var radarEnabled = true
    var soundEnabled = true
    var hapticEnabled = true
    var nightModeEnabled = false

    // MARK: - 订阅状态
    var subscriptionManager = SubscriptionManager()
    var isProUser: Bool { subscriptionManager.isSubscribed }

    // MARK: - 天气
    var weatherInfo: WeatherInfo?
    var batteryLevel: Int = 85
    var currentTime: Date = .now
}

enum AlertSensitivity: String, CaseIterable, Codable {
    case low = "low"
    case normal = "normal"
    case high = "high"

    var displayName: String {
        switch self {
        case .low: String(localized: "alert_sensitivity_low")
        case .normal: String(localized: "alert_sensitivity_normal")
        case .high: String(localized: "alert_sensitivity_high")
        }
    }
}

struct WeatherInfo {
    var temperature: Double
    var condition: WeatherCondition
    var iconName: String

    enum WeatherCondition: String {
        case sunny, cloudy, rainy, snowy, windy, foggy
    }
}
