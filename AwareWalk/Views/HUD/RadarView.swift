import SwiftUI

/// 360 度雷达环 — 显示周围物体方位和距离
struct RadarView: View {
    let points: [RadarPoint]
    let theme: HUDTheme
    let size: CGFloat

    @State private var sweepAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0

    private var ringCount: Int { theme.radarRingCount }

    var body: some View {
        ZStack {
            radarBackground
            radarRings
            directionMarkers
            if theme.radarSweepEnabled {
                sweepLine
            }
            objectDots
            centerDot
        }
        .frame(width: size, height: size)
        .onAppear {
            if theme.radarSweepEnabled {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    sweepAngle = 360
                }
            }
            withAnimation(.easeInOut(duration: 2).repeatForever()) {
                pulseScale = 1.1
            }
        }
    }

    // MARK: - 背景

    private var radarBackground: some View {
        Circle()
            .fill(theme.backgroundColor.opacity(theme.glassOpacity))
            .overlay(
                Circle()
                    .stroke(theme.primaryColor.opacity(0.3), lineWidth: theme.borderWidth)
            )
    }

    // MARK: - 距离环

    private var radarRings: some View {
        ForEach(1...ringCount, id: \.self) { ring in
            Circle()
                .stroke(
                    theme.primaryColor.opacity(0.15),
                    style: StrokeStyle(
                        lineWidth: 0.5,
                        dash: theme.radarStyle == .tactical ? [4, 4] : []
                    )
                )
                .frame(
                    width: size * CGFloat(ring) / CGFloat(ringCount),
                    height: size * CGFloat(ring) / CGFloat(ringCount)
                )
        }
    }

    // MARK: - 方向标记

    private var directionMarkers: some View {
        ForEach(Array(["N", "E", "S", "W"].enumerated()), id: \.offset) { index, label in
            let angle = Double(index) * 90 - 90
            let radius = size / 2 - 12

            Text(label)
                .font(.system(size: 9, weight: .bold, design: theme.fontDesign.swiftUIDesign))
                .foregroundStyle(theme.textSecondaryColor)
                .position(
                    x: size / 2 + CGFloat(cos(angle * .pi / 180)) * radius,
                    y: size / 2 + CGFloat(sin(angle * .pi / 180)) * radius
                )
        }
    }

    // MARK: - 扫描线

    private var sweepLine: some View {
        SweepShape()
            .fill(
                AngularGradient(
                    stops: [
                        .init(color: theme.primaryColor.opacity(0), location: 0),
                        .init(color: theme.primaryColor.opacity(0.3), location: 0.8),
                        .init(color: theme.primaryColor.opacity(0.6), location: 1),
                    ],
                    center: .center,
                    startAngle: .degrees(sweepAngle - 60),
                    endAngle: .degrees(sweepAngle)
                )
            )
            .mask(Circle())
    }

    // MARK: - 物体点

    private var objectDots: some View {
        ForEach(points) { point in
            let x = size / 2 + CGFloat(sin(point.angle)) * CGFloat(point.normalizedDistance) * size / 2 * 0.85
            let y = size / 2 - CGFloat(cos(point.angle)) * CGFloat(point.normalizedDistance) * size / 2 * 0.85

            Circle()
                .fill(point.objectType.color)
                .frame(width: point.objectType.displaySize, height: point.objectType.displaySize)
                .shadow(color: point.objectType.color.opacity(0.8), radius: 4)
                .scaleEffect(point.threatLevel >= .medium ? pulseScale : 1.0)
                .position(x: x, y: y)
        }
    }

    // MARK: - 中心点

    private var centerDot: some View {
        ZStack {
            Circle()
                .fill(theme.accentColor)
                .frame(width: 6, height: 6)
            if theme.radarStyle == .kawaii {
                Text("🐾")
                    .font(.system(size: 10))
            }
        }
    }
}

struct SweepShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.midY))
            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.midY),
                radius: max(rect.width, rect.height) / 2,
                startAngle: .degrees(-60),
                endAngle: .degrees(0),
                clockwise: false
            )
            path.closeSubpath()
        }
    }
}
