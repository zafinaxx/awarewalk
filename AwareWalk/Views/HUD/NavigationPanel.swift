import SwiftUI

/// 底部导航面板 — 类似车载 HUD 的导航信息显示
struct NavigationPanel: View {
    let state: NavigationState
    let theme: HUDTheme

    var body: some View {
        VStack(spacing: 0) {
            maneuverBar
            progressBar
        }
        .background(theme.backgroundColor.opacity(theme.glassOpacity + 0.1))
        .clipShape(.rect(cornerRadius: theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(theme.primaryColor.opacity(0.4), lineWidth: theme.borderWidth)
        )
    }

    // MARK: - 转弯指示条

    private var maneuverBar: some View {
        HStack(spacing: 16) {
            maneuverIcon

            VStack(alignment: .leading, spacing: 4) {
                Text(maneuverText)
                    .font(.system(.title3, design: theme.fontDesign.swiftUIDesign, weight: .bold))
                    .foregroundStyle(theme.textPrimaryColor)

                if !state.nextStreetName.isEmpty {
                    Text(state.nextStreetName)
                        .font(.system(.subheadline, design: theme.fontDesign.swiftUIDesign))
                        .foregroundStyle(theme.textSecondaryColor)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(state.formattedETA)
                    .font(.system(.title3, design: theme.fontDesign.swiftUIDesign, weight: .semibold))
                    .foregroundStyle(theme.accentColor)

                Text(state.formattedDistance)
                    .font(.system(.caption, design: theme.fontDesign.swiftUIDesign))
                    .foregroundStyle(theme.textSecondaryColor)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private var maneuverIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: theme.cornerRadius / 2)
                .fill(theme.primaryColor.opacity(0.2))
                .frame(width: 48, height: 48)

            Image(systemName: state.nextManeuver.icon)
                .font(.title2.weight(.bold))
                .foregroundStyle(theme.primaryColor)
        }
    }

    private var maneuverText: String {
        if state.nextManeuver == .arrive {
            return String(localized: "nav_arriving")
        }
        return "\(state.formattedNextDistance) \(state.nextManeuver.localizedLabel)"
    }

    // MARK: - 进度条

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(theme.primaryColor.opacity(0.1))

                Rectangle()
                    .fill(theme.accentGradient)
                    .frame(width: geo.size.width * progressRatio)
            }
        }
        .frame(height: 4)
    }

    private var progressRatio: CGFloat {
        guard state.distanceRemaining > 0 else { return 1.0 }
        return max(0, min(1, 1 - state.distanceRemaining / max(state.distanceRemaining + 100, 1)))
    }
}
