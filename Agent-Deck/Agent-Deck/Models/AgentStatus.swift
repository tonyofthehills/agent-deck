//
//  AgentStatus.swift
//  Agent-Deck
//
//  Created by Agent Deck Team
//

import Foundation

/// Enumeration of possible agent states displayed on mobile UI
/// Spec: data-model.md Entity 2
enum AgentStatus: String, Codable, CaseIterable {
    case idle = "idle"       // Agent waiting for user input - Gray (#888888)
    case working = "working" // Agent actively processing task - Blue (#0066CC)
    case done = "done"       // Agent completed all tasks - Green (#00AA00)
    case error = "error"     // Agent encountered error - Red (#CC0000)

    /// Display color for UI rendering
    var displayColor: String {
        switch self {
        case .idle: return "#888888"
        case .working: return "#0066CC"
        case .done: return "#00AA00"
        case .error: return "#CC0000"
        }
    }

    /// UI icon suggestion
    var icon: String {
        switch self {
        case .idle: return "⏸️"
        case .working: return "⚙️"
        case .done: return "✅"
        case .error: return "⚠️"
        }
    }
}
