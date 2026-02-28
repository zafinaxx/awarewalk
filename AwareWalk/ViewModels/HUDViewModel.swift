import SwiftUI
import Observation

@MainActor
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

    @ObservationIgnored
    private var timerTask: Task<Void, Never>?

    // MARK: - HUD 生命周期

    func activateHUD() async {
        isHUDActive = true
        print("[AwareWalk] HUD ViewModel 激活中...")

        navigationService.requestPermission()
        navigationService.startLocationUpdates()

        do {
            try await awarenessEngine.start()
            print("[AwareWalk] 空间感知引擎已启动 (isRunning: \(awarenessEngine.isRunning))")
        } catch {
            print("[AwareWalk] 空间感知启动失败（不影响 HUD 显示）: \(error)")
        }

        startTimeUpdates()
        print("[AwareWalk] HUD ViewModel 激活完成")
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
        timerTask = Task {
            while !Task.isCancelled {
                currentTime = Date()
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    private func stopTimeUpdates() {
        timerTask?.cancel()
        timerTask = nil
    }
}
