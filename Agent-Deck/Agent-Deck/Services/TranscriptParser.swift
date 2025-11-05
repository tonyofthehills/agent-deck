//
//  TranscriptParser.swift
//  Agent-Deck
//
//  Rich transcript parser - extracts structured data from Claude Code JSONL transcripts
//  Parses: modelName, activeSubagents (Task tool), todos (TodoWrite), currentTask
//  Spec: tasks.md, data-model.md
//

import Foundation

// MARK: - Data Models

/// Complete parsed transcript data
/// Note: SubagentInfo and TodoItem are defined in Models/
struct TranscriptData: Equatable {
    var modelName: String?
    var activeSubagents: [SubagentInfo]
    var todos: [TodoItem]
    var currentTask: String?
    var workingDirectory: String?

    init(modelName: String? = nil,
         activeSubagents: [SubagentInfo] = [],
         todos: [TodoItem] = [],
         currentTask: String? = nil,
         workingDirectory: String? = nil) {
        self.modelName = modelName
        self.activeSubagents = activeSubagents
        self.todos = todos
        self.currentTask = currentTask
        self.workingDirectory = workingDirectory
    }
}

/// Service for parsing Claude Code transcript JSONL files
class TranscriptParser {

    init() {
        Logger.info("TranscriptParser initialized", log: Logger.monitoring)
    }

    /// Parse entire transcript file and return extracted data
    /// - Parameter path: Absolute path to transcript.jsonl file
    /// - Returns: Parsed transcript data or nil if file cannot be read
    func parseTranscript(path: String) -> TranscriptData? {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            Logger.error("Failed to read transcript file: \(path)", log: Logger.monitoring)
            return nil
        }

        var data = TranscriptData()

        // Extract model name (usually appears early in transcript)
        data.modelName = extractModelName(from: content)

        // Extract working directory (from "cwd" field)
        data.workingDirectory = extractWorkingDirectory(from: content)

        // Extract subagents from Task tool calls
        data.activeSubagents = extractSubagents(from: content)

        // Extract todos from TodoWrite tool calls
        data.todos = extractTodos(from: content)

        // Get current task (first in_progress todo)
        data.currentTask = getCurrentTask(from: data.todos)

        return data
    }

    /// Parse model name from transcript
    /// Converts technical model IDs to friendly names
    /// - Parameter jsonl: JSONL content
    /// - Returns: Friendly model name or nil
    func extractModelName(from jsonl: String) -> String? {
        let lines = jsonl.split(separator: "\n")

        for line in lines {
            guard let data = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let message = json["message"] as? [String: Any],
                  let model = message["model"] as? String else {
                continue
            }

            return convertModelToFriendlyName(model)
        }

        return nil
    }

    /// Extract working directory from transcript
    /// - Parameter jsonl: JSONL content
    /// - Returns: Working directory path or nil
    func extractWorkingDirectory(from jsonl: String) -> String? {
        let lines = jsonl.split(separator: "\n")

        for line in lines {
            guard let data = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let cwd = json["cwd"] as? String else {
                continue
            }

            return cwd
        }

        return nil
    }

    /// Parse active subagents from tool_use blocks with name="Task"
    /// - Parameter jsonl: JSONL content
    /// - Returns: Array of SubagentInfo
    func extractSubagents(from jsonl: String) -> [SubagentInfo] {
        var subagents: [SubagentInfo] = []
        let lines = jsonl.split(separator: "\n")

        for line in lines {
            guard let data = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let message = json["message"] as? [String: Any],
                  let content = message["content"] as? [[String: Any]] else {
                continue
            }

            // Check each content item for Task tool use
            for item in content {
                guard item["type"] as? String == "tool_use",
                      item["name"] as? String == "Task",
                      let input = item["input"] as? [String: Any] else {
                    continue
                }

                // Extract Task subagent information
                let description = input["description"] as? String ?? "Unknown task"

                // Create SubagentInfo using existing model initializer
                let subagent = SubagentInfo(
                    description: description,
                    status: "running",
                    startedAt: Date()
                )

                subagents.append(subagent)
            }
        }

        return subagents
    }

    /// Parse todos from TodoWrite tool calls
    /// - Parameter jsonl: JSONL content
    /// - Returns: Array of TodoItem
    func extractTodos(from jsonl: String) -> [TodoItem] {
        var allTodos: [TodoItem] = []
        let lines = jsonl.split(separator: "\n")

        for line in lines {
            guard let data = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let message = json["message"] as? [String: Any],
                  let content = message["content"] as? [[String: Any]] else {
                continue
            }

            // Check each content item for TodoWrite tool use
            for item in content {
                guard item["type"] as? String == "tool_use",
                      item["name"] as? String == "TodoWrite",
                      let input = item["input"] as? [String: Any],
                      let todos = input["todos"] as? [[String: Any]] else {
                    continue
                }

                // Parse each todo from the TodoWrite call
                for todoDict in todos {
                    let content = todoDict["content"] as? String ?? ""
                    let status = todoDict["status"] as? String ?? "pending"
                    let activeForm = todoDict["activeForm"] as? String ?? content

                    // Create TodoItem using existing model initializer
                    let todo = TodoItem(
                        content: content,
                        activeForm: activeForm,
                        status: status
                    )

                    allTodos.append(todo)
                }
            }
        }

        // Return only the most recent TodoWrite (last occurrence)
        // Transcript may contain multiple TodoWrite calls as todos update
        return getLatestTodos(from: allTodos)
    }

    /// Get current task (first in_progress todo)
    /// - Parameter todos: Array of TodoItem
    /// - Returns: Current task description or nil
    func getCurrentTask(from todos: [TodoItem]) -> String? {
        // Find first todo with status "in_progress"
        let inProgressTodo = todos.first { $0.status == "in_progress" }

        // Return activeForm for better display ("Creating..." vs "Create...")
        return inProgressTodo?.activeForm
    }

    // MARK: - Private Helper Methods

    /// Convert technical model ID to friendly name
    /// - Parameter model: Raw model ID (e.g., "claude-sonnet-4-5-20250929")
    /// - Returns: Friendly name (e.g., "Sonnet 4.5")
    private func convertModelToFriendlyName(_ model: String) -> String {
        // Match common Claude model patterns
        if model.contains("sonnet") {
            if model.contains("4-5") || model.contains("4.5") {
                return "Sonnet 4.5"
            } else if model.contains("3-5") || model.contains("3.5") {
                return "Sonnet 3.5"
            } else if model.contains("3-7") || model.contains("3.7") {
                return "Sonnet 3.7"
            }
            return "Sonnet"
        } else if model.contains("opus") {
            return "Opus"
        } else if model.contains("haiku") {
            return "Haiku"
        }

        // Return original if no match
        return model
    }

    /// Get latest todos (deduplicate by content, keeping most recent)
    /// - Parameter todos: All parsed todos
    /// - Returns: Deduplicated todos (latest version of each)
    /// Note: We deduplicate by content, not ID, because each TodoWrite creates new IDs
    private func getLatestTodos(from todos: [TodoItem]) -> [TodoItem] {
        var latestTodos: [String: TodoItem] = [:]

        // Iterate in order - later items will overwrite earlier ones
        for todo in todos {
            latestTodos[todo.content] = todo
        }

        // Convert back to array
        return Array(latestTodos.values)
    }
}

// MARK: - Edge Case Handling & Safety

extension TranscriptParser {
    /// Parse transcript with comprehensive error handling
    /// - Parameter path: Absolute path to transcript file
    /// - Returns: TranscriptData (empty if parsing fails completely)
    func parseTranscriptSafe(path: String) -> TranscriptData {
        guard let data = parseTranscript(path: path) else {
            // Return empty data if file doesn't exist or is unreadable
            Logger.error("parseTranscriptSafe: Failed to parse, returning empty data", log: Logger.monitoring)
            return TranscriptData()
        }

        return data
    }

    /// Validate transcript file format
    /// - Parameter path: Absolute path to transcript file
    /// - Returns: True if file appears to be valid JSONL
    func isValidTranscript(path: String) -> Bool {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return false
        }

        let lines = content.split(separator: "\n")
        guard !lines.isEmpty else {
            return false
        }

        // Check if first line is valid JSON
        guard let firstLine = lines.first,
              let data = firstLine.data(using: .utf8),
              let _ = try? JSONSerialization.jsonObject(with: data) else {
            return false
        }

        return true
    }
}

// MARK: - Array Extension

extension Array where Element: Equatable {
    /// Remove duplicates from array while maintaining order
    func removingDuplicates() -> [Element] {
        var result: [Element] = []
        for element in self {
            if !result.contains(element) {
                result.append(element)
            }
        }
        return result
    }
}
