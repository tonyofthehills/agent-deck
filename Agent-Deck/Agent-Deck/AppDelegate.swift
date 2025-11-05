//
//  AppDelegate.swift
//  Agent-Deck
//
//  Created by Agent Deck Team
//

import Cocoa
import SwiftUI
import Combine

/// AppDelegate for menubar app lifecycle management
/// Spec: plan.md AppDelegate section, tasks.md T015-T016
/// Phase 3: Integrated with ProcessMonitor, WebSocketServer, HTTPServer
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?

    // Services - Phase 3 (User Story 1)
    var processMonitor: ProcessMonitor?
    var webSocketServer: WebSocketServer?
    var httpServer: HTTPServer?
    var windowManager: WindowManager? // Phase 4 (User Story 2)

    // Configuration
    var configuration: Configuration?

    // Combine subscriptions for observing ProcessMonitor changes
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("🚀 Agent Deck launching...")
        Logger.info("Agent Deck launching...")

        // Hide dock icon (menubar-only app) - configured in Info.plist with LSUIElement
        NSApp.setActivationPolicy(.accessory)

        // Create menubar status item
        setupStatusBar()
        NSLog("✅ Status bar setup complete")

        // Load configuration
        let config = loadConfiguration()
        NSLog("✅ Config loaded - port: \(config.server.port)")

        // Store configuration for later use
        self.configuration = config

        // Initialize services (Phase 3)
        NSLog("🔧 Starting setupServices...")
        setupServices(config: config)
        NSLog("✅ setupServices complete")

        Logger.info("Agent Deck launched successfully")
        NSLog("🎉 Agent Deck launched successfully")
    }

    func applicationWillTerminate(_ notification: Notification) {
        Logger.info("Agent Deck terminating...")

        // Clean shutdown - Phase 3
        processMonitor?.stopMonitoring()
        webSocketServer?.stop()
        httpServer?.stop()

        Logger.info("Agent Deck terminated")
    }

    /// Setup menubar status item
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            // Set menubar icon (will use SF Symbol or custom icon)
            button.image = NSImage(systemSymbolName: "cpu", accessibilityDescription: "Agent Deck")
            button.action = #selector(togglePopover)
            button.target = self

            Logger.info("Menubar icon created", log: Logger.general)
        }
    }

    /// Toggle popover visibility
    @objc private func togglePopover() {
        if let popover = popover, popover.isShown {
            popover.performClose(nil)
        } else {
            showPopover()
        }
    }

    /// Show menubar dropdown popover
    private func showPopover() {
        guard let button = statusItem?.button else { return }

        if popover == nil {
            popover = NSPopover()
            popover?.contentSize = NSSize(width: 300, height: 400)
            popover?.behavior = .transient

            // Phase 3: Use MenuBarView with ProcessMonitor, WindowManager, and Configuration
            if let monitor = processMonitor, let winManager = windowManager, let config = configuration {
                popover?.contentViewController = NSHostingController(rootView: MenuBarView(processMonitor: monitor, windowManager: winManager, configuration: config))
            }
        }

        popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }

    /// Load configuration on launch
    private func loadConfiguration() -> Configuration {
        do {
            let config = try ConfigManager.shared.loadConfiguration()
            Logger.info("Configuration loaded: \(config.agents.count) agent patterns", log: Logger.config)
            return config
        } catch {
            Logger.error("Failed to load configuration: \(error.localizedDescription)", log: Logger.config)

            // Return default configuration
            return Configuration.default
        }
    }

    /// Setup services (Phase 3 - User Story 1)
    private func setupServices(config: Configuration) {
        NSLog("📦 Initializing WindowManager...")
        windowManager = WindowManager()

        NSLog("📦 Initializing ProcessMonitor...")
        processMonitor = ProcessMonitor()
        processMonitor?.startMonitoring(configuration: config)

        // Get WebRoot path from bundle resources
        // Note: PWA files are directly in Resources/, not Resources/WebRoot/
        let webRootPath = Bundle.main.resourcePath ?? ""
        NSLog("📁 WebRoot path: \(webRootPath)")

        // Initialize HTTPServer (serves PWA files on port 3000)
        NSLog("📦 Initializing HTTPServer on port \(config.server.port)...")
        httpServer = HTTPServer(port: UInt16(config.server.port), webRootPath: webRootPath)

        // Initialize WebSocketServer (WebSocket on port 3001 to avoid conflict)
        // TODO: Ideally HTTP server should handle WebSocket upgrades, but for MVP we use separate ports
        NSLog("📦 Initializing WebSocketServer on port \(config.server.port + 1)...")
        webSocketServer = WebSocketServer(port: UInt16(config.server.port + 1))
        webSocketServer?.processMonitor = processMonitor
        webSocketServer?.windowManager = windowManager

        // Start servers
        NSLog("🚀 Starting servers...")
        do {
            NSLog("  Starting WebSocketServer...")
            try webSocketServer?.start()
            NSLog("  ✅ WebSocketServer started")

            NSLog("  Starting HTTPServer...")
            try httpServer?.start()
            NSLog("  ✅ HTTPServer started")

            Logger.info("Servers started on port \(config.server.port)", log: Logger.network)
            NSLog("🎉 All servers started successfully!")
        } catch {
            NSLog("❌ Server start error: \(error)")
            Logger.error("Failed to start servers: \(error.localizedDescription)", log: Logger.network)

            // Show error alert
            let alert = NSAlert()
            alert.messageText = "Server Start Failed"
            alert.informativeText = "Could not start WebSocket/HTTP server on port \(config.server.port). Port may be in use.\n\nError: \(error.localizedDescription)"
            alert.alertStyle = .critical
            alert.runModal()
        }

        // Observe ProcessMonitor changes and broadcast to WebSocket clients
        NSLog("👁️ Setting up ProcessMonitor observation...")
        observeProcessMonitorChanges()
    }

    /// Observe ProcessMonitor changes and broadcast updates
    private func observeProcessMonitorChanges() {
        guard let monitor = processMonitor, let wsServer = webSocketServer else { return }

        // Use Combine to observe ProcessMonitor.$instances changes
        // When instances change, broadcast full state to all WebSocket clients
        monitor.$instances
            .dropFirst() // Skip initial empty state
            .sink { [weak self, weak wsServer] instances in
                guard let wsServer = wsServer else { return }

                Logger.info("ProcessMonitor instances changed, broadcasting to \(wsServer.connections.count) clients", log: Logger.monitoring)

                // Broadcast full state update
                let message: [String: Any] = [
                    "type": "state_update",
                    "timestamp": ISO8601DateFormatter().string(from: Date()),
                    "instances": instances.map { $0.toDictionary() }
                ]

                wsServer.broadcastMessage(message)
            }
            .store(in: &cancellables)

        Logger.info("ProcessMonitor observation configured with Combine", log: Logger.monitoring)
    }
}
