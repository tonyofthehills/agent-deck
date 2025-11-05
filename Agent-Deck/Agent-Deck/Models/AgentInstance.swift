//
//  AgentInstance.swift
//  Agent-Deck
//
//  Created by Agent Deck Team
//

import Foundation

/// Represents a running AI coding agent process being monitored
/// Spec: data-model.md Entity 1
struct AgentInstance: Identifiable, Codable {
    /// Unique identifier for this agent instance
    let id: UUID

    /// Process ID from macOS
    let pid: pid_t

    /// Agent type identifier (e.g., "claude-code")
    let agentType: String

    /// Current working directory path (absolute path)
    let workingDirectory: String

    /// Current agent status
    var status: AgentStatus

    /// Parsed task description from stdout (max 200 chars, nullable)
    var currentTask: String?

    /// Timestamp of last status change (ISO 8601)
    var lastActivityTimestamp: Date

    /// macOS window ID for focus switching (optional in Phase 1-2)
    var windowIdentifier: String?

    /// Current git branch for the working directory (nullable if not a git repo)
    var gitBranch: String?

    // MARK: - Rich Transcript Data (Phase 2+)

    /// Model name being used by the agent
    /// Example: "Sonnet 4.5", "GPT-4", "Claude 3 Opus"
    var modelName: String?

    /// Currently running subagent tasks
    /// Populated from transcript data when subagents are active
    var activeSubagents: [SubagentInfo]

    /// Full todo list with statuses
    /// Populated from transcript data when TodoWrite is used
    var todos: [TodoItem]

    /// Description of the current in-progress task
    /// Typically the activeForm of the in_progress todo item
    /// Example: "Fixing QR code hardcoded port to use dynamic port from WebSocketServer"
    var currentTaskDescription: String?

    /// Initialize a new agent instance
    init(id: UUID = UUID(),
         pid: pid_t,
         agentType: String,
         workingDirectory: String,
         status: AgentStatus = .idle,
         currentTask: String? = nil,
         lastActivityTimestamp: Date = Date(),
         windowIdentifier: String? = nil,
         gitBranch: String? = nil,
         modelName: String? = nil,
         activeSubagents: [SubagentInfo] = [],
         todos: [TodoItem] = [],
         currentTaskDescription: String? = nil) {
        self.id = id
        self.pid = pid
        self.agentType = agentType
        self.workingDirectory = workingDirectory
        self.status = status
        self.currentTask = currentTask
        self.lastActivityTimestamp = lastActivityTimestamp
        self.windowIdentifier = windowIdentifier
        self.gitBranch = gitBranch
        self.modelName = modelName
        self.activeSubagents = activeSubagents
        self.todos = todos
        self.currentTaskDescription = currentTaskDescription
    }

    /// Create dictionary representation for WebSocket messaging
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "pid": Int(pid),
            "agentType": agentType,
            "workingDirectory": workingDirectory,
            "status": status.rawValue,
            "lastActivityTimestamp": ISO8601DateFormatter().string(from: lastActivityTimestamp)
        ]

        // Optional basic fields
        if let task = currentTask {
            dict["currentTask"] = task
        }

        if let window = windowIdentifier {
            dict["windowIdentifier"] = window
        }

        if let branch = gitBranch {
            dict["gitBranch"] = branch
        }

        // Rich transcript data fields
        if let model = modelName {
            dict["modelName"] = model
        }

        if let taskDesc = currentTaskDescription {
            dict["currentTaskDescription"] = taskDesc
        }

        // Subagents array
        if !activeSubagents.isEmpty {
            dict["activeSubagents"] = activeSubagents.map { $0.toDictionary() }
        }

        // Todos array
        if !todos.isEmpty {
            dict["todos"] = todos.map { $0.toDictionary() }
        }

        return dict
    }
}
