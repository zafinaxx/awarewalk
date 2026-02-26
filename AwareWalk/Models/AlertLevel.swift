import SwiftUI

enum AlertLevel: Int, Comparable, CaseIterable {
    case none = 0
    case info = 1
    case caution = 2
    case warning = 3
    case critical = 4

    static func < (lhs: AlertLevel, rhs: AlertLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var color: Color {
        switch self {
        case .none: .clear
        case .info: .blue
        case .caution: .yellow
        case .warning: .orange
        case .critical: .red
        }
    }

    var borderOpacity: Double {
        switch self {
        case .none: 0
        case .info: 0.3
        case .caution: 0.5
        case .warning: 0.7
        case .critical: 1.0
        }
    }

    var pulseSpeed: Double {
        switch self {
        case .none: 0
        case .info: 3.0
        case .caution: 2.0
        case .warning: 1.0
        case .critical: 0.4
        }
    }

    var hapticIntensity: Float {
        switch self {
        case .none: 0
        case .info: 0.2
        case .caution: 0.5
        case .warning: 0.8
        case .critical: 1.0
        }
    }

    var soundName: String? {
        switch self {
        case .none: nil
        case .info: "alert_info"
        case .caution: "alert_caution"
        case .warning: "alert_warning"
        case .critical: "alert_critical"
        }
    }

    var localizedLabel: String {
        switch self {
        case .none: String(localized: "alert_none")
        case .info: String(localized: "alert_info")
        case .caution: String(localized: "alert_caution")
        case .warning: String(localized: "alert_warning")
        case .critical: String(localized: "alert_critical")
        }
    }

    var icon: String {
        switch self {
        case .none: "checkmark.shield"
        case .info: "info.circle"
        case .caution: "exclamationmark.triangle"
        case .warning: "exclamationmark.triangle.fill"
        case .critical: "xmark.octagon.fill"
        }
    }
}
