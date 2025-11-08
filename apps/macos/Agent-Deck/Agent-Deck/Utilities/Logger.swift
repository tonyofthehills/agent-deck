//
//  Logger.swift
//  Agent-Deck
//
//  Created by Agent Deck Team
//

import Foundation
import os.log

/// Logging utility using os.log for Agent Deck
/// Spec: plan.md logging section
class Logger {
    static let subsystem = "com.agentdeck.mac"

    static let general = OSLog(subsystem: subsystem, category: "general")
    static let network = OSLog(subsystem: subsystem, category: "network")
    static let monitoring = OSLog(subsystem: subsystem, category: "monitoring")
    static let config = OSLog(subsystem: subsystem, category: "config")

    /// Log info message
    static func info(_ message: String, log: OSLog = general, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        os_log("%{public}@ [%{public}@:%d %{public}@] %{public}@",
               log: log,
               type: .info,
               "ℹ️",
               fileName,
               line,
               function,
               message)
    }

    /// Log error message
    static func error(_ message: String, log: OSLog = general, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        os_log("%{public}@ [%{public}@:%d %{public}@] %{public}@",
               log: log,
               type: .error,
               "❌",
               fileName,
               line,
               function,
               message)
    }

    /// Log debug message
    static func debug(_ message: String, log: OSLog = general, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        os_log("%{public}@ [%{public}@:%d %{public}@] %{public}@",
               log: log,
               type: .debug,
               "🔍",
               fileName,
               line,
               function,
               message)
    }

    /// Log warning message
    static func warning(_ message: String, log: OSLog = general, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        os_log("%{public}@ [%{public}@:%d %{public}@] %{public}@",
               log: log,
               type: .default,
               "⚠️",
               fileName,
               line,
               function,
               message)
    }
}
