import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "eye.trianglebadge.exclamationmark",
            titleKey: "onboarding_welcome_title",
            subtitleKey: "onboarding_welcome_subtitle",
            gradient: [.blue, .cyan]
        ),
        OnboardingPage(
            icon: "radar",
            titleKey: "onboarding_radar_title",
            subtitleKey: "onboarding_radar_subtitle",
            gradient: [.green, .mint]
        ),
        OnboardingPage(
            icon: "exclamationmark.triangle.fill",
            titleKey: "onboarding_alert_title",
            subtitleKey: "onboarding_alert_subtitle",
            gradient: [.orange, .red]
        ),
        OnboardingPage(
            icon: "map.fill",
            titleKey: "onboarding_nav_title",
            subtitleKey: "onboarding_nav_subtitle",
            gradient: [.purple, .indigo]
        ),
        OnboardingPage(
            icon: "paintpalette.fill",
            titleKey: "onboarding_theme_title",
            subtitleKey: "onboarding_theme_subtitle",
            gradient: [.pink, .purple]
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            bottomBar
        }
        .background(.ultraThinMaterial)
        .frame(width: 500, height: 600)
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 72))
                .foregroundStyle(.linearGradient(
                    colors: page.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .symbolEffect(.pulse, options: .repeating)

            VStack(spacing: 12) {
                Text(LocalizedStringKey(page.titleKey))
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)

                Text(LocalizedStringKey(page.subtitleKey))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
    }

    private var bottomBar: some View {
        HStack {
            if currentPage > 0 {
                Button("onboarding_back") {
                    withAnimation { currentPage -= 1 }
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            if currentPage < pages.count - 1 {
                Button("onboarding_next") {
                    withAnimation { currentPage += 1 }
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("onboarding_start") {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding(24)
    }
}

struct OnboardingPage {
    let icon: String
    let titleKey: String
    let subtitleKey: String
    let gradient: [Color]
}
