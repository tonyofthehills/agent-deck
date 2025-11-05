# Data Model: Agent Deck MVP

**Feature**: Agent Deck MVP (Phases 1-2)
**Date**: 2025-01-02
**Status**: Phase 1 Design

## Overview

This document defines the core entities for Agent Deck MVP. All entities are designed for in-memory state management with minimal persistence (YAML config, UserDefaults, localStorage).

---

## Entity 1: AgentInstance

**Purpose**: Represents a running AI coding agent process being monitored by Agent Deck.

### Attributes

| Attribute | Type | Nullable | Description | Validation |
|-----------|------|----------|-------------|------------|
| `id` | UUID | No | Unique identifier for this agent instance | Generated on detection |
| `pid` | Int32 | No | Process ID from macOS | Must be valid running process |
| `agentType` | String | No | Agent type identifier (e.g., "claude-code") | Enum: "claude-code" (Phase 1-2) |
| `workingDirectory` | String | No | Current working directory path | Must be absolute path |
| `status` | AgentStatus | No | Current agent status | See AgentStatus enum |
| `currentTask` | String | Yes | Parsed task description from stdout | Max length: 200 chars |
| `lastActivityTimestamp` | Date | No | Timestamp of last status change | ISO 8601 format |
| `windowIdentifier` | String | Yes | macOS window ID for focus switching | Optional in Phase 1-2 |
| `modelName` | String | Yes | AI model name (e.g., "claude-sonnet-4-5-20250929") | Extracted from transcript |
| `gitBranch` | String | Yes | Current git branch name | Extracted from git commands or transcript |
| `activeSubagents` | Array<SubagentInfo> | Yes | List of running subagents | See SubagentInfo entity |
| `todos` | Array<TodoItem> | Yes | Parsed todo list with status | See TodoItem entity |
| `currentTaskDescription` | String | Yes | Detailed task description from activeForm | Max length: 500 chars |

### Relationships

- **Has many**: StatusUpdate (1:N - one instance generates many status updates)
- **Monitored by**: ProcessMonitor service (composition)

### State Transitions

```
nil → idle (on process detection)
idle → working (on task start)
working → idle (on task completion)
working → done (on all tasks complete)
working → error (on task failure)
error → idle (on error recovery)
done → idle (on new task)
```

### Lifecycle

1. **Created**: When ProcessMonitor detects new Claude Code process
2. **Updated**: When status changes or currentTask parsed from stdout
3. **Deleted**: When process terminates (removed from instances list)

### Example (JSON representation)

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "pid": 12345,
  "agentType": "claude-code",
  "workingDirectory": "/Users/dev/project",
  "status": "working",
  "currentTask": "Implementing authentication tests",
  "lastActivityTimestamp": "2025-01-02T14:30:00Z",
  "windowIdentifier": "1234",
  "modelName": "claude-sonnet-4-5-20250929",
  "gitBranch": "001-mvp",
  "activeSubagents": [
    {
      "agentId": "subagent-001",
      "type": "Explore",
      "description": "Researching authentication patterns"
    }
  ],
  "todos": [
    {
      "id": "todo-1",
      "content": "Create SubagentInfo model",
      "status": "completed",
      "activeForm": "Creating SubagentInfo model"
    },
    {
      "id": "todo-2",
      "content": "Create TodoItem model",
      "status": "in_progress",
      "activeForm": "Creating TodoItem model"
    },
    {
      "id": "todo-3",
      "content": "Integrate TranscriptParser",
      "status": "pending",
      "activeForm": "Integrating TranscriptParser"
    }
  ],
  "currentTaskDescription": "Creating TodoItem model"
}
```

---

## Entity 2: SubagentInfo

**Purpose**: Represents an active subagent spawned by the main Claude Code agent.

### Attributes

| Attribute | Type | Nullable | Description | Validation |
|-----------|------|----------|-------------|------------|
| `agentId` | String | No | Unique identifier for this subagent | Format: "subagent-NNN" |
| `type` | String | No | Subagent type (e.g., "Explore", "general-purpose") | Extracted from transcript |
| `description` | String | No | Human-readable task description | Max length: 200 chars |

### Lifecycle

1. **Created**: When transcript shows new subagent invocation
2. **Updated**: When subagent description changes
3. **Deleted**: When subagent completes (removed from activeSubagents array)

### Example (JSON representation)

```json
{
  "agentId": "subagent-001",
  "type": "Explore",
  "description": "Researching authentication patterns in React Native"
}
```

---

## Entity 3: TodoItem

**Purpose**: Represents a task item from Claude Code's todo list.

### Attributes

| Attribute | Type | Nullable | Description | Validation |
|-----------|------|----------|-------------|------------|
| `id` | String | No | Unique identifier for this todo item | Generated from content hash |
| `content` | String | No | Todo item text (imperative form) | Max length: 200 chars |
| `status` | TodoStatus | No | Current status (pending, in_progress, completed) | Enum: "pending", "in_progress", "completed" |
| `activeForm` | String | No | Present continuous form for display when active | Max length: 200 chars |

### State Transitions

```
pending → in_progress (when task becomes current)
in_progress → completed (when task finishes)
completed → in_progress (rare: if task reopened)
```

### Lifecycle

1. **Created**: When new task appears in transcript todo list
2. **Updated**: When status changes (pending → in_progress → completed)
3. **Deleted**: When task is removed from todo list (rare)

### Example (JSON representation)

```json
{
  "id": "todo-1",
  "content": "Create SubagentInfo model",
  "status": "completed",
  "activeForm": "Creating SubagentInfo model"
}
```

---

## Entity 4: AgentStatus

**Purpose**: Enumeration of possible agent states displayed on mobile UI.

### Values

| Value | Display Color | Description | UI Icon Suggestion |
|-------|--------------|-------------|-------------------|
| `idle` | Gray (#888888) | Agent waiting for user input | ⏸️ Pause circle |
| `working` | Blue (#0066CC) | Agent actively processing task | ⚙️ Spinning gear |
| `done` | Green (#00AA00) | Agent completed all tasks | ✅ Checkmark |
| `error` | Red (#CC0000) | Agent encountered error | ⚠️ Warning triangle |

### Mapping from Spec Requirements

- FR-012 specifies color-coded indicators
- These values satisfy spec color requirements

---

## Entity 5: StatusUpdate

**Purpose**: Real-time event message broadcast via WebSocket to mobile clients.

### Attributes

| Attribute | Type | Nullable | Description | Validation |
|-----------|------|----------|-------------|------------|
| `type` | String | No | Message type identifier | Enum: "update", "instance_change", "connection_status" |
| `instanceId` | UUID | Yes | Reference to AgentInstance | Required for "update" type |
| `status` | AgentStatus | Yes | New status value | Required for "update" type |
| `currentTask` | String | Yes | Current task description | Max length: 200 chars |
| `timestamp` | Date | No | Event timestamp | ISO 8601 format |
| `metadata` | Dictionary<String, Any> | Yes | Additional event data | Optional per event type |

### Message Types

**Type: "update"** (Status change for existing instance)
```json
{
  "type": "update",
  "instanceId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "working",
  "currentTask": "Writing unit tests",
  "timestamp": "2025-01-02T14:30:15Z"
}
```

**Type: "instance_change"** (Instance added/removed)
```json
{
  "type": "instance_change",
  "action": "added",
  "instance": { /* full AgentInstance JSON */ },
  "timestamp": "2025-01-02T14:25:00Z"
}
```

**Type: "connection_status"** (Server connection health)
```json
{
  "type": "connection_status",
  "status": "connected",
  "serverVersion": "1.0.0",
  "timestamp": "2025-01-02T14:20:00Z"
}
```

### Lifecycle

1. **Created**: When status change detected by ProcessMonitor
2. **Broadcast**: Sent via WebSocket to all connected clients
3. **Delivered**: Within 500ms of creation (SC-001 requirement)
4. **Ephemeral**: Not persisted (in-memory only)

---

## Entity 6: Configuration

**Purpose**: Application settings loaded from YAML file and UserDefaults.

### Attributes

| Attribute | Type | Nullable | Source | Description |
|-----------|------|----------|--------|-------------|
| `serverPort` | Int | No | YAML / UserDefaults | WebSocket/HTTP server port (default: 3000) |
| `serverHost` | String | No | YAML | Server bind address (default: "0.0.0.0") |
| `autoStartOnLogin` | Bool | No | UserDefaults | Launch app on macOS login |
| `agentPatterns` | Array<AgentPattern> | No | YAML | Process name regex patterns |

### Sub-Entity: AgentPattern

| Attribute | Type | Description |
|-----------|------|-------------|
| `name` | String | Display name (e.g., "Claude Code") |
| `processPattern` | String | Regex pattern (e.g., "claude.*code") |
| `enabled` | Bool | Whether to monitor this agent type |

### Example YAML Configuration

```yaml
server:
  port: 3000
  host: "0.0.0.0"

agents:
  - name: "Claude Code"
    process_pattern: "claude.*code"
    enabled: true

  - name: "Cursor"
    process_pattern: "Cursor"
    enabled: false  # Phase 3+
```

### Lifecycle

1. **Loaded**: On app launch from ~/.agent-deck/config.yaml
2. **Created**: Default config written if file doesn't exist
3. **Updated**: When user modifies settings via Settings window or edits YAML
4. **Reloaded**: On file change detection (optional Phase 3+)

---

## Entity 7: WebSocketConnection

**Purpose**: Represents active connection from mobile client to Mac server.

### Attributes

| Attribute | Type | Nullable | Description |
|-----------|------|----------|-------------|
| `id` | UUID | No | Unique connection identifier |
| `remoteAddress` | String | No | Client IP address (e.g., "192.168.1.50") |
| `connectedAt` | Date | No | Connection establishment timestamp |
| `lastPingAt` | Date | Yes | Timestamp of last ping/pong |
| `connection` | NWConnection | No | Network.framework connection object |

### Relationships

- **Receives**: StatusUpdate messages (N:N - many connections receive many updates)
- **Managed by**: WebSocketServer service

### Lifecycle

1. **Created**: When mobile client completes WebSocket handshake
2. **Active**: While connection open and ping/pong heartbeat succeeds
3. **Disconnected**: On client disconnect, network failure, or server shutdown
4. **Cleaned up**: Immediately on disconnect (removed from connections list)

---

## Data Flow Diagram

```
┌──────────────────┐
│  ProcessMonitor  │ (Polls every 1-2s)
└────────┬─────────┘
         │ Detects process
         ↓
   ┌─────────────┐
   │AgentInstance│ (Created/Updated)
   └──────┬──────┘
          │ Status change
          ↓
   ┌─────────────┐
   │StatusUpdate │ (Event created)
   └──────┬──────┘
          │ Broadcast
          ↓
  ┌────────────────────┐
  │ WebSocketServer    │
  └──────┬─────────────┘
         │ Send to all
         ↓
  ┌────────────────────┐
  │WebSocketConnection │ (N connected clients)
  └──────┬─────────────┘
         │ Receive
         ↓
    ┌──────────┐
    │PWA Client│ (Mobile device)
    └──────────┘
```

---

## Persistence Strategy

| Entity | Persistence Mechanism | Persistence Scope |
|--------|----------------------|-------------------|
| AgentInstance | In-memory only | Runtime (lost on app quit) |
| AgentStatus | In-memory only | Enum definition (code) |
| StatusUpdate | In-memory only | Ephemeral (broadcast and discard) |
| Configuration | YAML file + UserDefaults | Persistent across launches |
| WebSocketConnection | In-memory only | Runtime (lost on disconnect) |

**Rationale**: MVP prioritizes speed. Persistence of agent history deferred to Phase 3+ based on user feedback.

---

## Validation Rules

### AgentInstance
- `pid` must be valid running process (verified via NSWorkspace)
- `workingDirectory` must be absolute path (starts with "/")
- `currentTask` truncated to 200 characters if longer
- `status` must be valid AgentStatus value

### Configuration
- `serverPort` must be 1024-65535 (unprivileged port range)
- `serverHost` must be valid IPv4 address or "0.0.0.0"
- `agentPatterns[].processPattern` must be valid regex

### StatusUpdate
- `instanceId` must reference existing AgentInstance (except "connection_status" type)
- `timestamp` must be current or recent (within 5 seconds tolerance)

---

## Future Extensions (Phase 3+)

**Deferred to post-MVP based on user feedback**:
- Task history (list of completed tasks per instance)
- Output logs (full stdout/stderr capture)
- Performance metrics (task duration, success rate)
- Custom actions (trigger bash/AppleScript from mobile)
- Multi-agent comparison view (side-by-side status)

See [spec.md User Story 4](./spec.md) for parsed output enhancement in Phase 3.
