import SwiftUI
import MapKit
import CoreLocation
import Observation

@Observable
final class NavigationService: NSObject, CLLocationManagerDelegate {
    @ObservationIgnored
    private let locationManager = CLLocationManager()
    @ObservationIgnored
    private var currentRoute: MKRoute?

    var navigationState = NavigationState()
    var searchResults: [MKMapItem] = []
    var isSearching = false
    var locationAuthorized = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
    }

    // MARK: - 位置权限

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }

    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - 搜索

    func searchPlaces(query: String) async {
        isSearching = true
        defer { isSearching = false }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        if let location = locationManager.location {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 5000,
                longitudinalMeters: 5000
            )
        }

        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            searchResults = response.mapItems
        } catch {
            searchResults = []
        }
    }

    // MARK: - 导航

    func startNavigation(to destination: MKMapItem) async throws {
        guard let currentLocation = locationManager.location else {
            throw NavigationError.locationUnavailable
        }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation.coordinate))
        request.destination = destination
        request.transportType = .walking

        let directions = MKDirections(request: request)
        let response = try await directions.calculate()

        guard let route = response.routes.first else {
            throw NavigationError.routeNotFound
        }

        currentRoute = route
        navigationState.isActive = true
        navigationState.destination = destination.placemark.coordinate
        navigationState.destinationName = destination.name ?? ""
        navigationState.distanceRemaining = route.distance
        navigationState.estimatedTimeMinutes = Int(route.expectedTravelTime / 60)
        navigationState.routePolyline = extractCoordinates(from: route.polyline)

        updateNextManeuver()
        startLocationUpdates()
    }

    func stopNavigation() {
        navigationState = NavigationState()
        currentRoute = nil
        stopLocationUpdates()
    }

    // MARK: - 路线处理

    private func extractCoordinates(from polyline: MKPolyline) -> [CLLocationCoordinate2D] {
        let count = polyline.pointCount
        var coords = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(), count: count)
        polyline.getCoordinates(&coords, range: NSRange(location: 0, length: count))
        return coords
    }

    private func updateNextManeuver() {
        guard let route = currentRoute else { return }

        if let step = route.steps.first(where: { $0.distance > 10 }) {
            navigationState.nextManeuverDistance = step.distance
            navigationState.nextStreetName = step.instructions
            navigationState.nextManeuver = mapManeuver(from: step)
        }
    }

    private func mapManeuver(from step: MKRoute.Step) -> NavigationManeuver {
        let instruction = step.instructions.lowercased()
        if instruction.contains("left") || instruction.contains("左") {
            return instruction.contains("slight") ? .slightLeft : .turnLeft
        }
        if instruction.contains("right") || instruction.contains("右") {
            return instruction.contains("slight") ? .slightRight : .turnRight
        }
        if instruction.contains("arrive") || instruction.contains("到达") {
            return .arrive
        }
        return .straight
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        navigationState.currentLocation = location.coordinate
        navigationState.speedKmh = max(0, location.speed * 3.6)

        if navigationState.isActive {
            updateDistanceAndETA(from: location)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthorized = manager.authorizationStatus == .authorizedWhenInUse ||
                            manager.authorizationStatus == .authorizedAlways
    }

    private func updateDistanceAndETA(from location: CLLocation) {
        guard let destination = navigationState.destination else { return }
        let destLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        navigationState.distanceRemaining = location.distance(from: destLocation)

        let speed = max(location.speed, 1.2) // 最低步行速度 1.2 m/s
        navigationState.estimatedTimeMinutes = Int(navigationState.distanceRemaining / speed / 60)

        if navigationState.distanceRemaining < 15 {
            navigationState.nextManeuver = .arrive
        }
    }
}

enum NavigationError: Error, LocalizedError {
    case locationUnavailable
    case routeNotFound

    var errorDescription: String? {
        switch self {
        case .locationUnavailable: "无法获取当前位置"
        case .routeNotFound: "未找到步行路线"
        }
    }
}
