//
//  Configuration.swift
//  Agent-Deck
//
//  Created by Agent Deck Team
//

import Foundation

/// Application settings loaded from YAML file and UserDefaults
/// Spec: data-model.md Entity 4
struct Configuration: Codable {
    /// Server configuration
    let server: ServerConfig

    /// Agent monitoring patterns
    let agents: [AgentPattern]

    struct ServerConfig: Codable {
        /// WebSocket/HTTP server port (default: 3000)
        let port: Int

        /// Server bind address (default: "0.0.0.0")
        let host: String

        /// Validate port is in unprivileged range
        var isValid: Bool {
            return port >= 1024 && port <= 65535
        }
    }

    struct AgentPattern: Codable {
        /// Display name (e.g., "Claude Code")
        let name: String

        /// Regex pattern for process name matching
        let processPattern: String

        /// Whether to monitor this agent type
        let enabled: Bool

        enum CodingKeys: String, CodingKey {
            case name
            case processPattern = "process_pattern"
            case enabled
        }

        /// Validate regex pattern compiles
        var isValid: Bool {
            do {
                _ = try NSRegularExpression(pattern: processPattern, options: [])
                return true
            } catch {
                return false
            }
        }
    }

    /// Default configuration
    static let `default` = Configuration(
        server: ServerConfig(port: 3000, host: "0.0.0.0"),
        agents: [
            AgentPattern(
                name: "Claude Code",
                processPattern: "claude.*code",
                enabled: true
            )
        ]
    )

    /// Validate entire configuration
    var isValid: Bool {
        return server.isValid && agents.allSatisfy { $0.isValid }
    }
}
