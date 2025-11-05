//
//  OutputParser.swift
//  Agent-Deck
//
//  OutputParser service - parses stdout from Claude Code to extract current task
//  Spec: tasks.md T041.1-T041.7, User Story 1 basic parsing
//

import Foundation

/// Service responsible for parsing agent stdout to extract task information
/// Phase 1-2: Basic parsing (current task with "Currently:" prefix)
/// Phase 3+: Advanced parsing (todo list, status line)
class OutputParser {
    /// Regex pattern for matching "Currently:" prefix
    /// Example: "Currently: Implementing authentication tests"
    private let currentlyPattern = try! NSRegularExpression(
        pattern: "^Currently:\\s*(.+)$",
        options: [.caseInsensitive]
    )

    /// Parse stdout line and extract current task if present
    /// Task: T041.2-T041.3
    /// - Parameter line: Single line of stdout from agent
    /// - Returns: Task description if "Currently:" prefix found, nil otherwise
    func parseCurrentTask(from line: String) -> String? {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

        // Match "Currently:" pattern
        let range = NSRange(trimmedLine.startIndex..., in: trimmedLine)
        guard let match = currentlyPattern.firstMatch(in: trimmedLine, range: range) else {
            return nil
        }

        // Extract task description (group 1)
        guard let taskRange = Range(match.range(at: 1), in: trimmedLine) else {
            return nil
        }

        let taskDescription = String(trimmedLine[taskRange])

        // Truncate to 200 chars (data-model.md validation rule) - T041.3
        let truncated = String(taskDescription.prefix(200))

        Logger.info("Parsed task: \(truncated)", log: Logger.monitoring)
        return truncated
    }

    /// Parse output buffer and extract most recent current task
    /// Task: T041.4 - handle unparseable output gracefully
    /// - Parameter output: Full or partial stdout buffer
    /// - Returns: Most recent task description, or nil if none found
    func parseLatestTask(from output: String) -> String? {
        let lines = output.split(separator: "\n").reversed() // Start from end

        for line in lines {
            if let task = parseCurrentTask(from: String(line)) {
                return task
            }
        }

        // T041.4: Handle unparseable output gracefully
        return nil // Will show "Unknown" or last known task in UI
    }

    /// Validate task description format
    /// - Parameter task: Task description to validate
    /// - Returns: true if valid, false otherwise
    func isValidTask(_ task: String) -> Bool {
        // Task must not be empty and must not be just whitespace
        let trimmed = task.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 200
    }
}
