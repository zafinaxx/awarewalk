import SwiftUI
import RealityKit
import ARKit

/// Mixed Immersive Space — 在透视模式下叠加 F-35 风格透明 HUD
/// 所有元素无背景，贴在用户视野边缘，中央留空不遮挡
struct ImmersiveHUDView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = HUDViewModel()

    var body: some View {
        RealityView { content, attachments in
            setupAttachments(content: content, attachments: attachments)
        } update: { content, attachments in
            updateAttachments(content: content, attachments: attachments)
        } attachments: {
            // 顶部信息带 — 视野上方
            Attachment(id: "top-strip") {
                topStripView
                    .frame(width: 800, height: 40)
            }

            // 底部信息带 — 视野下方
            Attachment(id: "bottom-strip") {
                bottomStripView
                    .frame(width: 800, height: 50)
            }

            // 右侧迷你雷达 — 视野右下
            Attachment(id: "mini-radar") {
                radarPanel
                    .frame(width: 100, height: 120)
            }

            // 左侧威胁等级 — 视野左侧
            Attachment(id: "threat-level") {
                threatPanel
                    .frame(width: 60, height: 120)
            }

            // 导航箭头 — 地面前方
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
            do {
                await viewModel.activateHUD()
            }
        }
        .onDisappear {
            viewModel.deactivateHUD()
        }
    }

    // MARK: - 空间布局

    private func setupAttachments(content: RealityViewContent, attachments: RealityViewAttachments) {
        let s: Float = 0.001

        // 顶部带 — 视野上方 (y=0.15, z=-1.2)
        if let e = attachments.entity(for: "top-strip") {
            e.position = [0, 0.15, -1.2]
            e.scale = [s, s, s]
            content.add(e)
        }

        // 底部带 — 视野下方 (y=-0.35, z=-1.2)
        if let e = attachments.entity(for: "bottom-strip") {
            e.position = [0, -0.35, -1.2]
            e.scale = [s, s, s]
            content.add(e)
        }

        // 迷你雷达 — 右下方
        if let e = attachments.entity(for: "mini-radar") {
            e.position = [0.5, -0.2, -1.2]
            e.scale = [s, s, s]
            content.add(e)
        }

        // 威胁等级 — 左侧
        if let e = attachments.entity(for: "threat-level") {
            e.position = [-0.5, -0.1, -1.2]
            e.scale = [s, s, s]
            content.add(e)
        }

        // 导航箭头 — 前方地面
        if let e = attachments.entity(for: "nav-arrow") {
            e.position = [0, -1.0, -3.0]
            e.scale = [s * 2, s * 2, s * 2]
            content.add(e)
        }
    }

    private func updateAttachments(content: RealityViewContent, attachments: RealityViewAttachments) {
        if let e = attachments.entity(for: "nav-arrow") {
            e.isEnabled = viewModel.isNavigating
        }
    }

    // MARK: - 顶部带

    private var topStripView: some View {
        HStack(spacing: 0) {
            HStack(spacing: 12) {
                chipLabel(icon: "phone.fill", text: "0", color: .green)
                chipLabel(icon: "message.fill", text: "2", color: .blue)
                chipLabel(icon: "envelope.fill", text: "5", color: .cyan)
            }

            Spacer()

            Text(Date(), format: .dateTime.hour().minute())
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(.cyan.opacity(0.6))

            Spacer()

            HStack(spacing: 8) {
                Text("\(appState.batteryLevel)%")
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .foregroundStyle(.green.opacity(0.5))
                Image(systemName: "battery.75percent")
                    .font(.system(size: 14))
                    .foregroundStyle(.green.opacity(0.5))
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - 底部带

    private var bottomStripView: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "%.1f", viewModel.navState.speedKmh))
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(.cyan.opacity(0.7))
                Text("km/h")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(.cyan.opacity(0.35))
            }

            Spacer()

            if viewModel.isNavigating {
                HStack(spacing: 12) {
                    Image(systemName: viewModel.navState.nextManeuver.icon)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.cyan.opacity(0.8))
                    Text(viewModel.navState.formattedNextDistance)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.7))
                    Text("ETA \(viewModel.navState.formattedETA)")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.cyan.opacity(0.4))
                }
            } else {
                HStack(spacing: 8) {
                    Circle().fill(.green.opacity(0.5)).frame(width: 8, height: 8)
                    Text("SAFE")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.green.opacity(0.5))
                }
            }

            Spacer()

            if let loc = viewModel.navState.currentLocation {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.4f", loc.latitude))
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.cyan.opacity(0.35))
                    Text(String(format: "%.4f", loc.longitude))
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.cyan.opacity(0.35))
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - 迷你雷达面板

    private var radarPanel: some View {
        let pts = viewModel.radarPoints.isEmpty ? HUDCompositeView.demoPoints : viewModel.radarPoints
        return VStack(spacing: 6) {
            MiniRadar(points: pts)
            Text("\(pts.count) OBJ")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(.cyan.opacity(0.35))
        }
    }

    // MARK: - 威胁等级面板

    private var threatPanel: some View {
        let maxThreat = viewModel.radarPoints.map(\.threatLevel).max() ?? .none
        return VStack(alignment: .leading, spacing: 8) {
            threatRow("CRIT", active: maxThreat == .high, color: .red)
            threatRow("WARN", active: maxThreat >= .medium, color: .orange)
            threatRow("CAUT", active: maxThreat >= .low, color: .yellow)
            threatRow("SAFE", active: maxThreat == .none, color: .green)
        }
    }

    private func threatRow(_ label: String, active: Bool, color: Color) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(active ? color.opacity(0.6) : .gray.opacity(0.1))
                .frame(width: 4, height: 14)
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(active ? color.opacity(0.5) : .gray.opacity(0.15))
        }
    }

    // MARK: - 辅助

    private func chipLabel(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 13))
            Text(text).font(.system(size: 13, weight: .bold, design: .monospaced))
        }
        .foregroundStyle(text == "0" ? .gray.opacity(0.25) : color.opacity(0.6))
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
