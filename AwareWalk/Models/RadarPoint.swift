import SwiftUI
import simd

struct RadarPoint: Identifiable {
    let id = UUID()
    var objectType: DetectedObjectType
    var relativePosition: SIMD3<Float>
    var distance: Float
    var angle: Float
    var velocity: Float
    var threatLevel: ThreatLevel
    var lastUpdated: Date = .now

    var normalizedAngle: Double {
        Double(angle) / (2 * .pi)
    }

    var normalizedDistance: Double {
        min(Double(distance) / 30.0, 1.0)
    }
}

enum DetectedObjectType: String, CaseIterable {
    case pedestrian
    case bicycle
    case vehicle
    case obstacle
    case unknown

    var color: Color {
        switch self {
        case .pedestrian: .green
        case .bicycle: .cyan
        case .vehicle: .red
        case .obstacle: .orange
        case .unknown: .gray
        }
    }

    var icon: String {
        switch self {
        case .pedestrian: "figure.walk"
        case .bicycle: "bicycle"
        case .vehicle: "car.fill"
        case .obstacle: "exclamationmark.triangle"
        case .unknown: "questionmark.circle"
        }
    }

    var displaySize: CGFloat {
        switch self {
        case .pedestrian: 6
        case .bicycle: 7
        case .vehicle: 10
        case .obstacle: 8
        case .unknown: 5
        }
    }
}

enum ThreatLevel: Int, Comparable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3

    static func < (lhs: ThreatLevel, rhs: ThreatLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
