import SwiftUI

/// HUD 组合视图 — 将所有 HUD 元素组合成完整的抬头显示界面
struct HUDCompositeView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = HUDViewModel()

    var body: some View {
        let theme = appState.currentTheme

        ZStack {
            alertLayer(theme: theme)
            hudContent(theme: theme)
        }
        .task {
            await viewModel.activateHUD()
        }
        .onDisappear {
            viewModel.deactivateHUD()
        }
    }

    // MARK: - 预警层（最底层，全屏）

    @ViewBuilder
    private func alertLayer(theme: HUDTheme) -> some View {
        AlertOverlay(
            level: viewModel.alertLevel,
            direction: viewModel.alertManager.alertDirection,
            message: viewModel.alertManager.alertMessage,
            theme: theme,
            isVisible: viewModel.alertManager.isAlertVisible
        )
    }

    // MARK: - HUD 内容层

    @ViewBuilder
    private func hudContent(theme: HUDTheme) -> some View {
        VStack {
            topBar(theme: theme)
            Spacer()
            centerArea(theme: theme)
            Spacer()
            bottomArea(theme: theme)
        }
        .padding(24)
    }

    // MARK: - 顶部：信息栏

    private func topBar(theme: HUDTheme) -> some View {
        InfoBar(
            time: viewModel.currentTime,
            weather: appState.weatherInfo,
            batteryLevel: appState.batteryLevel,
            theme: theme
        )
        .frame(maxWidth: 400)
    }

    // MARK: - 中央：雷达环

    @ViewBuilder
    private func centerArea(theme: HUDTheme) -> some View {
        if appState.radarEnabled {
            RadarView(
                points: viewModel.radarPoints,
                theme: theme,
                size: radarSize(for: theme)
            )
            .opacity(0.85)
        }
    }

    private func radarSize(for theme: HUDTheme) -> CGFloat {
        switch theme.radarStyle {
        case .tactical: 200
        case .minimal: 120
        case .kawaii: 160
        default: 160
        }
    }

    // MARK: - 底部：导航面板

    @ViewBuilder
    private func bottomArea(theme: HUDTheme) -> some View {
        if viewModel.isNavigating {
            NavigationPanel(
                state: viewModel.navState,
                theme: theme
            )
            .frame(maxWidth: 500)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        } else {
            standbyPanel(theme: theme)
        }
    }

    private func standbyPanel(theme: HUDTheme) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "shield.checkered")
                .font(.title3)
                .foregroundStyle(theme.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text("hud_standby_title")
                    .font(.system(.subheadline, design: theme.fontDesign.swiftUIDesign, weight: .semibold))
                    .foregroundStyle(theme.textPrimaryColor)
                Text("hud_standby_subtitle")
                    .font(.system(.caption, design: theme.fontDesign.swiftUIDesign))
                    .foregroundStyle(theme.textSecondaryColor)
            }

            Spacer()

            SpeedIndicator(speed: viewModel.navState.speedKmh, theme: theme)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(theme.backgroundColor.opacity(theme.glassOpacity))
        .clipShape(.rect(cornerRadius: theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(theme.primaryColor.opacity(0.2), lineWidth: theme.borderWidth * 0.5)
        )
        .frame(maxWidth: 500)
    }
}

struct SpeedIndicator: View {
    let speed: Double
    let theme: HUDTheme

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%.1f", speed))
                .font(.system(.title3, design: theme.fontDesign.swiftUIDesign, weight: .bold))
                .foregroundStyle(theme.primaryColor)
            Text("km/h")
                .font(.system(.caption2, design: theme.fontDesign.swiftUIDesign))
                .foregroundStyle(theme.textSecondaryColor)
        }
    }
}
