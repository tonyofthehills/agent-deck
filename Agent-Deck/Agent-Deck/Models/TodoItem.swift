//
//  TodoItem.swift
//  Agent-Deck
//
//  Created by Agent Deck Team
//

import Foundation

/// Represents a single task in the agent's todo list
/// Mirrors Claude Code's TodoWrite format
struct TodoItem: Identifiable, Codable, Equatable {
    /// Unique identifier for this todo item
    let id: UUID

    /// Task description in imperative form
    /// Example: "Fix QR code hardcoded port to use dynamic port from WebSocketServer"
    let content: String

    /// Task description in present continuous form (shown during execution)
    /// Example: "Fixing QR code hardcoded port to use dynamic port from WebSocketServer"
    let activeForm: String

    /// Current status of the task
    /// Values: "pending", "in_progress", "completed"
    let status: String

    /// Initialize a new todo item
    init(id: UUID = UUID(),
         content: String,
         activeForm: String,
         status: String) {
        self.id = id
        self.content = content
        self.activeForm = activeForm
        self.status = status
    }

    /// Create dictionary representation for WebSocket messaging
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "content": content,
            "activeForm": activeForm,
            "status": status
        ]
    }

    /// Check if this task is currently active
    var isInProgress: Bool {
        return status == "in_progress"
    }

    /// Check if this task is completed
    var isCompleted: Bool {
        return status == "completed"
    }

    /// Check if this task is pending
    var isPending: Bool {
        return status == "pending"
    }
}
