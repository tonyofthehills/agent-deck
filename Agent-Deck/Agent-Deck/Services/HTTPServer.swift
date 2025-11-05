//
//  HTTPServer.swift
//  Agent-Deck
//
//  HTTP server for serving PWA static files
//  Spec: tasks.md T029-T030
//  Fixed: 2025-11-03 - Connection handling issues
//

import Foundation
import Network

/// Simple HTTP server for serving PWA files from Resources/WebRoot
class HTTPServer {
    private var listener: NWListener?
    private var port: UInt16
    private var webRootPath: String
    private var activeConnections: Set<UUID> = []
    private var connectionTimeouts: [UUID: DispatchWorkItem] = [:]
    private let connectionTimeout: TimeInterval = 30.0

    init(port: UInt16 = 3000, webRootPath: String) {
        self.port = port
        self.webRootPath = webRootPath
        Logger.info("HTTPServer initialized on port \(port)", log: Logger.network)
    }

    /// Start HTTP server
    /// Task: T029 - implement HTTPServer using Network.framework
    func start() throws {
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true

        listener = try NWListener(using: parameters, on: NWEndpoint.Port(integerLiteral: port))

        guard let listener = listener else {
            NSLog("❌ HTTP listener creation failed")
            throw NSError(domain: "AgentDeck", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create HTTP listener"])
        }

        listener.newConnectionHandler = { [weak self] connection in
            self?.handleHTTPConnection(connection)
        }

        listener.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .ready:
                NSLog("🌐 HTTP server READY on port \(self.port)")
                Logger.info("HTTP server listening on port \(self.port)", log: Logger.network)
            case .failed(let error):
                NSLog("❌ HTTP server FAILED: \(error.localizedDescription)")
                Logger.error("HTTP server failed: \(error.localizedDescription)", log: Logger.network)
            case .waiting(let error):
                NSLog("⏳ HTTP server WAITING: \(error)")
            case .cancelled:
                NSLog("🛑 HTTP server CANCELLED")
            default:
                NSLog("❓ HTTP server state: \(state)")
            }
        }

        listener.start(queue: .main)
    }

    /// Stop HTTP server
    func stop() {
        // Cancel all active connections
        activeConnections.forEach { id in
            connectionTimeouts[id]?.cancel()
        }
        connectionTimeouts.removeAll()
        activeConnections.removeAll()

        listener?.cancel()
        Logger.info("HTTP server stopped", log: Logger.network)
    }

    /// Handle HTTP connection
    private func handleHTTPConnection(_ connection: NWConnection) {
        let connectionId = UUID()
        activeConnections.insert(connectionId)

        connection.start(queue: .main)

        // Set connection timeout
        let timeoutWork = DispatchWorkItem { [weak self, weak connection] in
            guard let self = self else { return }
            Logger.warning("HTTP connection timeout", log: Logger.network)
            connection?.cancel()
            self.activeConnections.remove(connectionId)
            self.connectionTimeouts.removeValue(forKey: connectionId)
        }
        connectionTimeouts[connectionId] = timeoutWork
        DispatchQueue.main.asyncAfter(deadline: .now() + connectionTimeout, execute: timeoutWork)

        // Start receive loop
        receiveLoop(connection: connection, connectionId: connectionId)
    }

    /// Receive loop for handling multiple requests on same connection
    private func receiveLoop(connection: NWConnection, connectionId: UUID) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }

            // Reset timeout on activity
            if let timeoutWork = self.connectionTimeouts[connectionId] {
                timeoutWork.cancel()
                let newTimeout = DispatchWorkItem { [weak self, weak connection] in
                    Logger.warning("HTTP connection timeout", log: Logger.network)
                    connection?.cancel()
                    self?.activeConnections.remove(connectionId)
                    self?.connectionTimeouts.removeValue(forKey: connectionId)
                }
                self.connectionTimeouts[connectionId] = newTimeout
                DispatchQueue.main.asyncAfter(deadline: .now() + self.connectionTimeout, execute: newTimeout)
            }

            if let error = error {
                Logger.error("HTTP receive error: \(error.localizedDescription)", log: Logger.network)
                self.cleanupConnection(connection, connectionId: connectionId)
                return
            }

            guard let data = data, let request = String(data: data, encoding: .utf8) else {
                if isComplete {
                    self.cleanupConnection(connection, connectionId: connectionId)
                } else {
                    // Continue receiving
                    self.receiveLoop(connection: connection, connectionId: connectionId)
                }
                return
            }

            // Handle request
            self.handleHTTPRequest(request, connection: connection, connectionId: connectionId, isComplete: isComplete)
        }
    }

    /// Clean up connection
    private func cleanupConnection(_ connection: NWConnection, connectionId: UUID) {
        connectionTimeouts[connectionId]?.cancel()
        connectionTimeouts.removeValue(forKey: connectionId)
        activeConnections.remove(connectionId)
        connection.cancel()
    }

    /// Handle HTTP request and serve file
    /// Task: T030 - serve static files from Resources/WebRoot
    private func handleHTTPRequest(_ request: String, connection: NWConnection, connectionId: UUID, isComplete: Bool) {
        // Parse request line
        let lines = request.split(separator: "\r\n")
        guard let requestLine = lines.first else {
            sendErrorResponse(connection, statusCode: 400, message: "Bad Request", connectionId: connectionId)
            return
        }

        let parts = requestLine.split(separator: " ")
        guard parts.count >= 2 else {
            sendErrorResponse(connection, statusCode: 400, message: "Bad Request", connectionId: connectionId)
            return
        }

        let method = String(parts[0])
        var path = String(parts[1])

        // Only support GET requests
        guard method == "GET" else {
            sendErrorResponse(connection, statusCode: 405, message: "Method Not Allowed", connectionId: connectionId)
            return
        }

        // Check for WebSocket upgrade (redirect to WebSocket handler)
        if request.contains("Upgrade: websocket") {
            // This is a WebSocket request, not an HTTP request
            // Close this connection - client should connect to WebSocket port
            cleanupConnection(connection, connectionId: connectionId)
            return
        }

        // Default to index.html for root path
        if path == "/" {
            path = "/index.html"
        }

        // Serve file
        serveFile(path: path, connection: connection, connectionId: connectionId, isComplete: isComplete)
    }

    /// Serve static file from WebRoot
    private func serveFile(path: String, connection: NWConnection, connectionId: UUID, isComplete: Bool) {
        // Remove leading slash and prevent directory traversal
        let safePath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .replacingOccurrences(of: "..", with: "")

        let filePath = "\(webRootPath)/\(safePath)"

        // Check if file exists
        guard FileManager.default.fileExists(atPath: filePath) else {
            sendErrorResponse(connection, statusCode: 404, message: "Not Found", connectionId: connectionId)
            return
        }

        // Read file
        guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            sendErrorResponse(connection, statusCode: 500, message: "Internal Server Error", connectionId: connectionId)
            return
        }

        // Determine content type
        let contentType = getContentType(for: safePath)

        // Send response
        let response = """
        HTTP/1.1 200 OK\r
        Content-Type: \(contentType)\r
        Content-Length: \(fileData.count)\r
        Connection: close\r
        Access-Control-Allow-Origin: *\r
        \r

        """

        var responseData = response.data(using: .utf8)!
        responseData.append(fileData)

        connection.send(content: responseData, completion: .idempotent)

        Logger.info("Served file: \(safePath) (\(fileData.count) bytes)", log: Logger.network)

        // Close connection after sending response
        // Small delay to ensure data is sent
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.cleanupConnection(connection, connectionId: connectionId)
        }
    }

    /// Send HTTP error response
    private func sendErrorResponse(_ connection: NWConnection, statusCode: Int, message: String, connectionId: UUID) {
        let body = """
        <html><body><h1>\(statusCode) \(message)</h1></body></html>
        """

        let response = """
        HTTP/1.1 \(statusCode) \(message)\r
        Content-Type: text/html\r
        Content-Length: \(body.count)\r
        Connection: close\r
        \r
        \(body)
        """

        let responseData = response.data(using: .utf8)!
        connection.send(content: responseData, completion: .idempotent)

        Logger.warning("HTTP \(statusCode): \(message)", log: Logger.network)

        // Close connection after sending error
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.cleanupConnection(connection, connectionId: connectionId)
        }
    }

    /// Get content type for file extension
    private func getContentType(for path: String) -> String {
        let ext = (path as NSString).pathExtension.lowercased()

        switch ext {
        case "html":
            return "text/html; charset=utf-8"
        case "js":
            return "application/javascript; charset=utf-8"
        case "css":
            return "text/css; charset=utf-8"
        case "json":
            return "application/json"
        case "png":
            return "image/png"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "svg":
            return "image/svg+xml"
        case "ico":
            return "image/x-icon"
        default:
            return "application/octet-stream"
        }
    }
}
