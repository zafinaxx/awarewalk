import SwiftUI

/// F-35 风格透明 HUD 叠层
/// 完全透明背景，信息贴在视野边缘，中央留空不遮挡
/// 字体已做人眼适配：行走中余光即可读取，不需要聚焦
struct HUDCompositeView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = HUDViewModel()

    var isLive: Bool = true

    private var points: [RadarPoint] {
        viewModel.radarPoints.isEmpty ? Self.demoPoints : viewModel.radarPoints
    }

    var body: some View {
        ZStack {
            Color.clear

            GeometryReader { geo in
                targetBrackets(in: geo.size)
            }

            VStack(spacing: 0) {
                topEdge
                Spacer()
                bottomEdge
            }
            .padding(24)

            HStack(spacing: 0) {
                leftEdge
                Spacer()
                rightEdge
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 80)

            threatDirectionIndicators
            boresight
        }
        .task {
            if isLive { await viewModel.activateHUD() }
        }
        .onDisappear {
            if isLive { viewModel.deactivateHUD() }
        }
    }

    // MARK: - 中央准星

    private var boresight: some View {
        ZStack {
            Rectangle()
                .fill(.cyan.opacity(0.12))
                .frame(width: 28, height: 1.5)
            Rectangle()
                .fill(.cyan.opacity(0.12))
                .frame(width: 1.5, height: 28)
            Circle()
                .stroke(.cyan.opacity(0.15), lineWidth: 1)
                .frame(width: 14, height: 14)
        }
    }

    // MARK: - 四角瞄准框

    private func targetBrackets(in size: CGSize) -> some View {
        let len: CGFloat = 36
        let thick: CGFloat = 2
        let pad: CGFloat = 10
        let color: Color = .cyan.opacity(0.25)

        return ZStack {
            bracketPath(x: pad, y: pad, dx: len, dy: len).stroke(color, lineWidth: thick)
            bracketPath(x: size.width - pad, y: pad, dx: -len, dy: len).stroke(color, lineWidth: thick)
            bracketPath(x: pad, y: size.height - pad, dx: len, dy: -len).stroke(color, lineWidth: thick)
            bracketPath(x: size.width - pad, y: size.height - pad, dx: -len, dy: -len).stroke(color, lineWidth: thick)
        }
    }

    private func bracketPath(x: CGFloat, y: CGFloat, dx: CGFloat, dy: CGFloat) -> Path {
        Path { p in
            p.move(to: CGPoint(x: x + dx, y: y))
            p.addLine(to: CGPoint(x: x, y: y))
            p.addLine(to: CGPoint(x: x, y: y + dy))
        }
    }

    // MARK: - 顶部边缘

    private var topEdge: some View {
        HStack(spacing: 0) {
            HStack(spacing: 12) {
                notifBadge(icon: "phone.fill", count: 0, color: .green)
                notifBadge(icon: "message.fill", count: 2, color: .blue)
                notifBadge(icon: "envelope.fill", count: 5, color: .cyan)
            }

            Spacer()

            headingTape

            Spacer()

            HStack(spacing: 12) {
                Text(Date(), format: .dateTime.hour().minute())
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.cyan.opacity(0.6))
                Text("·")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(.cyan.opacity(0.3))
                HStack(spacing: 5) {
                    Text("\(appState.batteryLevel)%")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.green.opacity(0.6))
                    Image(systemName: "battery.75percent")
                        .font(.system(size: 13))
                        .foregroundStyle(.green.opacity(0.5))
                }
            }
        }
    }

    private func notifBadge(icon: String, count: Int, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 13))
            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
            }
        }
        .foregroundStyle(count > 0 ? color.opacity(0.7) : .gray.opacity(0.25))
    }

    private var headingTape: some View {
        let heading = Int(viewModel.navState.currentHeading)
        let compassDir = compassDirection(for: heading)
        return HStack(spacing: 8) {
            Text("‹ \((heading - 30 + 360) % 360)°")
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(.cyan.opacity(0.3))
            Text("— \(compassDir) \(heading)° —")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(.cyan.opacity(0.6))
            Text("\((heading + 30) % 360)° ›")
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(.cyan.opacity(0.3))
        }
    }

    // MARK: - 底部边缘

    private var bottomEdge: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "%.1f", viewModel.navState.speedKmh))
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(.cyan.opacity(0.7))
                Text("km/h")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(.cyan.opacity(0.35))
            }

            Spacer()

            if viewModel.isNavigating {
                navPrompt
            } else {
                statusChip
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if let loc = viewModel.navState.currentLocation {
                    Text(String(format: "%.4f", loc.latitude))
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.cyan.opacity(0.35))
                    Text(String(format: "%.4f", loc.longitude))
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.cyan.opacity(0.35))
                } else {
                    Text("---.----")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.cyan.opacity(0.25))
                    Text("---.----")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(.cyan.opacity(0.25))
                }
            }
        }
    }

    private var navPrompt: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.navState.nextManeuver.icon)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.cyan.opacity(0.8))
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.navState.formattedNextDistance)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))
                if !viewModel.navState.nextStreetName.isEmpty {
                    Text(viewModel.navState.nextStreetName)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(.cyan.opacity(0.4))
                        .lineLimit(1)
                }
            }
            Text("ETA \(viewModel.navState.formattedETA)")
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundStyle(.cyan.opacity(0.4))
        }
    }

    private var statusChip: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(.green.opacity(0.6))
                .frame(width: 8, height: 8)
            Text("SAFE")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(.green.opacity(0.5))
        }
    }

    // MARK: - 左侧：威胁等级

    private var leftEdge: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()

            ForEach(["CRIT", "WARN", "CAUT", "SAFE"], id: \.self) { level in
                let active = isLevelActive(level)
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(active ? levelColor(level).opacity(0.7) : .gray.opacity(0.1))
                        .frame(width: 4, height: 14)
                    Text(level)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(active ? levelColor(level).opacity(0.6) : .gray.opacity(0.15))
                }
            }

            Spacer()
        }
        .frame(width: 70)
    }

    // MARK: - 右侧：雷达 + 物体计数

    private var rightEdge: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Spacer()

            MiniRadar(points: points)

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(points.count)")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(.cyan.opacity(0.5))
                Text("OBJ")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.cyan.opacity(0.3))
            }

            Spacer()
        }
        .frame(width: 100)
    }

    // MARK: - 威胁方向指示器

    private var threatDirectionIndicators: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let rx = geo.size.width / 2 - 50
            let ry = geo.size.height / 2 - 50

            ForEach(points.filter { $0.threatLevel >= .medium }) { point in
                let rad = Double(point.angle) - .pi / 2
                let x = center.x + cos(rad) * rx
                let y = center.y + sin(rad) * ry

                VStack(spacing: 3) {
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: 14))
                    Text(String(format: "%.0fm", point.distance))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                .foregroundStyle(point.threatLevel == .high ? .red.opacity(0.7) : .orange.opacity(0.6))
                .rotationEffect(.degrees(Double(point.angle) * 180 / .pi))
                .position(x: x, y: y)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - 辅助

    private func compassDirection(for heading: Int) -> String {
        let dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let idx = Int(round(Double(heading) / 45)) % 8
        return dirs[idx]
    }

    private func isLevelActive(_ name: String) -> Bool {
        let maxThreat = points.map(\.threatLevel).max() ?? .none
        switch name {
        case "CRIT": return maxThreat == .high
        case "WARN": return maxThreat >= .medium
        case "CAUT": return maxThreat >= .low
        case "SAFE": return maxThreat == .none
        default: return false
        }
    }

    private func levelColor(_ name: String) -> Color {
        switch name {
        case "CRIT": return .red
        case "WARN": return .orange
        case "CAUT": return .yellow
        default: return .green
        }
    }

    static let demoPoints: [RadarPoint] = [
        RadarPoint(objectType: .vehicle, relativePosition: [8, 0, -12],
                   distance: 14, angle: -0.6, velocity: 2.0, threatLevel: .medium),
        RadarPoint(objectType: .pedestrian, relativePosition: [-3, 0, -5],
                   distance: 6, angle: 2.5, velocity: 0.5, threatLevel: .none),
        RadarPoint(objectType: .bicycle, relativePosition: [4, 0, -7],
                   distance: 8, angle: -0.5, velocity: 1.5, threatLevel: .low),
        RadarPoint(objectType: .obstacle, relativePosition: [0, 0, -3],
                   distance: 3, angle: 0.1, velocity: 0, threatLevel: .low),
    ]
}

// MARK: - 迷你雷达

struct MiniRadar: View {
    let points: [RadarPoint]
    private let size: CGFloat = 88

    @State private var sweep: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(.cyan.opacity(0.15), lineWidth: 1)
            Circle()
                .stroke(.cyan.opacity(0.08), lineWidth: 0.5)
                .frame(width: size * 0.5, height: size * 0.5)
            Path { p in
                p.move(to: CGPoint(x: size / 2, y: 0))
                p.addLine(to: CGPoint(x: size / 2, y: size))
                p.move(to: CGPoint(x: 0, y: size / 2))
                p.addLine(to: CGPoint(x: size, y: size / 2))
            }
            .stroke(.cyan.opacity(0.06), lineWidth: 0.5)

            Rectangle()
                .fill(.cyan.opacity(0.12))
                .frame(width: 1, height: size / 2)
                .offset(y: -size / 4)
                .rotationEffect(.degrees(sweep))

            ForEach(points) { pt in
                let x = size / 2 + CGFloat(sin(pt.angle)) * CGFloat(pt.normalizedDistance) * size / 2 * 0.85
                let y = size / 2 - CGFloat(cos(pt.angle)) * CGFloat(pt.normalizedDistance) * size / 2 * 0.85
                Circle()
                    .fill(pt.objectType.color.opacity(0.7))
                    .frame(width: 5, height: 5)
                    .position(x: x, y: y)
            }

            Circle()
                .fill(.cyan.opacity(0.5))
                .frame(width: 3, height: 3)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                sweep = 360
            }
        }
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
