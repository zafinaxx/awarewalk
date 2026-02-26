import SwiftUI

/// 预警叠层 — 根据威胁等级在视野边缘显示不同强度的警告效果
struct AlertOverlay: View {
    let level: AlertLevel
    let direction: Double
    let message: String
    let theme: HUDTheme
    let isVisible: Bool

    @State private var pulseOpacity: Double = 0.5
    @State private var glowIntensity: Double = 0

    var body: some View {
        ZStack {
            if isVisible && level > .none {
                borderGlow
                directionIndicator
                alertBanner
            }
        }
        .allowsHitTesting(false)
        .onChange(of: level) {
            startPulse()
        }
        .onAppear {
            startPulse()
        }
    }

    // MARK: - 边框光效

    private var borderGlow: some View {
        RoundedRectangle(cornerRadius: 40)
            .stroke(
                alertColor.opacity(pulseOpacity * level.borderOpacity),
                lineWidth: glowWidth
            )
            .blur(radius: 15)
            .ignoresSafeArea()
    }

    private var glowWidth: CGFloat {
        switch level {
        case .none: 0
        case .info: 2
        case .caution: 4
        case .warning: 8
        case .critical: 16
        }
    }

    // MARK: - 方向指示器

    private var directionIndicator: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2 - 30
            let radians = (direction - 90) * .pi / 180
            let x = center.x + cos(radians) * radius
            let y = center.y + sin(radians) * radius

            DirectionArrow(level: level, theme: theme)
                .position(x: x, y: y)
                .rotationEffect(.degrees(direction))
                .opacity(level >= .caution ? 1 : 0)
        }
    }

    // MARK: - 预警横幅

    private var alertBanner: some View {
        VStack {
            if level >= .caution {
                HStack(spacing: 10) {
                    Image(systemName: level.icon)
                        .font(.title3.weight(.bold))
                    Text(message)
                        .font(.system(.subheadline, design: theme.fontDesign.swiftUIDesign, weight: .semibold))
                }
                .foregroundStyle(alertTextColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(alertColor.opacity(0.85))
                .clipShape(.capsule)
                .shadow(color: alertColor.opacity(0.5), radius: 10)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            Spacer()
        }
        .padding(.top, 60)
        .animation(.spring(response: 0.4), value: level)
    }

    // MARK: - 颜色

    private var alertColor: Color {
        theme.alertColor(level)
    }

    private var alertTextColor: Color {
        level == .caution ? .black : .white
    }

    // MARK: - 动画

    private func startPulse() {
        guard level > .none else {
            pulseOpacity = 0
            return
        }

        withAnimation(
            .easeInOut(duration: level.pulseSpeed)
            .repeatForever(autoreverses: true)
        ) {
            pulseOpacity = 1.0
        }
    }
}

struct DirectionArrow: View {
    let level: AlertLevel
    let theme: HUDTheme

    @State private var scale: CGFloat = 0.8

    var body: some View {
        Image(systemName: "arrowtriangle.up.fill")
            .font(.system(size: arrowSize))
            .foregroundStyle(theme.alertColor(level))
            .shadow(color: theme.alertColor(level).opacity(0.8), radius: 8)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                    scale = 1.2
                }
            }
    }

    private var arrowSize: CGFloat {
        switch level {
        case .none, .info: 12
        case .caution: 18
        case .warning: 24
        case .critical: 32
        }
    }
}
