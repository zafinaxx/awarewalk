import SwiftUI
import RealityKit
import ARKit

/// Mixed Immersive Space — 在透视模式下叠加 HUD 内容
struct ImmersiveHUDView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = HUDViewModel()

    var body: some View {
        RealityView { content, attachments in
            setupImmersiveContent(content: content, attachments: attachments)
        } update: { content, attachments in
            updateImmersiveContent(content: content, attachments: attachments)
        } attachments: {
            Attachment(id: "hud-overlay") {
                HUDCompositeView()
                    .environment(appState)
                    .frame(width: 600, height: 400)
            }

            Attachment(id: "nav-arrow") {
                if viewModel.isNavigating {
                    NavigationArrow3D(
                        maneuver: viewModel.navState.nextManeuver,
                        distance: viewModel.navState.nextManeuverDistance,
                        theme: appState.currentTheme
                    )
                }
            }
        }
        .task {
            await viewModel.activateHUD()
        }
        .onDisappear {
            viewModel.deactivateHUD()
        }
    }

    private func setupImmersiveContent(content: RealityViewContent, attachments: RealityViewAttachments) {
        // HUD 叠层 — 固定在用户视野前方偏下
        if let hudEntity = attachments.entity(for: "hud-overlay") {
            hudEntity.position = [0, -0.3, -1.5]
            hudEntity.scale = [0.001, 0.001, 0.001]
            content.add(hudEntity)
        }

        // 导航箭头 — 在地面上显示方向
        if let arrowEntity = attachments.entity(for: "nav-arrow") {
            arrowEntity.position = [0, -1.0, -3.0]
            arrowEntity.scale = [0.002, 0.002, 0.002]
            content.add(arrowEntity)
        }
    }

    private func updateImmersiveContent(content: RealityViewContent, attachments: RealityViewAttachments) {
        // 随用户头部移动更新 HUD 位置
        if let arrowEntity = attachments.entity(for: "nav-arrow") {
            arrowEntity.isEnabled = viewModel.isNavigating
        }
    }
}

/// 3D 导航箭头 — 显示在前方地面上
struct NavigationArrow3D: View {
    let maneuver: NavigationManeuver
    let distance: Double
    let theme: HUDTheme

    @State private var bounce: CGFloat = 0

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: maneuver.icon)
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(theme.accentGradient)
                .shadow(color: theme.primaryColor.opacity(0.5), radius: 20)
                .offset(y: bounce)

            Text(formattedDistance)
                .font(.system(size: 24, weight: .bold, design: theme.fontDesign.swiftUIDesign))
                .foregroundStyle(theme.textPrimaryColor)
                .shadow(color: .black.opacity(0.5), radius: 4)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                bounce = -10
            }
        }
    }

    private var formattedDistance: String {
        if distance >= 1000 {
            return String(format: "%.1f km", distance / 1000)
        }
        return String(format: "%.0f m", distance)
    }
}
