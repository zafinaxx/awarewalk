import SwiftUI

enum AppConstants {
    static let appName = "AwareWalk"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"

    // MARK: - 定价 (USD)
    enum Pricing {
        static let appPrice: Decimal = 12.99
        static let monthlySubscription: Decimal = 2.99
        static let yearlySubscription: Decimal = 12.99
        static let proUnlock: Decimal = 12.99
        static let themePackPrice: Decimal = 2.99
    }

    // MARK: - 空间感知参数
    enum Awareness {
        static let defaultScanRadius: Float = 30.0
        static let maxScanRadius: Float = 50.0
        static let updateInterval: TimeInterval = 0.1
        static let stalePointTimeout: TimeInterval = 2.0
        static let criticalDistance: Float = 3.0
        static let warningDistance: Float = 10.0
        static let cautionDistance: Float = 20.0
    }

    // MARK: - HUD 布局
    enum HUD {
        static let radarDefaultSize: CGFloat = 160
        static let radarTacticalSize: CGFloat = 200
        static let radarMinimalSize: CGFloat = 120
        static let hudWidth: CGFloat = 600
        static let hudHeight: CGFloat = 400
        static let navPanelMaxWidth: CGFloat = 500
    }

    // MARK: - 主题试用
    enum Trial {
        static let defaultDurationMinutes = 30
        static let extendedDurationMinutes = 60
    }

    // MARK: - 动画
    enum Animation {
        static let springResponse: Double = 0.3
        static let alertPulseMin: Double = 0.4
        static let alertPulseMax: Double = 3.0
    }

    // MARK: - StoreKit Product IDs
    enum ProductIDs {
        static let monthlyPro = "com.jingjing.AwareWalk.pro.monthly"
        static let yearlyPro = "com.jingjing.AwareWalk.pro.yearly"
        static let lifetimePro = "com.jingjing.AwareWalk.pro.lifetime"
        static let proUnlock = "com.jingjing.AwareWalk.pro.unlock"
        static let themePrefix = "com.jingjing.AwareWalk.theme."
    }

    // MARK: - 支持的市场
    enum Markets {
        static let supported = ["US", "JP", "KR"]
        static let currencies: [String: String] = [
            "US": "USD",
            "JP": "JPY",
            "KR": "KRW"
        ]
    }
}
