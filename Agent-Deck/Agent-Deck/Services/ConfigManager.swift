//
//  ConfigManager.swift
//  Agent-Deck
//
//  Created by Agent Deck Team
//

import Foundation
import Yams

/// Service for loading and managing YAML configuration
/// Spec: plan.md Configuration Storage section
class ConfigManager {
    static let shared = ConfigManager()

    private let configDirectory: URL
    private let configFile: URL
    private let defaultConfigResource = "default-config"

    private init() {
        // Configuration directory: ~/.agent-deck/
        configDirectory = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".agent-deck")

        configFile = configDirectory.appendingPathComponent("config.yaml")
    }

    /// Load configuration from ~/.agent-deck/config.yaml
    /// Creates default config if file doesn't exist
    func loadConfiguration() throws -> Configuration {
        Logger.info("Loading configuration from \(configFile.path)", log: Logger.config)

        // Create config directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: configDirectory.path) {
            try FileManager.default.createDirectory(at: configDirectory, withIntermediateDirectories: true)
            Logger.info("Created config directory: \(configDirectory.path)", log: Logger.config)
        }

        // If config file doesn't exist, create default
        if !FileManager.default.fileExists(atPath: configFile.path) {
            Logger.info("Config file not found, creating default configuration", log: Logger.config)
            try createDefaultConfig()
        }

        // Load and parse YAML
        let yamlString = try String(contentsOf: configFile, encoding: .utf8)
        let decoder = YAMLDecoder()
        let config = try decoder.decode(Configuration.self, from: yamlString)

        // Validate configuration
        guard config.isValid else {
            Logger.error("Configuration validation failed", log: Logger.config)
            throw ConfigError.invalidConfiguration
        }

        Logger.info("Configuration loaded successfully: \(config.agents.count) agent patterns", log: Logger.config)
        return config
    }

    /// Create default configuration file
    private func createDefaultConfig() throws {
        let defaultConfig = Configuration.default

        let encoder = YAMLEncoder()
        let yamlString = try encoder.encode(defaultConfig)

        try yamlString.write(to: configFile, atomically: true, encoding: .utf8)
        Logger.info("Created default config file: \(configFile.path)", log: Logger.config)
    }

    /// Get server port from UserDefaults or configuration
    func getServerPort() -> Int {
        if let port = UserDefaults.standard.object(forKey: "serverPort") as? Int {
            return port
        }
        return 3000 // Default
    }

    /// Save server port to UserDefaults
    func saveServerPort(_ port: Int) {
        UserDefaults.standard.set(port, forKey: "serverPort")
        Logger.info("Saved server port: \(port)", log: Logger.config)
    }

    /// Get auto-start preference from UserDefaults
    func getAutoStartOnLogin() -> Bool {
        return UserDefaults.standard.bool(forKey: "autoStartOnLogin")
    }

    /// Save auto-start preference to UserDefaults
    func saveAutoStartOnLogin(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "autoStartOnLogin")
        Logger.info("Saved auto-start on login: \(enabled)", log: Logger.config)
    }

    enum ConfigError: Error, LocalizedError {
        case invalidConfiguration
        case fileNotFound
        case parseError

        var errorDescription: String? {
            switch self {
            case .invalidConfiguration:
                return "Configuration validation failed. Check port range and regex patterns."
            case .fileNotFound:
                return "Configuration file not found at ~/.agent-deck/config.yaml"
            case .parseError:
                return "Failed to parse YAML configuration file"
            }
        }
    }
}
