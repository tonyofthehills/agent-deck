
//
//  TranscriptWatcher.swift
//  Agent-Deck
//
//  Real-time transcript monitoring using FSEvents
//  Watches ~/.claude/projects/ for .jsonl file changes
//

import Foundation
import Combine

/// Service that watches Claude Code transcript files for real-time activity updates
/// Uses FSEvents to detect when .jsonl files are modified
class TranscriptWatcher {
    /// Callback when a transcript is updated with new task text
    var onTranscriptUpdate: ((String, String) -> Void)? // (sessionId, taskText)

    private var eventStream: FSEventStreamRef?
    private let projectsDir: String

    init() {
        self.projectsDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/projects")
            .path
    }

    /// Start watching for transcript file changes
    func startWatching() {
        guard FileManager.default.fileExists(atPath: projectsDir) else {
            Logger.error("Claude projects directory not found: \(projectsDir)", log: Logger.monitoring)
            return
        }

        let pathsToWatch = [projectsDir] as CFArray

        var context = FSEventStreamContext(
            version: 0,
            info: Unmanaged.passUnretained(self).toOpaque(),
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        let callback: FSEventStreamCallback = { (
            stream: ConstFSEventStreamRef,
            contextInfo: UnsafeMutableRawPointer?,
            numEvents: Int,
            eventPaths: UnsafeMutableRawPointer,
            eventFlags: UnsafePointer<FSEventStreamEventFlags>,
            eventIds: UnsafePointer<FSEventStreamEventId>
        ) in
            guard let contextInfo = contextInfo else { return }

            let watcher = Unmanaged<TranscriptWatcher>.fromOpaque(contextInfo).takeUnretainedValue()

            // eventPaths is a C array of C string pointers
            let pathsPointer = eventPaths.assumingMemoryBound(to: UnsafePointer<CChar>.self)

            Logger.info("FSEvents fired with \(numEvents) event(s)", log: Logger.monitoring)

            for i in 0..<numEvents {
                let path = String(cString: pathsPointer[i])
                Logger.info("FSEvent path: \(path)", log: Logger.monitoring)

                // Only process .jsonl transcript files
                if path.hasSuffix(".jsonl") {
                    Logger.info("Processing transcript: \(path)", log: Logger.monitoring)
                    watcher.handleTranscriptChange(path: path)
                }
            }
        }

        eventStream = FSEventStreamCreate(
            kCFAllocatorDefault,
            callback,
            &context,
            pathsToWatch,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0.1, // 100ms latency for near-instant updates
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents)
        )

        guard let stream = eventStream else {
            Logger.error("Failed to create FSEventStream", log: Logger.monitoring)
            return
        }

        // Use dispatch queue instead of deprecated RunLoop method
        let queue = DispatchQueue(label: "com.agentdeck.transcript-watcher", qos: .userInitiated)
        FSEventStreamSetDispatchQueue(stream, queue)
        FSEventStreamStart(stream)

        Logger.info("TranscriptWatcher started monitoring: \(projectsDir)", log: Logger.monitoring)
    }

    /// Stop watching for changes
    func stopWatching() {
        guard let stream = eventStream else { return }

        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        eventStream = nil

        Logger.info("TranscriptWatcher stopped", log: Logger.monitoring)
    }

    /// Handle a transcript file change
    private func handleTranscriptChange(path: String) {
        // Extract session ID from file name
        let fileName = (path as NSString).lastPathComponent
        guard fileName.hasSuffix(".jsonl") else { return }

        let sessionId = String(fileName.dropLast(6)) // Remove ".jsonl"
        Logger.info("Reading transcript for session: \(sessionId)", log: Logger.monitoring)

        // Read last assistant message from transcript
        if let taskText = readLastMessage(from: path) {
            Logger.info("Transcript update: \(sessionId) - \(taskText)", log: Logger.monitoring)
            onTranscriptUpdate?(sessionId, taskText)
        } else {
            Logger.warning("No task text found in transcript: \(path)", log: Logger.monitoring)
        }
    }

    /// Read the last assistant message from a JSONL transcript file
    /// Returns the first line of text from the most recent assistant message
    private func readLastMessage(from path: String) -> String? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let content = String(data: data, encoding: .utf8) else {
            return nil
        }

        let lines = content.split(separator: "\n")

        // Read backwards to find most recent assistant message
        for line in lines.reversed() {
            guard let jsonData = line.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                continue
            }

            // Check if this is an assistant message
            guard let message = json["message"] as? [String: Any],
                  message["role"] as? String == "assistant",
                  let content = message["content"] as? [[String: Any]] else {
                continue
            }

            // Find first text block that's not a thinking block
            for item in content {
                guard item["type"] as? String == "text",
                      let text = item["text"] as? String,
                      !text.isEmpty,
                      !text.hasPrefix("<thinking") else {
                    continue
                }

                // Extract first meaningful line
                let textLines = text.split(separator: "\n")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }

                if let firstLine = textLines.first {
                    return String(firstLine.prefix(200))
                }
            }
        }

        return nil
    }

    deinit {
        stopWatching()
    }
}
