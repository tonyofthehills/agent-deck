# WebSocket Protocol: Agent Deck MVP

**Feature**: Agent Deck MVP (Phases 1-2)
**Date**: 2025-01-02
**Protocol Version**: 1.0

## Overview

This document defines the WebSocket communication protocol between Agent Deck Mac app (server) and PWA mobile client. The protocol uses JSON messages over WebSocket (ws://) for real-time bidirectional communication.

---

## Connection Handshake

### Client → Server (HTTP Upgrade)

```http
GET / HTTP/1.1
Host: 192.168.1.100:3000
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==
Sec-WebSocket-Version: 13
```

### Server → Client (Upgrade Response)

```http
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: HSmrc0sMlYUkAGmm5OPpG2HaGWk=
```

**Connection established at**: `ws://<local-ip>:3000/`

---

## Message Format

All messages are JSON objects sent as WebSocket text frames.

### Base Message Structure

```json
{
  "type": "<message-type>",
  "timestamp": "<ISO-8601-timestamp>",
  ...additional fields per type...
}
```

---

## Server → Client Messages

### 1. Initial State (on connect)

**Type**: `initial_state`
**When**: Immediately after WebSocket handshake
**Purpose**: Send full current state to newly connected client

```json
{
  "type": "initial_state",
  "timestamp": "2025-01-02T14:30:00Z",
  "instances": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "pid": 12345,
      "agentType": "claude-code",
      "workingDirectory": "/Users/dev/project",
      "status": "working",
      "currentTask": "Implementing authentication tests",
      "lastActivityTimestamp": "2025-01-02T14:29:55Z"
    }
  ],
  "serverVersion": "1.0.0"
}
```

**Fields**:
- `instances`: Array of all current AgentInstance objects
- `serverVersion`: Mac app version string

---

### 2. Status Update

**Type**: `update`
**When**: Any AgentInstance status or currentTask changes
**Purpose**: Real-time status synchronization (FR-007, FR-014)

```json
{
  "type": "update",
  "timestamp": "2025-01-02T14:30:15Z",
  "instanceId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "working",
  "currentTask": "Writing unit tests"
}
```

**Fields**:
- `instanceId`: UUID of affected AgentInstance
- `status`: New AgentStatus value ("idle" | "working" | "done" | "error")
- `currentTask`: Optional task description (nullable)

**Latency Requirement**: Must be delivered within 500ms of status change (SC-001)

---

### 3. Instance Added

**Type**: `instance_added`
**When**: New Claude Code process detected
**Purpose**: Notify clients of new agent instances

```json
{
  "type": "instance_added",
  "timestamp": "2025-01-02T14:25:00Z",
  "instance": {
    "id": "660e9500-f39c-51e5-b827-557766551111",
    "pid": 67890,
    "agentType": "claude-code",
    "workingDirectory": "/Users/dev/another-project",
    "status": "idle",
    "currentTask": null,
    "lastActivityTimestamp": "2025-01-02T14:25:00Z"
  }
}
```

**Fields**:
- `instance`: Full AgentInstance object

---

### 4. Instance Removed

**Type**: `instance_removed`
**When**: Claude Code process terminates
**Purpose**: Notify clients to remove instance from UI

```json
{
  "type": "instance_removed",
  "timestamp": "2025-01-02T14:35:00Z",
  "instanceId": "550e8400-e29b-41d4-a716-446655440000",
  "reason": "process_terminated"
}
```

**Fields**:
- `instanceId`: UUID of terminated instance
- `reason`: "process_terminated" | "manual_stop" | "error"

---

### 5. Focus Success

**Type**: `focus_success`
**When**: Window switch command completed successfully
**Purpose**: Confirm window focus operation to client (FR-030)

```json
{
  "type": "focus_success",
  "timestamp": "2025-01-02T14:30:20Z",
  "instanceId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Latency Requirement**: Must be sent within 1 second of receiving `focus` command (SC-002)

---

### 6. Focus Failure

**Type**: `focus_failure`
**When**: Window switch command failed
**Purpose**: Report error to client with actionable message (FR-031)

```json
{
  "type": "focus_failure",
  "timestamp": "2025-01-02T14:30:20Z",
  "instanceId": "550e8400-e29b-41d4-a716-446655440000",
  "error": "accessibility_permissions_required",
  "message": "Agent Deck needs Accessibility permissions to switch windows. Please grant permission in System Preferences > Privacy & Security > Accessibility."
}
```

**Error Codes**:
- `accessibility_permissions_required`: Missing accessibility permissions
- `instance_not_found`: Instance no longer exists
- `window_not_found`: Window ID invalid or process has no window
- `applescript_error`: AppleScript execution failed

---

### 7. Pong

**Type**: `pong`
**When**: In response to client `ping`
**Purpose**: Keep-alive heartbeat response

```json
{
  "type": "pong",
  "timestamp": "2025-01-02T14:30:25Z"
}
```

---

## Client → Server Messages

### 1. Focus Instance

**Type**: `focus`
**When**: User taps agent instance card on mobile
**Purpose**: Request Mac to bring window to front (FR-015, FR-028)

```json
{
  "type": "focus",
  "timestamp": "2025-01-02T14:30:19Z",
  "instanceId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Expected Response**: `focus_success` or `focus_failure` within 1 second

---

### 2. Ping

**Type**: `ping`
**When**: Every 30 seconds (client-initiated keep-alive)
**Purpose**: Detect connection health, prevent timeout

```json
{
  "type": "ping",
  "timestamp": "2025-01-02T14:30:25Z"
}
```

**Expected Response**: `pong` within 5 seconds

---

## Error Handling

### Server Errors

If server encounters error processing message:

```json
{
  "type": "error",
  "timestamp": "2025-01-02T14:30:30Z",
  "error": "invalid_message_format",
  "message": "Unable to parse JSON message"
}
```

**Error Codes**:
- `invalid_message_format`: JSON parsing failed
- `unknown_message_type`: Unrecognized `type` field
- `missing_required_field`: Required field missing
- `internal_server_error`: Server-side exception

### Client Error Handling

**Connection Loss**:
- Client detects disconnection via WebSocket `onclose` event
- Display "Disconnected" status indicator (FR-016)
- Attempt reconnection with exponential backoff (FR-017)
- Backoff schedule: 1s → 2s → 4s → 8s → 16s (max)

**Timeout**:
- If no `pong` received within 10 seconds of `ping`, assume connection dead
- Trigger reconnection flow

**Message Parse Error**:
- Log error to console
- Display error toast notification (optional in MVP)
- Continue processing other messages

---

## Message Flow Examples

### Scenario 1: New Client Connection

```
Client → Server: HTTP Upgrade Request
Server → Client: 101 Switching Protocols
Server → Client: initial_state (with current instances list)
Client → Server: ping
Server → Client: pong
```

### Scenario 2: Status Change

```
[ProcessMonitor detects Claude Code status change]
Server → Client 1: update (status: "working")
Server → Client 2: update (status: "working")
Server → Client N: update (status: "working")
[All connected clients receive update within 500ms]
```

### Scenario 3: Window Focus

```
[User taps instance card on mobile]
Client → Server: focus (instanceId: "550e...")
[Server executes AppleScript]
Server → Client: focus_success
[User returns to desk, window is frontmost]
```

### Scenario 4: New Instance Detected

```
[ProcessMonitor detects new Claude Code process]
Server → Client 1: instance_added (new instance object)
Server → Client 2: instance_added (new instance object)
[Clients add new card to UI list]
```

### Scenario 5: Connection Health Check

```
Client → Server: ping
[30 seconds pass]
Client → Server: ping
Server → Client: pong
[Connection healthy]
```

---

## Performance Requirements

| Requirement | Target | Success Criterion |
|-------------|--------|-------------------|
| Status update latency | <500ms | SC-001 |
| Window focus latency | <1s | SC-002 |
| Ping/pong round-trip | <100ms | Implicit (local network) |
| Reconnection time | <5s | SC-011 |
| Message size | <10KB | Typical instance object ~2KB |

---

## Security Considerations

**Phase 1-2 MVP** (Local Network Only):
- ❌ No authentication/authorization
- ❌ No encryption (plain WebSocket, not WSS)
- ✅ Bind to local network only (0.0.0.0:3000)
- ✅ Trust same-network devices

**Phase 6+ (Production)**:
- ✅ Implement WSS (TLS encryption)
- ✅ Add authentication layer (token-based)
- ✅ Rate limiting on focus commands
- ✅ Input validation on all messages

---

## Protocol Versioning

**Current Version**: 1.0

**Version Negotiation** (Phase 3+):
- Client sends `Sec-WebSocket-Protocol: agentdeck-v1` header
- Server validates and confirms version
- Reject incompatible versions

**Breaking Changes**:
- Major version increment (1.0 → 2.0)
- Backward compatibility window: 1 release cycle

---

## Testing Protocol

### Manual Testing Checklist

- [ ] Connect PWA from mobile, verify `initial_state` received
- [ ] Change agent status on Mac, verify `update` received within 500ms
- [ ] Tap instance card, verify `focus_success` and window switches
- [ ] Terminate Claude Code process, verify `instance_removed` received
- [ ] Disconnect WiFi on mobile, verify reconnection within 5s
- [ ] Send invalid JSON, verify `error` message received
- [ ] Multiple clients connected, verify broadcast to all

### Tools

- **wscat**: CLI WebSocket client for testing
  ```bash
  wscat -c ws://192.168.1.100:3000
  ```
- **Chrome DevTools**: Network tab → WS filter → inspect messages
- **Postman**: WebSocket testing interface

---

## References

- WebSocket RFC: [RFC 6455](https://datatracker.ietf.org/doc/html/rfc6455)
- Swift Network.framework: [Apple Developer Docs](https://developer.apple.com/documentation/network)
- Data Model: [data-model.md](../data-model.md)
- Spec Requirements: FR-007, FR-011, FR-014, FR-015, FR-016, FR-017, FR-030, FR-031
