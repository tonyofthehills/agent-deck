//
//  SubagentInfo.swift
//  Agent-Deck
//
//  Created by Agent Deck Team
//

import Foundation

/// Represents a subagent task spawned by the main agent
/// Used to display active parallel tasks in the UI
struct SubagentInfo: Identifiable, Codable, Equatable {
    /// Unique identifier for this subagent
    let id: UUID

    /// Human-readable description of what this subagent is doing
    /// Example: "Fix QR code port passing", "Search documentation for Convex patterns"
    let description: String

    /// Current status of the subagent
    /// Values: "running", "completed", "failed"
    let status: String

    /// When this subagent was started
    let startedAt: Date

    /// Initialize a new subagent info
    init(id: UUID = UUID(),
         description: String,
         status: String = "running",
         startedAt: Date = Date()) {
        self.id = id
        self.description = description
        self.status = status
        self.startedAt = startedAt
    }

    /// Create dictionary representation for WebSocket messaging
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "description": description,
            "status": status,
            "startedAt": ISO8601DateFormatter().string(from: startedAt)
        ]
    }
}
