# Swift Development Guide

**Agent Deck - Swift/SwiftUI Patterns for macOS**

Patterns and best practices for the Agent Deck menubar application.

**Last Updated**: 2025-01-24

---

## Table of Contents

1. [SwiftUI Patterns](#swiftui-patterns)
2. [Process Monitoring](#process-monitoring)
3. [AppleScript Window Management](#applescript-window-management)
4. [WebSocket Server](#websocket-server)
5. [QR Code Generation](#qr-code-generation)
6. [Error Handling](#error-handling)
7. [Logging](#logging)

---

## SwiftUI Patterns

### Menubar App Structure

```swift
@main
struct AgentDeckApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView() // Settings via NSMenu, not SwiftUI
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)

        // Create menubar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        // ...
    }
}
```

### State Management with Combine

```swift
class MonitorService: ObservableObject {
    @Published var instances: [AgentInstance] = []

    private var cancellables = Set<AnyCancellable>()

    func startMonitoring() {
        Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.pollProcesses()
            }
            .store(in: &cancellables)
    }
}
```

---

## Process Monitoring

### Detect Running Agents

```swift
import AppKit

func getRunningProcesses() -> [NSRunningApplication] {
    return NSWorkspace.shared.runningApplications
}

func findClaudeCodeInstances() -> [AgentInstance] {
    let processes = getRunningProcesses()

    return processes.compactMap { app in
        guard let executableURL = app.executableURL else { return nil }
        let executableName = executableURL.lastPathComponent

        // Match "claude" or "claude-code" or "claude code"
        if executableName.lowercased().contains("claude") {
            return AgentInstance(
                id: UUID(),
                pid: app.processIdentifier,
                name: app.localizedName ?? "Claude Code",
                agentType: "claude-code",
                cwd: getCurrentDirectory(pid: app.processIdentifier),
                status: .idle
            )
        }
        return nil
    }
}

func getCurrentDirectory(pid: pid_t) -> String {
    // Use lsof to get working directory
    let task = Process()
    task.launchPath = "/usr/bin/lsof"
    task.arguments = ["-p", "\(pid)", "-a", "-d", "cwd", "-F", "n"]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""

    // Parse lsof output (format: "n/path/to/dir")
    if let line = output.split(separator: "\n").first(where: { $0.hasPrefix("n") }) {
        return String(line.dropFirst())
    }

    return "Unknown"
}
```

---

## AppleScript Window Management

### Window Switching

```swift
func focusWindow(pid: pid_t) -> Bool {
    let script = """
    tell application "System Events"
        set frontmost of first process whose unix id is \(pid) to true
    end tell
    """

    var error: NSDictionary?
    if let scriptObject = NSAppleScript(source: script) {
        scriptObject.executeAndReturnError(&error)
        return error == nil
    }
    return false
}
```

### Application Launching (Custom Actions)

```swift
func openApplication(name: String) -> Bool {
    let script = """
    tell application "\(name)"
        activate
    end tell
    """

    var error: NSDictionary?
    if let scriptObject = NSAppleScript(source: script) {
        scriptObject.executeAndReturnError(&error)
        return error == nil
    }
    return false
}
```

---

## WebSocket Server

### Using Network.framework

```swift
import Network

class WebSocketServer {
    private var listener: NWListener?
    private var connections: [NWConnection] = []

    func start(port: UInt16 = 3000) {
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true

        listener = try? NWListener(using: parameters, on: NWEndpoint.Port(integerLiteral: port))

        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }

        listener?.start(queue: .main)
    }

    func broadcast(message: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: message) else { return }

        connections.forEach { connection in
            connection.send(content: data, completion: .idempotent)
        }
    }
}
```

---

## QR Code Generation

### Generate QR Code for Mobile Pairing

```swift
import CoreImage

func generateQRCode(from string: String) -> NSImage? {
    let data = string.data(using: .utf8)

    let filter = CIFilter(name: "CIQRCodeGenerator")
    filter?.setValue(data, forKey: "inputMessage")
    filter?.setValue("H", forKey: "inputCorrectionLevel")

    guard let outputImage = filter?.outputImage else { return nil }

    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaledImage = outputImage.transformed(by: transform)

    let rep = NSCIImageRep(ciImage: scaledImage)
    let nsImage = NSImage(size: rep.size)
    nsImage.addRepresentation(rep)

    return nsImage
}

// Usage:
let localIP = getLocalIPAddress() // "192.168.1.100"
let url = "ws://\(localIP):3000"
let qrCode = generateQRCode(from: url)
```

### Get Local IP Address

```swift
import Foundation

func getLocalIPAddress() -> String? {
    var address: String?
    var ifaddr: UnsafeMutablePointer<ifaddrs>?

    if getifaddrs(&ifaddr) == 0 {
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }

            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family

            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: (interface?.ifa_name)!)
                if name == "en0" { // WiFi interface
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                              &hostname, socklen_t(hostname.count),
                              nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
    }

    return address
}
```

---

## Error Handling

### Custom Error Types

```swift
enum AgentDeckError: Error, LocalizedError {
    case configurationLoadFailed
    case webSocketBindFailed
    case processMonitoringFailed
    case windowSwitchFailed

    var errorDescription: String? {
        switch self {
        case .configurationLoadFailed:
            return "Failed to load configuration from ~/.agent-deck/config.yaml"
        case .webSocketBindFailed:
            return "Failed to start WebSocket server on port 3000"
        case .processMonitoringFailed:
            return "Failed to monitor running processes"
        case .windowSwitchFailed:
            return "Failed to switch window (check Accessibility permissions)"
        }
    }
}

// Usage:
do {
    let config = try loadConfig()
} catch {
    // Show alert to user
    let alert = NSAlert()
    alert.messageText = "Configuration Error"
    alert.informativeText = error.localizedDescription
    alert.runModal()
}
```

---

## Logging

### Structured Logging with os.log

```swift
import os.log

class Logger {
    static let subsystem = "com.agentdeck.app"

    static let general = OSLog(subsystem: subsystem, category: "general")
    static let network = OSLog(subsystem: subsystem, category: "network")
    static let monitoring = OSLog(subsystem: subsystem, category: "monitoring")

    static func info(_ message: String, log: OSLog = general) {
        os_log("%{public}@", log: log, type: .info, message)
    }

    static func error(_ message: String, log: OSLog = general) {
        os_log("%{public}@", log: log, type: .error, message)
    }
}

// Usage:
Logger.info("WebSocket server started on port 3000", log: .network)
Logger.error("Failed to parse agent output", log: .monitoring)
```

### View Logs

```bash
# Console.app or:
log stream --predicate 'subsystem == "com.agentdeck.app"'
```

---

## Related Documentation

- **[CLAUDE.md](../../CLAUDE.md)** - Main project guide
- **[REACT_NATIVE_GUIDE.md](./REACT_NATIVE_GUIDE.md)** - React Native patterns
- **[LESSONS_LEARNED.md](./LESSONS_LEARNED.md)** - Critical Swift patterns discovered
- **[QUICK_START.md](./QUICK_START.md)** - Quick start guide

---

**Version**: 1.0
**Extracted from**: CLAUDE.md (Agent Deck project)
**Last Updated**: 2025-01-24
