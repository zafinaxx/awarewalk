import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @State private var showOnboarding = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                headerSection
                hudControlSection
                quickActionsSection
            }
            .padding(40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .sheet(isPresented: $showOnboarding) {
                OnboardingView()
            }
            .onAppear {
                if !UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                    showOnboarding = true
                }
            }
        }
    }

    // MARK: - 顶部标题区

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "eye.trianglebadge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(appState.currentTheme.accentGradient)
                .symbolEffect(.pulse, options: .repeating)

            Text("AwareWalk")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(appState.currentTheme.accentGradient)

            Text("hud_subtitle")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - HUD 控制区

    private var hudControlSection: some View {
        VStack(spacing: 20) {
            Button {
                Task {
                    if appState.isHUDActive {
                        await dismissImmersiveSpace()
                        appState.isHUDActive = false
                    } else {
                        let result = await openImmersiveSpace(id: "hud-space")
                        if case .opened = result {
                            appState.isHUDActive = true
                        }
                    }
                }
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: appState.isHUDActive ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title)
                    Text(appState.isHUDActive ? "hud_stop" : "hud_start")
                        .font(.title2.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(appState.isHUDActive ? .red : appState.currentTheme.primaryColor)

            HStack(spacing: 12) {
                StatusIndicator(
                    icon: "location.fill",
                    label: String(localized: "status_gps"),
                    isActive: true
                )
                StatusIndicator(
                    icon: "antenna.radiowaves.left.and.right",
                    label: String(localized: "status_radar"),
                    isActive: appState.radarEnabled
                )
                StatusIndicator(
                    icon: "bell.fill",
                    label: String(localized: "status_alerts"),
                    isActive: appState.soundEnabled
                )
            }
        }
        .padding(24)
        .background(.regularMaterial, in: .rect(cornerRadius: 20))
    }

    // MARK: - 快捷操作

    private var quickActionsSection: some View {
        HStack(spacing: 16) {
            QuickActionButton(
                icon: "paintpalette.fill",
                label: String(localized: "action_themes"),
                color: .purple
            ) {
                openWindow(id: "theme-gallery")
            }

            QuickActionButton(
                icon: "map.fill",
                label: String(localized: "action_navigate"),
                color: .blue
            ) {
                appState.isNavigating.toggle()
            }

            QuickActionButton(
                icon: "gearshape.fill",
                label: String(localized: "action_settings"),
                color: .gray
            ) {
                openWindow(id: "settings")
            }
        }
    }
}

// MARK: - 子组件

struct StatusIndicator: View {
    let icon: String
    let label: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(isActive ? .green : .secondary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.subheadline.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
        .buttonStyle(.bordered)
        .tint(color)
    }
}
