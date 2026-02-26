import SwiftUI
import AVFoundation
import Observation

@MainActor
@Observable
final class AlertManager {
    var currentLevel: AlertLevel = .none
    var alertDirection: Double = 0
    var alertMessage: String = ""
    var isAlertVisible = false

    @ObservationIgnored
    private var audioPlayer: AVAudioPlayer?
    @ObservationIgnored
    private var alertCooldown: [AlertLevel: Date] = [:]
    @ObservationIgnored
    private let cooldownIntervals: [AlertLevel: TimeInterval] = [
        .info: 10,
        .caution: 5,
        .warning: 2,
        .critical: 0.5
    ]

    // MARK: - 触发预警

    func triggerAlert(level: AlertLevel, direction: Double, objectType: DetectedObjectType, distance: Float) {
        guard level > .none else {
            dismissAlert()
            return
        }

        if let lastTrigger = alertCooldown[level],
           Date().timeIntervalSince(lastTrigger) < (cooldownIntervals[level] ?? 1) {
            return
        }

        currentLevel = level
        alertDirection = direction
        alertMessage = buildAlertMessage(type: objectType, distance: distance, direction: direction)
        isAlertVisible = true
        alertCooldown[level] = Date()

        playAlertSound(for: level)
        scheduleAutoDismiss(for: level)
    }

    func dismissAlert() {
        withAnimation(.easeOut(duration: 0.3)) {
            isAlertVisible = false
        }
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            self?.currentLevel = .none
            self?.alertMessage = ""
        }
    }

    // MARK: - 预警消息构建

    private func buildAlertMessage(type: DetectedObjectType, distance: Float, direction: Double) -> String {
        let directionText = localizedDirection(angle: direction)
        let distanceText = String(format: "%.0fm", distance)

        let objectText: String = switch type {
        case .vehicle: String(localized: "alert_vehicle")
        case .bicycle: String(localized: "alert_bicycle")
        case .pedestrian: String(localized: "alert_pedestrian")
        case .obstacle: String(localized: "alert_obstacle")
        case .unknown: String(localized: "alert_object")
        }

        return "\(directionText) \(distanceText) - \(objectText)"
    }

    private func localizedDirection(angle: Double) -> String {
        let normalized = ((angle.truncatingRemainder(dividingBy: 360)) + 360)
            .truncatingRemainder(dividingBy: 360)

        return switch normalized {
        case 0..<22.5, 337.5..<360: String(localized: "dir_front")
        case 22.5..<67.5: String(localized: "dir_front_right")
        case 67.5..<112.5: String(localized: "dir_right")
        case 112.5..<157.5: String(localized: "dir_back_right")
        case 157.5..<202.5: String(localized: "dir_back")
        case 202.5..<247.5: String(localized: "dir_back_left")
        case 247.5..<292.5: String(localized: "dir_left")
        case 292.5..<337.5: String(localized: "dir_front_left")
        default: String(localized: "dir_unknown")
        }
    }

    // MARK: - 音效

    private func playAlertSound(for level: AlertLevel) {
        guard let soundName = level.soundName,
              let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            return
        }

        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.volume = level.hapticIntensity
        audioPlayer?.play()
    }

    private func scheduleAutoDismiss(for level: AlertLevel) {
        let duration: TimeInterval = switch level {
        case .none: 0
        case .info: 3
        case .caution: 4
        case .warning: 5
        case .critical: 8
        }

        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(duration))
            if self?.currentLevel == level {
                self?.dismissAlert()
            }
        }
    }
}
