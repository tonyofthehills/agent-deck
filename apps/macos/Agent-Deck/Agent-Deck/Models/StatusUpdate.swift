//
//  StatusUpdate.swift
//  Agent-Deck
//
//  Created by Agent Deck Team
//

import Foundation

/// Real-time event message broadcast via WebSocket to mobile clients
/// Spec: data-model.md Entity 3, contracts/websocket-protocol.md
struct StatusUpdate: Codable {
    /// Message type identifier
    let type: MessageType

    /// Event timestamp (ISO 8601)
    let timestamp: Date

    /// Reference to AgentInstance (required for "update" type)
    let instanceId: UUID?

    /// New status value (required for "update" type)
    let status: AgentStatus?

    /// Current task description (max 200 chars, nullable)
    let currentTask: String?

    /// Additional event data (optional per event type)
    let metadata: [String: String]?

    /// Full instance object (for instance_added type)
    let instance: AgentInstance?

    /// Reason for instance removal (for instance_removed type)
    let reason: String?

    /// Error code (for focus_failure type)
    let error: String?

    /// Error message (for focus_failure type)
    let message: String?

    /// Server version (for initial_state type)
    let serverVersion: String?

    /// List of instances (for initial_state type)
    let instances: [AgentInstance]?

    enum MessageType: String, Codable {
        case initialState = "initial_state"
        case update = "update"
        case instanceAdded = "instance_added"
        case instanceRemoved = "instance_removed"
        case focusSuccess = "focus_success"
        case focusFailure = "focus_failure"
        case pong = "pong"
        case error = "error"
    }

    /// Create status update message
    static func update(instanceId: UUID, status: AgentStatus, currentTask: String?) -> StatusUpdate {
        StatusUpdate(
            type: .update,
            timestamp: Date(),
            instanceId: instanceId,
            status: status,
            currentTask: currentTask,
            metadata: nil,
            instance: nil,
            reason: nil,
            error: nil,
            message: nil,
            serverVersion: nil,
            instances: nil
        )
    }

    /// Create instance added message
    static func instanceAdded(_ instance: AgentInstance) -> StatusUpdate {
        StatusUpdate(
            type: .instanceAdded,
            timestamp: Date(),
            instanceId: nil,
            status: nil,
            currentTask: nil,
            metadata: nil,
            instance: instance,
            reason: nil,
            error: nil,
            message: nil,
            serverVersion: nil,
            instances: nil
        )
    }

    /// Create instance removed message
    static func instanceRemoved(instanceId: UUID, reason: String = "process_terminated") -> StatusUpdate {
        StatusUpdate(
            type: .instanceRemoved,
            timestamp: Date(),
            instanceId: instanceId,
            status: nil,
            currentTask: nil,
            metadata: nil,
            instance: nil,
            reason: reason,
            error: nil,
            message: nil,
            serverVersion: nil,
            instances: nil
        )
    }

    /// Create initial state message
    static func initialState(instances: [AgentInstance], serverVersion: String = "1.0.0") -> StatusUpdate {
        StatusUpdate(
            type: .initialState,
            timestamp: Date(),
            instanceId: nil,
            status: nil,
            currentTask: nil,
            metadata: nil,
            instance: nil,
            reason: nil,
            error: nil,
            message: nil,
            serverVersion: serverVersion,
            instances: instances
        )
    }

    /// Create focus success message
    static func focusSuccess(instanceId: UUID) -> StatusUpdate {
        StatusUpdate(
            type: .focusSuccess,
            timestamp: Date(),
            instanceId: instanceId,
            status: nil,
            currentTask: nil,
            metadata: nil,
            instance: nil,
            reason: nil,
            error: nil,
            message: nil,
            serverVersion: nil,
            instances: nil
        )
    }

    /// Create focus failure message
    static func focusFailure(instanceId: UUID, error: String, message: String) -> StatusUpdate {
        StatusUpdate(
            type: .focusFailure,
            timestamp: Date(),
            instanceId: instanceId,
            status: nil,
            currentTask: nil,
            metadata: nil,
            instance: nil,
            reason: nil,
            error: error,
            message: message,
            serverVersion: nil,
            instances: nil
        )
    }

    /// Create pong message
    static func pong() -> StatusUpdate {
        StatusUpdate(
            type: .pong,
            timestamp: Date(),
            instanceId: nil,
            status: nil,
            currentTask: nil,
            metadata: nil,
            instance: nil,
            reason: nil,
            error: nil,
            message: nil,
            serverVersion: nil,
            instances: nil
        )
    }

    /// Convert to JSON data for WebSocket transmission
    func toJSONData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try encoder.encode(self)
    }
}
