import SwiftUI

struct HUDTheme: Identifiable, Codable, Equatable {
    let id: String
    let styleFamily: ThemeStyleFamily
    let name: String
    let subtitle: String
    let previewImageName: String
    let isPremium: Bool
    let trialDurationMinutes: Int

    // 颜色系统 (存储为 hex)
    let primaryHex: String
    let secondaryHex: String
    let accentHex: String
    let backgroundHex: String
    let alertInfoHex: String
    let alertCautionHex: String
    let alertWarningHex: String
    let alertCriticalHex: String
    let textPrimaryHex: String
    let textSecondaryHex: String

    // 视觉风格
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let glassOpacity: Double
    let blurRadius: CGFloat
    let fontDesign: ThemeFontDesign
    let iconStyle: ThemeIconStyle
    let animationStyle: ThemeAnimationStyle

    // 雷达样式
    let radarStyle: RadarStyle
    let radarRingCount: Int
    let radarSweepEnabled: Bool

    var primaryColor: Color { Color(hex: primaryHex) }
    var secondaryColor: Color { Color(hex: secondaryHex) }
    var accentColor: Color { Color(hex: accentHex) }
    var backgroundColor: Color { Color(hex: backgroundHex) }
    var textPrimaryColor: Color { Color(hex: textPrimaryHex) }
    var textSecondaryColor: Color { Color(hex: textSecondaryHex) }

    var accentGradient: LinearGradient {
        LinearGradient(
            colors: [primaryColor, accentColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func alertColor(for level: AlertLevel) -> Color {
        switch level {
        case .none: .clear
        case .info: Color(hex: alertInfoHex)
        case .caution: Color(hex: alertCautionHex)
        case .warning: Color(hex: alertWarningHex)
        case .critical: Color(hex: alertCriticalHex)
        }
    }
}

// MARK: - 主题风格族

enum ThemeStyleFamily: String, CaseIterable, Codable, Identifiable {
    case apple = "apple"
    case cyberpunk = "cyberpunk"
    case japanese = "japanese"
    case europeanClassical = "european_classical"
    case kawaii = "kawaii"
    case military = "military"
    case retroFuture = "retro_future"
    case minimalistZen = "minimalist_zen"
    case neonCity = "neon_city"
    case nordic = "nordic"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .apple: String(localized: "theme_family_apple")
        case .cyberpunk: String(localized: "theme_family_cyberpunk")
        case .japanese: String(localized: "theme_family_japanese")
        case .europeanClassical: String(localized: "theme_family_european")
        case .kawaii: String(localized: "theme_family_kawaii")
        case .military: String(localized: "theme_family_military")
        case .retroFuture: String(localized: "theme_family_retro")
        case .minimalistZen: String(localized: "theme_family_zen")
        case .neonCity: String(localized: "theme_family_neon")
        case .nordic: String(localized: "theme_family_nordic")
        }
    }

    var icon: String {
        switch self {
        case .apple: "apple.logo"
        case .cyberpunk: "bolt.trianglebadge.exclamationmark"
        case .japanese: "leaf.fill"
        case .europeanClassical: "building.columns.fill"
        case .kawaii: "pawprint.fill"
        case .military: "shield.checkered"
        case .retroFuture: "tv.fill"
        case .minimalistZen: "circle.dotted"
        case .neonCity: "building.2.fill"
        case .nordic: "snowflake"
        }
    }

    var isFree: Bool { self == .apple }

    var price: Decimal {
        switch self {
        case .apple: 0
        default: 2.99
        }
    }

    var themeCount: Int {
        switch self {
        case .apple: 3
        case .cyberpunk: 4
        case .japanese: 3
        case .europeanClassical: 3
        case .kawaii: 4
        case .military: 3
        case .retroFuture: 3
        case .minimalistZen: 3
        case .neonCity: 3
        case .nordic: 3
        }
    }
}

enum ThemeFontDesign: String, Codable {
    case standard
    case rounded
    case monospaced
    case serif

    var swiftUIDesign: Font.Design {
        switch self {
        case .standard: .default
        case .rounded: .rounded
        case .monospaced: .monospaced
        case .serif: .serif
        }
    }
}

enum ThemeIconStyle: String, Codable {
    case sfSymbol
    case outlined
    case filled
    case custom
}

enum ThemeAnimationStyle: String, Codable {
    case smooth
    case snappy
    case glitch
    case organic
    case bounce
}

enum RadarStyle: String, Codable {
    case classic
    case tactical
    case minimal
    case decorative
    case kawaii
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
