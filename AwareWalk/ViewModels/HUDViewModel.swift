import SwiftUI
import Observation
import Combine

@Observable
final class HUDViewModel {
    let awarenessEngine = SpatialAwarenessEngine()
    let navigationService = NavigationService()
    let alertManager = AlertManager()

    var radarPoints: [RadarPoint] { awarenessEngine.detectedObjects }
    var alertLevel: AlertLevel { alertManager.currentLevel }
    var isNavigating: Bool { navigationService.navigationState.isActive }
    var navState: NavigationState { navigationService.navigationState }

    var isHUDActive = false
    var currentTime = Date()
    var batteryLevel = 85

    private var timer: Timer?

    // MARK: - HUD 生命周期

    func activateHUD() async {
        isHUDActive = true
        navigationService.requestPermission()
        navigationService.startLocationUpdates()

        do {
            try await awarenessEngine.start()
        } catch {
            print("空间感知启动失败: \(error)")
        }

        startTimeUpdates()
    }

    func deactivateHUD() {
        isHUDActive = false
        awarenessEngine.stop()
        navigationService.stopLocationUpdates()
        stopTimeUpdates()
    }

    // MARK: - 预警处理

    func processAlerts() {
        let level = awarenessEngine.currentAlertLevel
        guard level > .none else {
            alertManager.dismissAlert()
            return
        }

        if let closestThreat = awarenessEngine.detectedObjects
            .filter({ $0.threatLevel >= .medium })
            .min(by: { $0.distance < $1.distance }) {

            alertManager.triggerAlert(
                level: level,
                direction: Double(closestThreat.angle) * 180 / .pi,
                objectType: closestThreat.objectType,
                distance: closestThreat.distance
            )
        }
    }

    // MARK: - 导航

    func searchAndNavigate(query: String) async {
        await navigationService.searchPlaces(query: query)
    }

    // MARK: - 时间更新

    private func startTimeUpdates() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.currentTime = Date()
        }
    }

    private func stopTimeUpdates() {
        timer?.invalidate()
        timer = nil
    }
}
