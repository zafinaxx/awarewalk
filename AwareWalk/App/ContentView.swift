import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    @State private var showOnboarding = false
    @State private var isToggling = false
    @State private var showError = false
    @State private var errorText = ""

    var body: some View {
        ZStack {
            if appState.isHUDActive {
                fullScreenHUD
            } else {
                launchCard
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showOnboarding) {
            OnboardingView()
        }
        .alert("AwareWalk", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorText)
        }
        .onAppear {
            if !UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                showOnboarding = true
            }
        }
    }

    // MARK: - 启动页

    private var launchCard: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 36)

            VStack(spacing: 16) {
                Image(systemName: "eye")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.cyan, .blue, .purple],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .symbolEffect(.breathe, options: .repeating)

                Text("AwareWalk")
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text("hud_subtitle")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 32)

            GuardianEyeButton(isToggling: isToggling) {
                toggleHUD()
            }

            Spacer(minLength: 24)

            HStack(spacing: 16) {
                StatusPill(icon: "location.fill", label: "GPS", isActive: true)
                StatusPill(icon: "antenna.radiowaves.left.and.right",
                           label: String(localized: "status_radar"),
                           isActive: appState.radarEnabled)
                StatusPill(icon: "bell.fill",
                           label: String(localized: "status_alerts"),
                           isActive: appState.soundEnabled)
            }

            Spacer(minLength: 36)
        }
        .padding(.horizontal, 44)
        .frame(width: 540, height: 560)
        .glassBackgroundEffect()
        .ornament(attachmentAnchor: .scene(.bottom)) {
            launchToolbar
                .glassBackgroundEffect()
        }
    }

    private var launchToolbar: some View {
        HStack(spacing: 6) {
            ToolbarButton(icon: "paintpalette.fill",
                          label: String(localized: "action_themes")) {
                openWindow(id: "theme-gallery")
            }
            ToolbarButton(icon: "map.fill",
                          label: String(localized: "action_navigate")) {
                appState.isNavigating.toggle()
            }
            ToolbarButton(icon: "gearshape.fill",
                          label: String(localized: "action_settings")) {
                openWindow(id: "settings")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - 全屏 HUD

    private var fullScreenHUD: some View {
        ZStack {
            Color.clear

            HUDCompositeView(isLive: false)
                .environment(appState)

            VStack {
                HStack {
                    Spacer()
                    hudControlChip
                }
                Spacer()
            }
            .padding(24)
        }
        .ornament(attachmentAnchor: .scene(.bottom)) {
            activeToolbar
                .glassBackgroundEffect()
        }
    }

    private var hudControlChip: some View {
        Button {
            toggleHUD()
        } label: {
            HStack(spacing: 6) {
                Circle().fill(.green).frame(width: 6, height: 6)
                Text("HUD")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.green.opacity(0.7))
                if isToggling {
                    ProgressView().controlSize(.mini)
                } else {
                    Image(systemName: "power")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.red.opacity(0.6))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: .capsule)
        }
        .buttonStyle(.plain)
        .disabled(isToggling)
        .opacity(0.8)
    }

    private var activeToolbar: some View {
        HStack(spacing: 6) {
            ToolbarButton(icon: "paintpalette.fill",
                          label: String(localized: "action_themes")) {
                openWindow(id: "theme-gallery")
            }
            ToolbarButton(icon: "map.fill",
                          label: String(localized: "action_navigate")) {
                appState.isNavigating.toggle()
            }
            ToolbarButton(icon: "gearshape.fill",
                          label: String(localized: "action_settings")) {
                openWindow(id: "settings")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - HUD 切换

    private func toggleHUD() {
        guard !isToggling else { return }
        Task {
            isToggling = true
            defer { isToggling = false }

            if appState.isHUDActive {
                await dismissImmersiveSpace()
                appState.isHUDActive = false
            } else {
                let result = await openImmersiveSpace(id: "hud-space")
                switch result {
                case .opened:
                    appState.isHUDActive = true
                case .error:
                    errorText = String(localized: "hud_error_message")
                    showError = true
                case .userCancelled:
                    errorText = String(localized: "hud_cancelled_message")
                    showError = true
                @unknown default:
                    break
                }
            }
        }
    }
}

// MARK: - ============================================================
// MARK:   守护之眼按钮 — 与 App 图标统一的高端设计
// MARK: - ============================================================

struct GuardianEyeButton: View {
    let isToggling: Bool
    let action: () -> Void

    @State private var glowPulse: CGFloat = 0.7
    @State private var orbBreath: CGFloat = 0.85
    @State private var shimmer: CGFloat = 0.3
    @State private var rayRotation: Double = 0

    private let W: CGFloat = 220
    private let H: CGFloat = 110

    // 完全复刻图标色彩
    private static let cyan    = Color(red: 0.30, green: 0.78, blue: 0.98)
    private static let blue    = Color(red: 0.28, green: 0.48, blue: 0.98)
    private static let purple  = Color(red: 0.52, green: 0.25, blue: 0.88)
    private static let rose    = Color(red: 0.76, green: 0.55, blue: 0.50)
    private static let gold    = Color(red: 0.90, green: 0.68, blue: 0.18)
    private static let dkGold  = Color(red: 0.65, green: 0.42, blue: 0.08)

    var body: some View {
        VStack(spacing: 16) {
            Button(action: action) {
                ZStack {
                    softGlow
                    glassBody
                    frameStroke
                    roseGoldTrim
                    irisDisk
                    irisSubtleRings
                    goldenRays
                    goldenSphere
                    walkIcon
                    glassSheen
                }
                .frame(width: W + 44, height: H + 56)
            }
            .buttonStyle(.plain)
            .disabled(isToggling)
            .accessibilityLabel("Activate HUD")

            Text("hud_start")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .onAppear { animate() }
    }

    // MARK: - 1. 外层柔光（呼吸）
    private var softGlow: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [
                        Self.cyan.opacity(glowPulse * 0.22),
                        Self.blue.opacity(glowPulse * 0.10),
                        Color.clear
                    ],
                    center: .center, startRadius: 20, endRadius: W * 0.6
                )
            )
            .frame(width: W + 40, height: H + 40)
            .blur(radius: 18)
    }

    // MARK: - 2. 玻璃填充体（高饱和，和图标一致）
    private var glassBody: some View {
        EyeShape()
            .fill(
                LinearGradient(
                    colors: [
                        Self.cyan.opacity(0.72),
                        Self.blue.opacity(0.65),
                        Self.purple.opacity(0.70)
                    ],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .frame(width: W, height: H)
    }

    // MARK: - 3. 粗边框渐变描边（图标同款）
    private var frameStroke: some View {
        EyeShape()
            .stroke(
                LinearGradient(
                    colors: [Self.cyan, Self.blue, Self.purple],
                    startPoint: .leading, endPoint: .trailing
                ),
                lineWidth: 6
            )
            .frame(width: W, height: H)
    }

    // MARK: - 4. 玫瑰金外边缘
    private var roseGoldTrim: some View {
        EyeShape()
            .stroke(Self.rose.opacity(0.65), lineWidth: 2)
            .frame(width: W + 8, height: H + 5)
    }

    // MARK: - 5. 青色虹膜圆盘（大面积，和图标一样）
    private var irisDisk: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Self.cyan.opacity(0.50),
                        Self.blue.opacity(0.35),
                        Self.cyan.opacity(0.15),
                        Color.clear
                    ],
                    center: .center, startRadius: 8, endRadius: 48
                )
            )
            .frame(width: 90, height: 90)
    }

    // MARK: - 6. 虹膜淡环（只有 2-3 圈，不杂乱）
    private var irisSubtleRings: some View {
        ZStack {
            Circle()
                .stroke(Self.cyan.opacity(0.25), lineWidth: 1.2)
                .frame(width: 72, height: 72)
            Circle()
                .stroke(Self.blue.opacity(0.18), lineWidth: 0.8)
                .frame(width: 52, height: 52)
        }
    }

    // MARK: - 7. 金色光芒（从球体放射，图标有这个）
    private var goldenRays: some View {
        ForEach(0..<8, id: \.self) { i in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Self.gold.opacity(0.4), Color.clear],
                        startPoint: .center, endPoint: .leading
                    )
                )
                .frame(width: 32, height: 1)
                .offset(x: 18)
                .rotationEffect(.degrees(Double(i) * 45 + rayRotation))
        }
    }

    // MARK: - 8. 金色球体（大、立体、3D 高光）
    private var goldenSphere: some View {
        ZStack {
            goldenSphereGlow
            goldenSphereBody
            goldenSphereHighlight
        }
    }

    private var goldenSphereGlow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Self.gold.opacity(orbBreath * 0.6),
                        Self.gold.opacity(0.15),
                        Color.clear
                    ],
                    center: .center, startRadius: 6, endRadius: 40
                )
            )
            .frame(width: 60, height: 60)
    }

    private var goldenSphereBody: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.92),
                        Self.gold,
                        Self.dkGold,
                        Self.dkGold.opacity(0.8)
                    ],
                    center: UnitPoint(x: 0.35, y: 0.28),
                    startRadius: 0, endRadius: 20
                )
            )
            .frame(width: 34, height: 34)
            .shadow(color: Self.gold.opacity(0.65), radius: 14, y: 2)
    }

    private var goldenSphereHighlight: some View {
        Circle()
            .fill(Color.white.opacity(0.85))
            .frame(width: 8, height: 8)
            .offset(x: -5, y: -6)
    }

    // MARK: - 9. 行走图标
    private var walkIcon: some View {
        Group {
            if isToggling {
                ProgressView()
                    .controlSize(.regular)
                    .tint(.white)
            } else {
                Image(systemName: "figure.walk.motion")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color.white.opacity(0.9))
                    .shadow(color: Self.gold, radius: 4)
            }
        }
    }

    // MARK: - 10. 顶部玻璃光泽（镜面反射）
    private var glassSheen: some View {
        EyeShape()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(shimmer * 0.50),
                        Color.white.opacity(shimmer * 0.15),
                        Color.clear
                    ],
                    startPoint: .top, endPoint: .center
                )
            )
            .frame(width: W - 16, height: H * 0.40)
            .offset(y: -(H * 0.20))
            .allowsHitTesting(false)
    }

    private func animate() {
        withAnimation(.easeInOut(duration: 2.5).repeatForever()) { glowPulse = 1.0 }
        withAnimation(.easeInOut(duration: 2.0).repeatForever()) { orbBreath = 1.0 }
        withAnimation(.easeInOut(duration: 3.0).repeatForever()) { shimmer = 0.8 }
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) { rayRotation = 360 }
    }
}

/// 眼睛形状（尖端更锐利，和图标一致）
struct EyeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let midX = rect.midX
        let midY = rect.midY

        path.move(to: CGPoint(x: rect.minX, y: midY))
        // 上半弧
        path.addCurve(
            to: CGPoint(x: midX, y: rect.minY + h * 0.05),
            control1: CGPoint(x: rect.minX + w * 0.06, y: midY - h * 0.44),
            control2: CGPoint(x: midX - w * 0.24, y: rect.minY)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: midY),
            control1: CGPoint(x: midX + w * 0.24, y: rect.minY),
            control2: CGPoint(x: rect.maxX - w * 0.06, y: midY - h * 0.44)
        )
        // 下半弧
        path.addCurve(
            to: CGPoint(x: midX, y: rect.maxY - h * 0.05),
            control1: CGPoint(x: rect.maxX - w * 0.06, y: midY + h * 0.44),
            control2: CGPoint(x: midX + w * 0.24, y: rect.maxY)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX, y: midY),
            control1: CGPoint(x: midX - w * 0.24, y: rect.maxY),
            control2: CGPoint(x: rect.minX + w * 0.06, y: midY + h * 0.44)
        )
        return path
    }
}

// MARK: - 状态胶囊

struct StatusPill: View {
    let icon: String
    let label: String
    let isActive: Bool
    var tint: Color = .blue
    private var activeColor: Color { tint == .blue ? .green : tint }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.caption)
            Text(label).font(.subheadline.weight(.medium))
        }
        .foregroundStyle(isActive ? activeColor : .secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(
            isActive
                ? AnyShapeStyle(activeColor.opacity(0.1))
                : AnyShapeStyle(Color.secondary.opacity(0.06)),
            in: .capsule
        )
    }
}

// MARK: - 工具栏按钮

struct ToolbarButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.title3)
                Text(label).font(.caption)
            }
            .frame(width: 76, height: 54)
        }
        .buttonStyle(.borderless)
    }
}
