import SwiftUI
import ARKit
import RealityKit
import Observation

/// 空间感知引擎 — 使用 SceneReconstruction 检测周边物体并评估威胁
@Observable
final class SpatialAwarenessEngine {
    private var session: ARKitSession?
    private var sceneReconstruction: SceneReconstructionProvider?
    private var worldTracking: WorldTrackingProvider?

    var detectedObjects: [RadarPoint] = []
    var currentAlertLevel: AlertLevel = .none
    var isRunning = false
    var environmentMeshAnchors: [MeshAnchor] = []

    // 扫描参数
    var scanRadius: Float = 30.0
    var updateInterval: TimeInterval = 0.1

    // MARK: - 生命周期

    func start() async throws {
        let session = ARKitSession()
        self.session = session

        let sceneReconstruction = SceneReconstructionProvider()
        let worldTracking = WorldTrackingProvider()
        self.sceneReconstruction = sceneReconstruction
        self.worldTracking = worldTracking

        guard SceneReconstructionProvider.isSupported,
              WorldTrackingProvider.isSupported else {
            throw AwarenessError.notSupported
        }

        try await session.run([sceneReconstruction, worldTracking])
        isRunning = true

        await processSceneUpdates()
    }

    func stop() {
        session?.stop()
        isRunning = false
        detectedObjects.removeAll()
        currentAlertLevel = .none
    }

    // MARK: - 场景更新处理

    private func processSceneUpdates() async {
        guard let sceneReconstruction else { return }

        for await update in sceneReconstruction.anchorUpdates {
            switch update.event {
            case .added, .updated:
                processMeshAnchor(update.anchor)
            case .removed:
                removeMeshAnchor(update.anchor)
            }

            evaluateThreats()
        }
    }

    private func processMeshAnchor(_ anchor: MeshAnchor) {
        if let index = environmentMeshAnchors.firstIndex(where: { $0.id == anchor.id }) {
            environmentMeshAnchors[index] = anchor
        } else {
            environmentMeshAnchors.append(anchor)
        }

        analyzeEnvironmentChanges(anchor)
    }

    private func removeMeshAnchor(_ anchor: MeshAnchor) {
        environmentMeshAnchors.removeAll { $0.id == anchor.id }
    }

    // MARK: - 环境分析

    /// 通过网格变化检测移动物体
    private func analyzeEnvironmentChanges(_ anchor: MeshAnchor) {
        let transform = anchor.originFromAnchorTransform
        let position = SIMD3<Float>(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)

        let distance = length(position)
        guard distance <= scanRadius else { return }

        let angle = atan2(position.x, position.z)
        let objectType = classifyObject(anchor: anchor, distance: distance)
        let velocity = estimateVelocity(for: anchor)
        let threat = assessThreat(type: objectType, distance: distance, velocity: velocity)

        let radarPoint = RadarPoint(
            objectType: objectType,
            relativePosition: position,
            distance: distance,
            angle: angle,
            velocity: velocity,
            threatLevel: threat
        )

        updateRadarPoint(radarPoint)
    }

    /// 基于网格特征分类物体
    private func classifyObject(anchor: MeshAnchor, distance: Float) -> DetectedObjectType {
        let geometry = anchor.geometry
        let vertexCount = geometry.vertices.count

        // 简化版分类 — 实际应使用 CoreML 模型
        if vertexCount > 5000 {
            return .vehicle
        } else if vertexCount > 1000 {
            return .obstacle
        } else if vertexCount > 200 {
            return .pedestrian
        } else {
            return .unknown
        }
    }

    private func estimateVelocity(for anchor: MeshAnchor) -> Float {
        // 通过比较前后帧的位置变化估算速度
        // 实际实现需要维护历史帧数据
        return 0
    }

    private func assessThreat(type: DetectedObjectType, distance: Float, velocity: Float) -> ThreatLevel {
        let timeToContact = velocity > 0.1 ? distance / velocity : Float.infinity

        switch type {
        case .vehicle:
            if timeToContact < 3 { return .high }
            if distance < 10 { return .medium }
            return .low
        case .bicycle:
            if timeToContact < 2 { return .high }
            if distance < 5 { return .medium }
            return .low
        case .pedestrian:
            if distance < 2 { return .low }
            return .none
        case .obstacle:
            if distance < 3 { return .medium }
            if distance < 5 { return .low }
            return .none
        case .unknown:
            return .none
        }
    }

    // MARK: - 雷达数据管理

    private func updateRadarPoint(_ point: RadarPoint) {
        if let index = detectedObjects.firstIndex(where: {
            abs($0.angle - point.angle) < 0.2 && abs($0.distance - point.distance) < 2
        }) {
            detectedObjects[index] = point
        } else {
            detectedObjects.append(point)
        }

        cleanupStalePoints()
    }

    private func cleanupStalePoints() {
        let cutoff = Date().addingTimeInterval(-2)
        detectedObjects.removeAll { $0.lastUpdated < cutoff }
    }

    // MARK: - 威胁评估

    private func evaluateThreats() {
        let maxThreat = detectedObjects.map(\.threatLevel).max() ?? .none

        currentAlertLevel = switch maxThreat {
        case .none: .none
        case .low: .info
        case .medium: .caution
        case .high: detectedObjects.contains(where: { $0.distance < 3 }) ? .critical : .warning
        }
    }
}

enum AwarenessError: Error, LocalizedError {
    case notSupported
    case sessionFailed

    var errorDescription: String? {
        switch self {
        case .notSupported: "此设备不支持空间感知功能"
        case .sessionFailed: "ARKit 会话启动失败"
        }
    }
}
