import SwiftUI

/// 单个主题族购买页
struct ThemePurchaseSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let family: ThemeStyleFamily

    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    previewSection
                    featuresSection
                    purchaseButton
                }
                .padding(24)
            }
            .navigationTitle(family.displayName)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: family.icon)
                .font(.system(size: 56))
                .foregroundStyle(.linearGradient(
                    colors: familyGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            Text(family.displayName)
                .font(.title.weight(.bold))

            Text("theme_family_description_\(family.rawValue)")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var previewSection: some View {
        let themes = appState.themeManager.themes(for: family)
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(themes) { theme in
                    ThemePreviewMini(theme: theme)
                }
            }
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("theme_includes")
                .font(.headline)

            FeatureRow(icon: "paintpalette.fill", text: String(localized: "theme_feature_colors"))
            FeatureRow(icon: "textformat", text: String(localized: "theme_feature_fonts"))
            FeatureRow(icon: "radar", text: String(localized: "theme_feature_radar"))
            FeatureRow(icon: "wand.and.stars", text: String(localized: "theme_feature_animations"))
            FeatureRow(icon: "arrow.triangle.2.circlepath", text: String(localized: "theme_feature_updates"))
        }
        .padding(20)
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }

    private var purchaseButton: some View {
        Button {
            Task {
                isPurchasing = true
                let productID = SubscriptionManager.themeFamilyPrefix + family.rawValue
                let success = await appState.subscriptionManager.purchaseByID(productID)
                if success {
                    appState.themeManager.purchaseFamily(family)
                }
                isPurchasing = false
                if success { dismiss() }
            }
        } label: {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("theme_purchase_\(family.price.description)")
                        .font(.title3.weight(.bold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .disabled(isPurchasing)
    }

    private var familyGradientColors: [Color] {
        let themes = appState.themeManager.themes(for: family)
        guard let first = themes.first else { return [.blue, .purple] }
        return [first.primaryColor, first.accentColor]
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct ThemePreviewMini: View {
    let theme: HUDTheme

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .fill(theme.backgroundColor)
                .overlay(
                    VStack(spacing: 4) {
                        Circle()
                            .stroke(theme.primaryColor.opacity(0.5), lineWidth: 1)
                            .frame(width: 30, height: 30)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.primaryColor.opacity(0.3))
                            .frame(width: 60, height: 12)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .stroke(theme.primaryColor.opacity(0.3), lineWidth: theme.borderWidth)
                )
                .frame(width: 100, height: 140)

            Text(theme.name)
                .font(.caption2.weight(.medium))
                .lineLimit(1)
        }
    }
}

/// Pro 订阅页 — 解锁全部主题
struct ProSubscriptionSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var purchaseInProgress: String?
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    crownHeader
                    benefitsList
                    pricingOptions
                    termsLinks
                }
                .padding(24)
            }
            .navigationTitle("pro_title")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { dismiss() }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .task {
                await appState.subscriptionManager.loadProducts()
            }
        }
    }

    private var crownHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 56))
                .foregroundStyle(.linearGradient(
                    colors: [.yellow, .orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            Text("AwareWalk Pro")
                .font(.largeTitle.weight(.bold))

            Text("pro_subtitle")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var benefitsList: some View {
        VStack(alignment: .leading, spacing: 14) {
            ProBenefit(icon: "paintpalette.fill", title: String(localized: "pro_all_themes"), desc: String(localized: "pro_all_themes_desc"))
            ProBenefit(icon: "radar", title: String(localized: "pro_advanced_radar"), desc: String(localized: "pro_advanced_radar_desc"))
            ProBenefit(icon: "bell.badge.fill", title: String(localized: "pro_smart_alerts"), desc: String(localized: "pro_smart_alerts_desc"))
            ProBenefit(icon: "map.fill", title: String(localized: "pro_multi_maps"), desc: String(localized: "pro_multi_maps_desc"))
            ProBenefit(icon: "arrow.up.circle.fill", title: String(localized: "pro_priority_updates"), desc: String(localized: "pro_priority_updates_desc"))
        }
        .padding(20)
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }

    private var pricingOptions: some View {
        VStack(spacing: 12) {
            PricingCard(
                title: String(localized: "price_monthly"),
                price: "$2.99",
                period: String(localized: "price_per_month"),
                isPopular: false
            ) {
                purchaseProduct(SubscriptionManager.monthlyID)
            }

            PricingCard(
                title: String(localized: "price_yearly"),
                price: "$12.99",
                period: String(localized: "price_per_year"),
                isPopular: true,
                badge: String(localized: "price_save_30")
            ) {
                purchaseProduct(SubscriptionManager.yearlyID)
            }

            PricingCard(
                title: String(localized: "price_lifetime"),
                price: "$12.99",
                period: String(localized: "price_once"),
                isPopular: false
            ) {
                purchaseProduct(SubscriptionManager.unlockID)
            }

            Button {
                Task { await appState.subscriptionManager.restorePurchases() }
            } label: {
                Text("price_restore")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
        }
    }

    private var termsLinks: some View {
        VStack(spacing: 8) {
            Text("Subscriptions auto-renew unless cancelled 24h before period end. Manage in Settings > Apple ID > Subscriptions.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Privacy Policy", destination: URL(string: "https://zafinaxx.github.io/awarewalk/privacy/")!)
                Link("Terms of Use", destination: URL(string: "https://zafinaxx.github.io/awarewalk/terms/")!)
            }
            .font(.caption2)
        }
        .padding(.top, 8)
    }

    private func purchaseProduct(_ productID: String) {
        guard purchaseInProgress == nil else { return }
        purchaseInProgress = productID
        Task {
            let success = await appState.subscriptionManager.purchaseByID(productID)
            purchaseInProgress = nil
            if success {
                dismiss()
            } else if let error = appState.subscriptionManager.purchaseError {
                errorMessage = error
                showError = true
            }
        }
    }
}

struct ProBenefit: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(desc).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct PricingCard: View {
    let title: String
    let price: String
    let period: String
    let isPopular: Bool
    var badge: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                        if let badge {
                            Text(badge)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.orange, in: .capsule)
                        }
                    }
                    Text(period)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(price)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isPopular ? .orange : .primary)
            }
            .padding(16)
            .background(isPopular ? Color.orange.opacity(0.1) : .clear)
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isPopular ? .orange : .secondary.opacity(0.3), lineWidth: isPopular ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
