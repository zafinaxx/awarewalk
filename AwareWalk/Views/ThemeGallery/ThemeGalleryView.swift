import SwiftUI

/// 主题画廊 — 展示所有风格族和主题，支持购买和试用
struct ThemeGalleryView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedFamily: ThemeStyleFamily = .apple
    @State private var showingPurchase = false
    @State private var purchaseTarget: ThemeStyleFamily?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    familyPicker
                    themesGrid
                }
                .padding(24)
            }
            .navigationTitle("theme_gallery_title")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !appState.isProUser {
                        Button {
                            showingPurchase = true
                        } label: {
                            Label("theme_unlock_all", systemImage: "crown.fill")
                        }
                        .tint(.yellow)
                    }
                }
            }
            .sheet(isPresented: $showingPurchase) {
                if let family = purchaseTarget {
                    ThemePurchaseSheet(family: family)
                        .environment(appState)
                } else {
                    ProSubscriptionSheet()
                        .environment(appState)
                }
            }
        }
    }

    // MARK: - 风格族选择器

    private var familyPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ThemeStyleFamily.allCases) { family in
                    FamilyTab(
                        family: family,
                        isSelected: selectedFamily == family,
                        isPurchased: appState.themeManager.isFamilyPurchased(family)
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedFamily = family
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - 主题网格

    private var themesGrid: some View {
        let themes = appState.themeManager.themes(for: selectedFamily)

        return VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedFamily.displayName)
                        .font(.title2.weight(.bold))
                    Text(familySubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                if !selectedFamily.isFree && !appState.themeManager.isFamilyPurchased(selectedFamily) {
                    Button {
                        purchaseTarget = selectedFamily
                        showingPurchase = true
                    } label: {
                        Label(String(localized: "theme_unlock_family"), systemImage: "lock.open.fill")
                            .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                }
            }

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
            ], spacing: 16) {
                ForEach(themes) { theme in
                    ThemeCard(
                        theme: theme,
                        isActive: theme.id == appState.themeManager.activeThemeId,
                        isAvailable: appState.themeManager.isThemeAvailable(theme),
                        trialRemaining: appState.themeManager.trialTimeRemaining(for: theme)
                    ) {
                        handleThemeSelection(theme)
                    } onTrial: {
                        appState.themeManager.startTrial(for: theme)
                        appState.themeManager.selectTheme(theme)
                    }
                }
            }
        }
    }

    private var familySubtitle: String {
        let count = appState.themeManager.themes(for: selectedFamily).count
        return String(localized: "theme_count_\(count)")
    }

    private func handleThemeSelection(_ theme: HUDTheme) {
        if appState.themeManager.isThemeAvailable(theme) {
            withAnimation(.spring(response: 0.3)) {
                appState.themeManager.selectTheme(theme)
            }
        }
    }
}

// MARK: - 风格族标签

struct FamilyTab: View {
    let family: ThemeStyleFamily
    let isSelected: Bool
    let isPurchased: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: family.icon)
                    .font(.title3)
                Text(family.displayName)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
            }
            .frame(width: 80, height: 70)
            .background(isSelected ? Color.accentColor.opacity(0.15) : .clear)
            .clipShape(.rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 2)
            )
            .overlay(alignment: .topTrailing) {
                if !family.isFree && !isPurchased {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                        .padding(4)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 主题卡片

struct ThemeCard: View {
    let theme: HUDTheme
    let isActive: Bool
    let isAvailable: Bool
    let trialRemaining: TimeInterval?
    let onSelect: () -> Void
    let onTrial: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            themePreview
            themeInfo
        }
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isActive ? Color.accentColor : .clear, lineWidth: 3)
        )
        .shadow(color: isActive ? .accentColor.opacity(0.3) : .clear, radius: 8)
        .opacity(isAvailable ? 1 : 0.7)
    }

    // MARK: - 主题预览

    private var themePreview: some View {
        ZStack {
            // 背景色
            Rectangle()
                .fill(theme.backgroundColor)

            // 迷你 HUD 预览
            VStack(spacing: 8) {
                // 迷你信息栏
                HStack {
                    Circle()
                        .fill(theme.accentColor)
                        .frame(width: 6, height: 6)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.textPrimaryColor.opacity(0.5))
                        .frame(width: 30, height: 4)
                    Spacer()
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.textSecondaryColor.opacity(0.5))
                        .frame(width: 20, height: 4)
                }
                .padding(.horizontal, 12)

                // 迷你雷达
                ZStack {
                    Circle()
                        .stroke(theme.primaryColor.opacity(0.3), lineWidth: 0.5)
                        .frame(width: 40, height: 40)
                    Circle()
                        .stroke(theme.primaryColor.opacity(0.2), lineWidth: 0.5)
                        .frame(width: 25, height: 25)
                    Circle()
                        .fill(theme.accentColor)
                        .frame(width: 3, height: 3)

                    // 几个示例点
                    Circle().fill(Color.green).frame(width: 3, height: 3).offset(x: 10, y: -8)
                    Circle().fill(Color.red).frame(width: 4, height: 4).offset(x: -12, y: 5)
                    Circle().fill(Color.cyan).frame(width: 3, height: 3).offset(x: 5, y: 14)
                }

                // 迷你导航条
                HStack(spacing: 6) {
                    Image(systemName: "arrow.turn.up.right")
                        .font(.system(size: 8))
                        .foregroundStyle(theme.primaryColor)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.textPrimaryColor.opacity(0.4))
                        .frame(width: 40, height: 3)
                    Spacer()
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.accentColor.opacity(0.6))
                        .frame(width: 20, height: 3)
                }
                .padding(.horizontal, 12)
            }
            .padding(.vertical, 12)
        }
        .frame(height: 130)
    }

    // MARK: - 主题信息

    private var themeInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text(theme.subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            if !isAvailable {
                HStack(spacing: 8) {
                    Button(action: onTrial) {
                        Text("theme_try")
                            .font(.caption2.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)

                    Button(action: onSelect) {
                        Text("theme_buy")
                            .font(.caption2.weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.mini)
                }
            } else if let remaining = trialRemaining {
                Text(trialTimeString(remaining))
                    .font(.caption2)
                    .foregroundStyle(.orange)
            } else if isAvailable && !isActive {
                Button(action: onSelect) {
                    Text("theme_apply")
                        .font(.caption2.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }
        }
        .padding(12)
        .background(.regularMaterial)
    }

    private func trialTimeString(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        if minutes > 0 {
            return String(localized: "theme_trial_remaining_\(minutes)")
        }
        return String(localized: "theme_trial_expired")
    }
}
