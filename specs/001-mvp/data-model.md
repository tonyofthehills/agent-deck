# Data Model - Agent Deck MVP

**Version:** 1.0
**Phase:** 001-mvp
**Last Updated:** 2025-01-05

---

## Overview

This document defines all data entities, their relationships, validation rules, and persistence strategies for Agent Deck MVP (Phases 1-2).

**Key Principles:**
- Local-first (no cloud sync in MVP)
- Swift Codable for native models
- JSON serialization for WebSocket transport
- YAML for user-editable configuration
- localStorage for PWA persistence

---

## Core Entities

### 1. AgentInstance

**Purpose:** Represents a single running AI agent process (e.g., Claude Code, Cursor)

**Swift Model:**
```swift
struct AgentInstance: Identifiable, Codable {
    let id: UUID
    let pid: pid_t
    let name: String                  // "Claude Code"
    let agentType: String              // "claude-code", "cursor", etc.
    let cwd: String                    // Working directory path
    var status: AgentStatus            // idle, thinking, running_tool, error
    var currentTask: String?           // "Editing AppDelegate.swift"
    var modelName: String?             // "claude-sonnet-4-5-20250929"
    var gitBranch: String?             // "001-mvp"
    var subagents: [SubagentInfo]      // Active subagents
    var todos: [TodoItem]              // Todo list
    var lastUpdate: Date
}
```

**Validation Rules:**
- `id`: Must be unique UUID
- `pid`: Must be valid process ID (> 0)
- `name`: Non-empty string, max 100 characters
- `agentType`: Must match known types ("claude-code", "cursor", "windsurf")
- `cwd`: Valid file system path
- `status`: Must be valid AgentStatus enum value
- `currentTask`: Optional, max 500 characters
- `modelName`: Optional, max 100 characters
- `gitBranch`: Optional, max 100 characters
- `subagents`: Array, max 10 items
- `todos`: Array, max 50 items
- `lastUpdate`: Must not be in the future

**JSON Schema (WebSocket):**
```json
{
  "id": "uuid-string",
  "pid": 12345,
  "name": "Claude Code",
  "agentType": "claude-code",
  "cwd": "/Users/dev/project",
  "status": "thinking",
  "currentTask": "Editing AppDelegate.swift",
  "modelName": "claude-sonnet-4-5-20250929",
  "gitBranch": "001-mvp",
  "subagents": [
    {
      "type": "Explore",
      "description": "Searching codebase for authentication patterns",
      "startedAt": "2025-01-05T10:30:00Z"
    }
  ],
  "todos": [
    {
      "content": "Implement authentication",
      "status": "in_progress",
      "activeForm": "Implementing authentication"
    }
  ],
  "lastUpdate": "2025-01-05T10:35:00Z"
}
```

---

### 2. AgentStatus

**Purpose:** Enum representing current agent activity state

**Swift Model:**
```swift
enum AgentStatus: String, Codable {
    case idle         // Waiting for input
    case thinking     // Processing request
    case runningTool  // Executing tool (Bash, Read, etc.)
    case error        // Error state
}
```

**Validation Rules:**
- Must be one of: "idle", "thinking", "runningTool", "error"
- Case-sensitive

**JSON Representation:**
```json
"status": "thinking"
```

---

### 3. SubagentInfo

**Purpose:** Represents an active subagent launched by main agent

**Swift Model:**
```swift
struct SubagentInfo: Codable, Hashable {
    let type: String               // "Explore", "Plan", "general-purpose"
    let description: String        // "Searching for authentication patterns"
    let startedAt: Date
}
```

**Validation Rules:**
- `type`: Non-empty string, max 50 characters
- `description`: Non-empty string, max 500 characters
- `startedAt`: Must not be in the future

**JSON Schema:**
```json
{
  "type": "Explore",
  "description": "Searching for authentication patterns",
  "startedAt": "2025-01-05T10:30:00Z"
}
```

---

### 4. TodoItem

**Purpose:** Represents a task in agent's todo list

**Swift Model:**
```swift
struct TodoItem: Codable, Hashable {
    let content: String            // "Implement authentication"
    let status: TodoStatus         // pending, in_progress, completed
    let activeForm: String         // "Implementing authentication"
}

enum TodoStatus: String, Codable {
    case pending
    case inProgress = "in_progress"
    case completed
}
```

**Validation Rules:**
- `content`: Non-empty string, max 500 characters
- `status`: Must be "pending", "in_progress", or "completed"
- `activeForm`: Non-empty string, max 500 characters

**JSON Schema:**
```json
{
  "content": "Implement authentication",
  "status": "in_progress",
  "activeForm": "Implementing authentication"
}
```

---

### 5. CustomAction

**Purpose:** User-defined command/script that can be triggered from PWA

**Swift Model:**
```swift
struct CustomAction: Identifiable, Codable {
    let id: UUID
    let label: String              // "Open Figma"
    let icon: String               // "🎨" or "design_services"
    let actionType: ActionType     // applescript, bash, url, shortcuts
    let params: ActionParams       // Type-specific parameters
    var enabled: Bool
}

enum ActionType: String, Codable {
    case applescript
    case bash
    case url
    case shortcuts
}

struct ActionParams: Codable {
    // AppleScript
    var script: String?            // AppleScript source code

    // Bash
    var command: String?           // Shell command
    var args: [String]?            // Command arguments

    // URL
    var urlString: String?         // URL to open
    var scheme: String?            // URL scheme (optional validation)

    // Shortcuts (Phase 5+)
    var shortcutName: String?      // Shortcut name
    var shortcutParams: [String: String]?  // Input parameters
}
```

**Validation Rules:**
- `id`: Must be unique UUID
- `label`: Non-empty string, max 50 characters, no newlines
- `icon`: Single emoji (1-2 characters) OR Material Symbols icon name (max 50 chars)
- `actionType`: Must be "applescript", "bash", "url", or "shortcuts"
- `enabled`: Boolean

**ActionParams Validation:**
- **AppleScript**: `script` required, non-empty, max 10,000 characters
- **Bash**: `command` required, non-empty, max 1,000 characters; `args` optional array
- **URL**: `urlString` required, valid URL format, allowed schemes: http, https, file, mailto, tel
- **Shortcuts**: `shortcutName` required (Phase 5+)

**JSON Schema:**
```json
{
  "id": "uuid-string",
  "label": "Open Figma",
  "icon": "🎨",
  "actionType": "applescript",
  "params": {
    "script": "tell application \"Figma\" to activate"
  },
  "enabled": true
}
```

**YAML Configuration Example:**
```yaml
customActions:
  - id: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890"
    label: "Open Figma"
    icon: "🎨"
    actionType: "applescript"
    params:
      script: 'tell application "Figma" to activate'
    enabled: true

  - id: "B2C3D4E5-F6A7-8901-BCDE-F12345678901"
    label: "Git Status"
    icon: "📊"
    actionType: "bash"
    params:
      command: "/usr/bin/git"
      args: ["status", "--short"]
    enabled: true

  - id: "C3D4E5F6-A7B8-9012-CDEF-123456789012"
    label: "GitHub"
    icon: "🐙"
    actionType: "url"
    params:
      urlString: "https://github.com"
    enabled: true
```

---

### 6. ActionResult

**Purpose:** Result of custom action execution

**Swift Model:**
```swift
struct ActionResult: Codable {
    let actionId: UUID
    let success: Bool
    let output: String?            // stdout or success message
    let error: String?             // stderr or error message
    let executedAt: Date
}
```

**Validation Rules:**
- `actionId`: Must be valid UUID matching existing CustomAction
- `success`: Boolean
- `output`: Optional, max 10,000 characters
- `error`: Optional, max 10,000 characters
- `executedAt`: Must not be in the future

**JSON Schema:**
```json
{
  "actionId": "uuid-string",
  "success": true,
  "output": "Application 'Figma' activated",
  "error": null,
  "executedAt": "2025-01-05T10:45:00Z"
}
```

---

### 7. Configuration

**Purpose:** Application configuration loaded from YAML

**Swift Model:**
```swift
struct Configuration: Codable {
    let server: ServerConfig
    let agents: [AgentConfig]
    let customActions: [CustomAction]
}

struct ServerConfig: Codable {
    let port: UInt16               // 3000-65535
    let host: String               // "0.0.0.0" or "127.0.0.1"
}

struct AgentConfig: Codable {
    let name: String               // "Claude Code"
    let processPattern: String     // "claude.*code" (regex)
    let enabled: Bool
}
```

**Validation Rules:**
- **ServerConfig:**
  - `port`: 3000-65535 (avoid system ports 0-1023)
  - `host`: Valid IP address ("0.0.0.0", "127.0.0.1") or hostname

- **AgentConfig:**
  - `name`: Non-empty, max 100 characters
  - `processPattern`: Valid regex pattern, max 200 characters
  - `enabled`: Boolean

- **Configuration:**
  - `agents`: At least 1 enabled agent
  - `customActions`: Max 20 actions (UI limit)

**YAML Schema:**
```yaml
server:
  port: 3000
  host: "0.0.0.0"

agents:
  - name: "Claude Code"
    processPattern: "claude.*code"
    enabled: true

  - name: "Cursor"
    processPattern: "Cursor"
    enabled: false

customActions:
  - id: "uuid-1"
    label: "Open Figma"
    icon: "🎨"
    actionType: "applescript"
    params:
      script: 'tell application "Figma" to activate'
    enabled: true
```

**Default Configuration:**
```yaml
server:
  port: 3000
  host: "0.0.0.0"

agents:
  - name: "Claude Code"
    processPattern: "claude.*code"
    enabled: true

customActions: []
```

---

## Entity Relationships

```
Configuration
├── ServerConfig (1:1)
├── AgentConfig[] (1:N)
└── CustomAction[] (1:N)

AgentInstance
├── AgentStatus (1:1)
├── SubagentInfo[] (1:N)
└── TodoItem[] (1:N)

CustomAction
└── ActionResult (1:N) [execution history, not persisted in MVP]
```

**Key Relationships:**
- Each `Configuration` has one `ServerConfig`
- Each `Configuration` has 1-10 `AgentConfig` entries
- Each `Configuration` has 0-20 `CustomAction` entries
- Each `AgentInstance` has 0-10 `SubagentInfo` entries
- Each `AgentInstance` has 0-50 `TodoItem` entries
- Each `CustomAction` can generate multiple `ActionResult` objects (not persisted)

---

## Persistence Strategy

### Mac App (Swift)

**Configuration:**
- **Location:** `~/.agent-deck/config.yaml`
- **Format:** YAML (human-editable)
- **Library:** Yams (Swift YAML parser)
- **Frequency:** Load on startup, reload on file change (FSEvents)

**Agent Instances:**
- **Storage:** In-memory only (transient)
- **Source:** Derived from running processes (NSWorkspace)
- **Lifecycle:** Created on process detection, removed on process exit

**Custom Actions:**
- **Storage:** Embedded in `config.yaml` under `customActions` key
- **Updates:** Write to `config.yaml`, reload configuration

### PWA (JavaScript)

**Panel State:**
- **Storage:** localStorage
- **Key:** `agentDeckPanelState`
- **Format:** JSON
- **Data:**
  ```json
  {
    "panelHeight": 300,
    "visibleButtons": 12
  }
  ```

**Connection State:**
- **Storage:** sessionStorage (cleared on tab close)
- **Key:** `agentDeckConnection`
- **Data:**
  ```json
  {
    "lastConnectedUrl": "ws://192.168.1.100:3000",
    "autoReconnect": true
  }
  ```

**No Persistence:**
- Agent instances (received via WebSocket, display-only)
- Custom actions (received via WebSocket, display-only)

---

## Data Flow

### 1. App Startup (Mac)

```
1. Load config.yaml → Configuration struct
2. Start WebSocket/HTTP servers (ServerConfig.port)
3. Start process monitoring (filter by AgentConfig.processPattern)
4. Load CustomAction[] from config.yaml
5. Broadcast initial state to connected PWA clients
```

### 2. Agent Detection (Mac)

```
1. NSWorkspace.runningApplications → filter by processPattern
2. Read transcript file → parse current task, model, branch, todos, subagents
3. Create/update AgentInstance in-memory
4. Broadcast "update" message via WebSocket
```

### 3. Custom Action Execution (Mac → PWA)

```
1. PWA: User taps action button
2. PWA → Mac: WebSocket message { type: "execute_action", actionId: "uuid" }
3. Mac: Find CustomAction by ID
4. Mac: Execute based on actionType (AppleScript, Bash, URL)
5. Mac: Create ActionResult
6. Mac → PWA: WebSocket message { type: "action_result", result: {...} }
7. PWA: Show success/failure toast
```

### 4. Configuration Changes

```
1. User edits ~/.agent-deck/config.yaml
2. FSEvents detects file change
3. ConfigManager reloads YAML
4. Update in-memory Configuration
5. Restart services if server config changed
6. Broadcast "actions" message with updated CustomAction[]
```

---

## Validation Examples

### Valid AgentInstance
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "pid": 54321,
  "name": "Claude Code",
  "agentType": "claude-code",
  "cwd": "/Users/dev/apps/app-009-agent-deck",
  "status": "thinking",
  "currentTask": "Generating data-model.md",
  "modelName": "claude-sonnet-4-5-20250929",
  "gitBranch": "001-mvp",
  "subagents": [],
  "todos": [
    {
      "content": "Generate data-model.md",
      "status": "in_progress",
      "activeForm": "Generating data-model.md"
    }
  ],
  "lastUpdate": "2025-01-05T10:50:00Z"
}
```

### Valid CustomAction (AppleScript)
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "label": "Open Figma",
  "icon": "🎨",
  "actionType": "applescript",
  "params": {
    "script": "tell application \"Figma\" to activate"
  },
  "enabled": true
}
```

### Invalid CustomAction (Missing Required Field)
```json
{
  "id": "invalid",
  "label": "Broken Action",
  "icon": "❌",
  "actionType": "bash",
  "params": {
    // ERROR: Missing "command" field for bash action
  },
  "enabled": true
}
```

**Validation Error:**
```
CustomAction validation failed:
- actionType "bash" requires params.command (non-empty string)
```

---

## Future Considerations (Post-MVP)

### Phase 3+: Full Parsing
- Add `StatusLineData` struct (memory usage, tool execution, recent activity)
- Expand `TodoItem` with timestamps, dependencies

### Phase 5+: Mobile Interaction
- Add `ApprovalRequest` struct (for yes/no prompts from agent)
- Add `InputRequest` struct (for text input from mobile)

### Phase 6+: Cloud Sync
- Add `cloudSyncEnabled` flag to Configuration
- Add `lastSyncedAt` timestamp to entities
- Add conflict resolution strategy

### Phase 7+: Native Mobile Apps
- Swift models shared between macOS and iOS (Swift Package)
- CoreData for offline persistence on mobile

---

## Appendix: JSON Schema Definitions

**Full WebSocket Message Schema** → See `contracts/websocket-protocol.md`

**YAML Configuration Schema** → See `default-config.yaml` in Resources/

---

**Document Version:** 1.0
**Generated:** 2025-01-05
**Phase:** 001-mvp (Phases 1-2)
**SpecKit Template:** spec-kit-template-claude-sh-v0.0.79
