import SwiftUI
import MapKit
import CoreLocation

struct NavigationState {
    var isActive = false
    var destination: CLLocationCoordinate2D?
    var destinationName: String = ""
    var currentLocation: CLLocationCoordinate2D?
    var currentHeading: Double = 0
    var distanceRemaining: Double = 0
    var estimatedTimeMinutes: Int = 0
    var nextManeuver: NavigationManeuver = .straight
    var nextManeuverDistance: Double = 0
    var nextStreetName: String = ""
    var routePolyline: [CLLocationCoordinate2D] = []
    var speedKmh: Double = 0

    var formattedDistance: String {
        if distanceRemaining >= 1000 {
            return String(format: "%.1f km", distanceRemaining / 1000)
        }
        return String(format: "%.0f m", distanceRemaining)
    }

    var formattedNextDistance: String {
        if nextManeuverDistance >= 1000 {
            return String(format: "%.1f km", nextManeuverDistance / 1000)
        }
        return String(format: "%.0f m", nextManeuverDistance)
    }

    var formattedETA: String {
        if estimatedTimeMinutes >= 60 {
            let hours = estimatedTimeMinutes / 60
            let mins = estimatedTimeMinutes % 60
            return "\(hours)h \(mins)min"
        }
        return "\(estimatedTimeMinutes) min"
    }
}

enum NavigationManeuver: String, CaseIterable {
    case straight
    case slightLeft
    case slightRight
    case turnLeft
    case turnRight
    case sharpLeft
    case sharpRight
    case uTurn
    case arrive

    var icon: String {
        switch self {
        case .straight: "arrow.up"
        case .slightLeft: "arrow.up.left"
        case .slightRight: "arrow.up.right"
        case .turnLeft: "arrow.turn.up.left"
        case .turnRight: "arrow.turn.up.right"
        case .sharpLeft: "arrow.turn.down.left"
        case .sharpRight: "arrow.turn.down.right"
        case .uTurn: "arrow.uturn.down"
        case .arrive: "mappin.circle.fill"
        }
    }

    var localizedLabel: String {
        switch self {
        case .straight: String(localized: "nav_straight")
        case .slightLeft: String(localized: "nav_slight_left")
        case .slightRight: String(localized: "nav_slight_right")
        case .turnLeft: String(localized: "nav_turn_left")
        case .turnRight: String(localized: "nav_turn_right")
        case .sharpLeft: String(localized: "nav_sharp_left")
        case .sharpRight: String(localized: "nav_sharp_right")
        case .uTurn: String(localized: "nav_u_turn")
        case .arrive: String(localized: "nav_arrive")
        }
    }
}
