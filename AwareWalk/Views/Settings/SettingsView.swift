import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        @Bindable var state = appState

        NavigationStack {
            Form {
                Section("settings_hud") {
                    Toggle("settings_radar", isOn: $state.radarEnabled)
                    Toggle("settings_night_mode", isOn: $state.nightModeEnabled)
                }

                Section("settings_alerts") {
                    Picker("settings_sensitivity", selection: $state.alertSensitivity) {
                        ForEach(AlertSensitivity.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    Toggle("settings_sound", isOn: $state.soundEnabled)
                    Toggle("settings_haptic", isOn: $state.hapticEnabled)
                }

                navigationSection
                themeSection
                subscriptionSection
                aboutSection
            }
            .navigationTitle("settings_title")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("settings_done") {
                        dismissWindow(id: "settings")
                    }
                }
            }
        }
    }

    // MARK: - 导航设置

    private var navigationSection: some View {
        Section("settings_navigation") {
            NavigationLink {
                Text("settings_map_source_detail")
            } label: {
                HStack {
                    Text("settings_map_source")
                    Spacer()
                    Text("Apple Maps")
                        .foregroundStyle(.secondary)
                }
            }

            NavigationLink {
                Text("settings_voice_detail")
            } label: {
                Text("settings_voice_guidance")
            }
        }
    }

    // MARK: - 主题设置

    private var themeSection: some View {
        Section("settings_appearance") {
            HStack {
                Text("settings_current_theme")
                Spacer()
                Text(appState.currentTheme.name)
                    .foregroundStyle(.secondary)
            }

            NavigationLink {
                Text("settings_custom_theme_detail")
            } label: {
                Text("settings_custom_themes")
            }
        }
    }

    // MARK: - 订阅

    @State private var showingUpgrade = false

    private var subscriptionSection: some View {
        Section("settings_subscription") {
            HStack {
                Text("settings_status")
                Spacer()
                Text(appState.isProUser ? "Pro" : "Free")
                    .foregroundStyle(appState.isProUser ? .orange : .secondary)
                    .fontWeight(appState.isProUser ? .bold : .regular)
            }

            if !appState.isProUser {
                Button("settings_upgrade_pro") {
                    showingUpgrade = true
                }
                .foregroundStyle(.orange)
                .sheet(isPresented: $showingUpgrade) {
                    ProSubscriptionSheet()
                        .environment(appState)
                }
            }

            Button("settings_restore") {
                Task {
                    await appState.subscriptionManager.restorePurchases()
                }
            }
        }
    }

    // MARK: - 关于

    private var aboutSection: some View {
        Section("settings_about") {
            HStack {
                Text("settings_version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }

            Link("settings_privacy", destination: URL(string: "https://jingjingapp.github.io/awarewalk/privacy/")!)
            Link("settings_terms", destination: URL(string: "https://jingjingapp.github.io/awarewalk/terms/")!)
            Link("settings_support", destination: URL(string: "mailto:jingjingapp@outlook.com")!)
        }
    }
}
