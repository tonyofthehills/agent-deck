# CLAUDE.md - Agent Deck

**Project-specific guidance for Claude Code when working on Agent Deck**

---

## Project Overview

**Agent Deck** - Stream Deck for AI agents. Monitor Claude Code, Cursor, and other agentic coding tools from your phone. Switch windows with one tap, run custom macros.

**Repository:** `/Users/tonyofthehills/dev/apps/app-009-agent-deck/`

**Platform Strategy:** Hybrid approach
- 🖥️ **Mac**: Native Swift/SwiftUI menubar app
- 📱 **Mobile**: Progressive Web App (iOS/Android/iPad/any browser)
- 🚫 **NOT building**: Native iOS/Android apps until Phase 7+ (after validation)

**Timeline:** 2-week MVP (Phases 1-2) → validate → iterate

---

## Core Principles (Constitution)

### 1. Speed to Market
- **2-week MVP over perfection**
- Ship Phase 1-2 in 2 weeks, no scope creep
- Iterate based on user feedback
- "Done is better than perfect" for MVP

### 2. Mac-First Architecture
- **Native Swift menubar app is the core product**
- Professional macOS integration (menubar, AppleScript, NSWorkspace)
- No Electron, no web wrappers for Mac app
- Single .app bundle (no Node.js dependency for users)

### 3. Mobile Validation Strategy
- **PWA first, native mobile later**
- Works on ALL devices immediately (universal access)
- No app store delays (iterate daily)
- Build native iOS/Android only if 100+ users demand it (Phase 7+)

### 4. Local-First
- **No cloud dependencies in Phase 1-6**
- Local network only (same WiFi)
- No authentication initially
- No external APIs (except monitoring agents)

### 5. Developer Audience
- **Functionality over polish**
- Prioritize working features over UI perfection
- Developers understand technical limitations
- Document clearly, don't over-abstract

---

## YOU ARE ENCOURAGED TO

- **Utilize MCP Servers strategically** (see MCP Server Integration section below)
- Spend extra tokens thinking harder for significant output improvements
- Ask for clarification instead of assuming intent (especially UI/UX)
- Suggest better implementations

## NEVER

- Be lazy by eliminating functionality to force completion
- Make a workaround for a persistant issue that will need to be solved later in development

## ALWAYS

- **📋 Check documentation at the start of every session** - Understand current sprint, current task, and dependencies
- **✅ Update task checkboxes when completing work** - Mark [ ] as [x] and update progress tracking
- **📊 Report progress** at end of session
- Use subagents for implementation as much as possible in accordance with best practices for using claude code subagents
- Check spec docs to ensure alignment
- Add lessons learned to LESSONS_LEARNED.md after fixing unexpected issues

---

## MCP Server Integration

This project uses multiple Model Context Protocol (MCP) servers to enhance development capabilities. Each server has specific strengths - use them strategically.

### Available MCP Servers

#### 1. **Exa Search** (`@modelcontextprotocol/server-exa`)

**Purpose:** Web research, current information, troubleshooting

**Use for:**
- Researching new technologies, libraries, or frameworks
- Finding current best practices and tutorials
- Troubleshooting errors and issues
- Discovering architectural patterns
- General web research

**Tools:**
- `web_search_exa` - Neural web search with quality rankings
- `get_code_context_exa` - Search for programming-specific context

**Example usage:**
```
"Research the latest React Native performance optimization techniques"
"Find best practices for Swift Concurrency with @MainActor"
"How to implement real-time sync with Convex"
```

---

#### 2. **Ref** (`ref-tools-mcp`)

**Purpose:** Agentic documentation search, exploratory learning

**Use for:**
- Exploratory "how to do X" questions
- Discovering best practices within specific libraries
- Finding code examples and patterns
- When you don't know exactly which docs you need
- Token-efficient documentation retrieval

**Strengths:**
- Agentic search-and-read pattern (LLM refines queries)
- Covers 1000s of public repos and documentation sites
- Minimal token usage compared to full doc dumps
- Great for discovering APIs you didn't know existed

**Example usage:**
```
"How do I implement pagination with Convex mutations?"
"Show me best practices for SwiftUI navigation in macOS apps"
"What's the proper way to handle errors in Unity ECS systems?"
```

---

#### 3. **Context7** (`@upstash/context7-mcp`)

**Purpose:** Comprehensive library documentation retrieval

**Use for:**
- Getting detailed API reference for a specific known library
- When you need comprehensive documentation about one library
- Targeted documentation with high token counts (up to 50k tokens)

**Strengths:**
- Deep, comprehensive documentation
- Two-step process: resolve library ID, then fetch docs
- Good for detailed API exploration of a single library

**Tools:**
- `resolve-library-id` - Find Context7-compatible library ID
- `get-library-docs` - Fetch comprehensive documentation

**Example usage:**
```
"Get comprehensive Convex documentation for mutation patterns (use context7)"
"Fetch detailed SwiftUI documentation for @Observable macro (use context7)"
```

---

#### 4. **Pieces** (`pieces`)

**Purpose:** Historical and contextual memory from user's environment

**Use for:**
- Understanding what the user has been working on recently
- Retrieving past interactions and code snippets
- Accessing project-specific context and history
- Creating long-term memories of important breakthroughs

**Tools:**
- `ask_pieces_ltm` - Query historical/contextual information
- `create_pieces_memory` - Save important context for future reference

**Important:** Always provide `chat_llm` parameter (e.g., "claude-sonnet-4-5-20250929")

**Example usage:**
```
"What was I working on in Unity yesterday?" (use pieces)
"Show me the approach I used for authentication in the last session" (use pieces)
```

**Creating Memories:**
Create Pieces memories for:
- Major breakthroughs or bug fixes
- Important architectural decisions
- Complex problem solutions
- Topic/goal changes
- Pre-commit documentation

---

#### 5. **Semgrep** (`semgrep`)

**Purpose:** Security vulnerability scanning and code quality analysis

**Use for:**
- Scanning AI-generated Swift and JavaScript code before committing
- Finding macOS security issues (Keychain, file permissions, URL schemes)
- Checking PWA security (XSS, CORS, CSP violations)
- Validating authentication and session handling
- OWASP Top 10 vulnerability detection

**Tools:**
- `semgrep_scan` - Scan files for security vulnerabilities
- `semgrep_scan_with_custom_rule` - Run custom security rules
- `semgrep_scan_supply_chain` - Check dependency vulnerabilities
- `get_supported_languages` - List supported languages (Swift, JavaScript, etc.)

**CRITICAL - Always scan before committing:**
- AI-generated code (Swift menubar app OR JavaScript PWA)
- Authentication/authorization changes
- WebSocket communication code
- Session management
- File operations
- API endpoint implementations

**Example usage:**
```
"Scan the Swift authentication code for security issues"
"Check the PWA JavaScript for XSS vulnerabilities"
"Run supply chain scan after npm install"
```

**See "Security Scanning with Semgrep MCP" section below for comprehensive usage**

---

### When to Use Which MCP Server

| Scenario | Use This | Why |
|----------|----------|-----|
| "How do I implement X with Y library?" | **Ref** | Exploratory documentation search |
| "What are the latest best practices for X?" | **Exa Search** | Current web research |
| "Get comprehensive docs for Library X" | **Context7** | Deep, targeted documentation |
| "What was I working on yesterday?" | **Pieces** | Historical context |
| "Find tutorials for X technology" | **Exa Search** | Web research |
| "Show me the API for specific function in Library X" | **Ref** → **Context7** | Start with Ref, deep dive with Context7 |
| "Troubleshoot this error message" | **Exa Search** | Current solutions and discussions |
| "How did I solve problem X last week?" | **Pieces** | Historical memory |

---

### Best Practices

**1. Start Broad, Then Focus:**
- Start with **Ref** for exploratory questions
- Use **Exa Search** for broader research
- Deep dive with **Context7** when you know exactly what you need

**2. Be Specific:**
- Include library names and version numbers when known
- Mention the specific technology stack
- Reference error messages verbatim for troubleshooting

**3. Don't Overuse:**
- Don't use MCP servers for basic programming knowledge
- Don't use them for project-specific code (use codebase search instead)
- Don't use them when the answer is in recent context

**4. Create Memories:**
- Use Pieces to save important breakthroughs
- Document complex solutions for future reference
- Create memories before major commits or pivots

**5. Privacy Considerations:**
- Exa Search queries may be logged - avoid API keys/secrets
- Pieces stores data locally - safe for sensitive information
- Context7 and Ref access public documentation only

---

### Typical Workflow Examples

**Starting a new feature:**
1. Use **Exa Search** to research current best practices
2. Use **Ref** to explore relevant library documentation
3. Use **Context7** for deep dive into specific APIs
4. Create a **Pieces memory** when complete

**Troubleshooting an error:**
1. Use **Pieces** to check if you've seen this error before
2. Use **Exa Search** to find recent solutions
3. Use **Ref** to understand the underlying library behavior

**Learning a new library:**
1. Use **Exa Search** for tutorials and getting started guides
2. Use **Ref** for exploratory API discovery
3. Use **Context7** for comprehensive API reference
4. Create **Pieces memories** for important patterns learned

---

## Security Scanning with Semgrep MCP

**CRITICAL: Always scan AI-generated code before committing!**

Agent Deck is a dual-platform project (Swift menubar + JavaScript PWA) requiring security vigilance across both stacks.

### When to Scan

**ALWAYS scan before committing when you:**
1. Generate or modify authentication code (session tokens, API keys)
2. Implement WebSocket communication or real-time updates
3. Add file operations or path handling (Swift menubar app)
4. Work with clipboard or pasteboard monitoring
5. Implement PWA service worker or caching
6. Handle user input in either platform
7. Add npm dependencies (`npm install` for PWA)
8. Implement cross-origin communication (Swift ↔ PWA)

### How to Scan

**Swift menubar app:**
```
Scan these files with semgrep_scan:
[
  {"path": "/absolute/path/to/AgentDeck/Sources/Auth/*.swift"},
  {"path": "/absolute/path/to/AgentDeck/Sources/WebSocket/*.swift"}
]
```

**JavaScript PWA:**
```
Scan these files with semgrep_scan:
[
  {"path": "/absolute/path/to/pwa/src/auth.js"},
  {"path": "/absolute/path/to/pwa/service-worker.js"}
]
```

**Supply chain (after npm install):**
```
cd pwa && run semgrep_scan_supply_chain
```

### Priority Vulnerabilities by Platform

**Swift Menubar App (ERROR severity):**
- Hardcoded API keys or session tokens
- Insecure Keychain usage
- Unsafe URL scheme handling
- UserDefaults for sensitive data
- Command injection in shell operations
- Path traversal in file operations
- Unvalidated WebSocket messages

**JavaScript PWA (ERROR severity):**
- XSS vulnerabilities in dynamic content
- CORS misconfiguration
- CSP bypass opportunities
- Insecure localStorage for tokens
- WebSocket injection attacks
- Unvalidated service worker caching
- DOM-based XSS

**Cross-Platform (ERROR severity):**
- Session token exposure in transit
- Authentication bypass vulnerabilities
- Insecure communication channels
- API credential leakage

### Secure AI Coding Workflow

```
1. Request: "Add WebSocket authentication"
2. AI generates Swift + JavaScript code
3. ⚠️ STOP - Scan both platforms:
   - semgrep_scan: Swift files
   - semgrep_scan: JavaScript files
4. Review findings: Fix all ERROR severity issues
5. Re-scan to verify fixes
6. ✅ Commit only when clean (no ERROR findings)
```

### Project-Specific Custom Rules

**Example: Prevent hardcoded WebSocket URLs**
```yaml
rules:
  - id: hardcoded-websocket-url
    pattern: let wsURL = "ws://..."
    languages: [swift, javascript]
    severity: ERROR
    message: Never hardcode WebSocket URLs - use configuration
    metadata:
      fix: Use environment variables or configuration file
```

**Example: Validate WebSocket messages**
```yaml
rules:
  - id: unvalidated-websocket-message
    pattern: |
      webSocket.onmessage = (event) => {
        ...
        eval(event.data)
      }
    languages: [javascript]
    severity: ERROR
    message: Never execute WebSocket data without validation
```

### Agent Deck Security Checklist

**Swift Menubar App:**
- [ ] Validate all WebSocket messages before processing
- [ ] Use Keychain for session token storage
- [ ] Implement proper URL scheme validation
- [ ] Sanitize clipboard/pasteboard content
- [ ] Validate all file paths
- [ ] Implement request signing for API calls

**JavaScript PWA:**
- [ ] Sanitize all user input for XSS
- [ ] Implement strict CSP headers
- [ ] Validate CORS configuration
- [ ] Use secure cookie flags (httpOnly, secure, sameSite)
- [ ] Validate service worker cache sources
- [ ] Implement XSS protection in WebSocket handlers
- [ ] Use token refresh mechanism

**Cross-Platform:**
- [ ] Encrypt sensitive data in transit
- [ ] Implement proper session management
- [ ] Validate authentication on both platforms
- [ ] Test offline/online state transitions
- [ ] Audit all communication channels

### Quick Reference

| Scenario | Semgrep Command |
|----------|-----------------|
| Scan Swift auth code | `semgrep_scan: Sources/Auth/*.swift` |
| Scan PWA JavaScript | `semgrep_scan: pwa/src/**/*.js` |
| Check WebSocket code | `semgrep_scan: */WebSocket/*` |
| Scan service worker | `semgrep_scan: pwa/service-worker.js` |
| Supply chain (PWA) | `cd pwa && semgrep_scan_supply_chain` |
| Custom rule | `semgrep_scan_with_custom_rule` |

**See workspace CLAUDE.md for comprehensive Semgrep documentation**

---

## SpecKit Integration 🚀

**This project uses SpecKit for spec-driven development.**

### Workflow (Use These Commands)

**Before any coding:**
```bash
# 1. Define principles (30 min) - REQUIRED FIRST
/speckit.constitution

# 2. Create spec from agent-deck-spec-final.md (1 hour)
/speckit.specify

# 3. Generate implementation plan (1 hour)
/speckit.plan

# 4. Break into tasks (30 min)
/speckit.tasks

# 5. Start implementation (iterative)
/speckit.implement [task-name]
```

**Optional enhancement commands:**
- `/speckit.clarify` - Ask structured questions before planning
- `/speckit.analyze` - Check cross-artifact consistency
- `/speckit.checklist` - Quality validation

### SpecKit Files

**.specify/** - SpecKit configuration and artifacts
- `memory/` - Stores constitution, spec, plan, tasks
- `scripts/` - Helper scripts
- `templates/` - Spec templates

**DO NOT modify .specify/ directly** - use slash commands

---

## Tech Stack

### macOS Application (Phase 1-2)
**Language:** Swift 5.7+ (Swift 6 compatible)
**UI:** SwiftUI (native macOS look and feel)
**Frameworks:**
- `Combine` - Reactive state management
- `Network.framework` or `Vapor` - WebSocket server
- `NSWorkspace` - Process monitoring
- `NSAppleScript` - Window management
- `UserDefaults` - Configuration storage

**Dependencies (via Swift Package Manager):**
- `Yams` - YAML parsing for config files
- Optional: `Vapor` - If using for WebSocket (alternative to Network.framework)

**Target:** macOS 12+ (Monterey or later)

### Mobile Interface (Phase 1-2)
**Type:** Progressive Web App (PWA)
**Framework:** Vanilla JavaScript (NO React, NO Vue, NO build step)
**Why vanilla JS:**
- Fast loading on mobile
- No build step = faster iteration
- Simple for 2-week MVP
- Easy to understand

**Files:**
- `index.html` - Mobile UI structure
- `app.js` - WebSocket client + UI logic
- `styles.css` - Mobile-optimized dark mode styles
- `manifest.json` - PWA manifest
- `service-worker.js` - Offline support

**Location:** Embedded in Mac app at `Resources/WebRoot/`

### Backend (Phase 1-2)
**Embedded in Mac app** - No separate server process

**Options:**
1. **Swift Network.framework** (lightweight)
   - Built into Swift
   - No external dependencies
   - Good for simple WebSocket

2. **Vapor** (full-featured)
   - HTTP + WebSocket in one
   - Easier to serve PWA files
   - More overhead

**Choose:** Start with Network.framework, migrate to Vapor if needed

---

## File Structure (Expected)

```
AgentDeck-Mac/                           # Xcode project
├── AgentDeck.xcodeproj
├── Sources/
│   ├── AgentDeckApp.swift              # Main app entry
│   ├── MenuBarController.swift         # Menubar app controller
│   ├── Models/
│   │   ├── AgentInstance.swift         # Agent data model
│   │   ├── CustomAction.swift          # Action data model
│   │   └── Configuration.swift         # App config
│   ├── Services/
│   │   ├── MonitorService.swift        # Process monitoring
│   │   ├── ParserService.swift         # Output parsing
│   │   ├── WebSocketServer.swift       # Real-time communication
│   │   ├── HTTPServer.swift            # Serves PWA files
│   │   ├── WindowManager.swift         # Window focus/switching
│   │   └── ConfigurationService.swift  # YAML config management
│   ├── Views/
│   │   ├── MenuBarView.swift           # Menubar dropdown UI
│   │   ├── SettingsView.swift          # Settings window
│   │   ├── AgentListView.swift         # Agent status list
│   │   └── QRCodeView.swift            # QR code for mobile pairing
│   └── Utilities/
│       ├── AppleScriptRunner.swift     # AppleScript execution
│       ├── Logger.swift                # Logging
│       └── NetworkDiscovery.swift      # Bonjour/mDNS
├── Resources/
│   ├── Assets.xcassets                 # App icons
│   ├── default-config.yaml             # Default configuration
│   ├── default-actions.yaml            # Default custom actions
│   └── WebRoot/                        # ⭐ EMBEDDED PWA
│       ├── index.html
│       ├── app.js
│       ├── styles.css
│       ├── manifest.json
│       ├── service-worker.js
│       └── icons/
│           ├── icon-192.png
│           └── icon-512.png
└── Info.plist

# Root files (existing)
├── .specify/                           # SpecKit artifacts
├── .claude/                            # SpecKit commands
├── agent-deck-spec-final.md            # Full specification
├── README.md                           # Project overview
├── CLAUDE.md                           # This file
└── .gitignore
```

---

## Development Constraints

### Phase 1-2 Focus (MVP - 2 Weeks)

**IN SCOPE:**
- ✅ Monitoring only (no interaction with agents yet)
- ✅ Claude Code process detection
- ✅ Basic output parsing (current task)
- ✅ Window switching (AppleScript)
- ✅ WebSocket server (localhost:3000)
- ✅ PWA mobile interface (basic)
- ✅ QR code pairing
- ✅ Custom actions (basic: AppleScript, Bash)

**OUT OF SCOPE (Phase 3+):**
- ❌ Mobile interaction (approval prompts) - Phase 5
- ❌ Full output parsing (todo list, status line) - Phase 3
- ❌ Multiple agent types (Cursor, Windsurf) - Phase 3
- ❌ Advanced custom actions - Phase 5
- ❌ Native iOS/Android apps - Phase 7-8
- ❌ Code signing/notarization - Phase 6
- ❌ Auto-updates - Phase 6

### Performance Targets

- **CPU**: <2% idle, <5% active
- **Memory**: <100MB RAM
- **Latency**: <500ms status update, <1s window switch
- **Startup**: <2s to menubar ready

### Security Constraints

**Phase 1-2:**
- Local network only (bind to 0.0.0.0:3000)
- No authentication (trust local network)
- No encryption (plain WebSocket, not WSS)
- Accessibility permissions required (for window switching)

**Phase 6+ (Production):**
- Add WSS (TLS) for non-local access
- Consider authentication layer
- Rate limit custom actions

---

## Common Patterns & Best Practices

### SwiftUI Patterns

**Menubar app:**
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

**State management (Combine):**
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

### PWA Patterns

**WebSocket client:**
```javascript
class AgentDeckClient {
    constructor() {
        this.ws = null;
        this.reconnectDelay = 1000;
    }

    connect(url) {
        this.ws = new WebSocket(url);

        this.ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            this.handleUpdate(data);
        };

        this.ws.onclose = () => {
            // Auto-reconnect
            setTimeout(() => this.connect(url), this.reconnectDelay);
        };
    }

    sendFocusCommand(instanceId) {
        this.ws.send(JSON.stringify({
            type: 'focus',
            instanceId: instanceId
        }));
    }
}
```

**Touch-optimized UI:**
```css
/* Mobile-first, dark mode */
:root {
    --bg: #1a1a1a;
    --text: #ffffff;
    --border: #333;
}

.agent-card {
    padding: 1rem;
    margin: 0.5rem;
    background: var(--bg);
    border-left: 4px solid var(--status-color);
    border-radius: 8px;

    /* Touch target size */
    min-height: 44px;
}

.agent-card:active {
    transform: scale(0.98);
    opacity: 0.8;
}
```

---

## Testing Strategy

### Phase 1-2 (MVP)
**Manual testing only** - No automated tests initially

**Test checklist:**
- [ ] Mac app launches and appears in menubar
- [ ] Detects running Claude Code processes
- [ ] WebSocket server accepts connections
- [ ] Mobile PWA loads and connects
- [ ] Window switching works (AppleScript)
- [ ] Status updates appear in real-time (<500ms)
- [ ] Works on iPhone Safari
- [ ] Works on Android Chrome
- [ ] "Add to Home Screen" creates icon

### Phase 3+ (Post-MVP)
**Add automated tests:**
- XCTest for Swift code
- Jest for PWA JavaScript
- Integration tests for WebSocket

---

## Common Pitfalls & How to Avoid

### 1. ❌ Don't Build Native Mobile Apps Yet
**Why:** Wastes 3-4 weeks before validating PWA works
**Instead:** Ship PWA, get users, let them tell you if they need native

### 2. ❌ Don't Use Node.js for Backend
**Why:** Forces users to install Node.js + dependencies
**Instead:** Embed server in Swift app (single .app bundle)

### 3. ❌ Don't Try to Parse All Agent Types Initially
**Why:** Each agent (Cursor, Windsurf) has different output formats
**Instead:** Start with Claude Code only (Phase 1-2), add others in Phase 3

### 4. ❌ Don't Build Mobile Interaction in MVP
**Why:** Adds 1-2 weeks of complexity (PTY wrapper, stdin injection)
**Instead:** Monitoring only in MVP, interaction in Phase 5

### 5. ❌ Don't Use React/Vue for PWA
**Why:** Build step slows iteration, overkill for simple UI
**Instead:** Vanilla JS (fast loading, no build, easy to understand)

### 6. ❌ Don't Bind WebSocket to 127.0.0.1
**Why:** Mobile devices can't connect (different IP)
**Instead:** Bind to 0.0.0.0:3000 (all interfaces on local network)

### 7. ❌ Don't Forget Accessibility Permissions
**Why:** AppleScript window switching requires accessibility access
**Instead:** Prompt user on first launch, document in README

---

## Configuration Management

### YAML Config Files

**Location:** `~/.agent-deck/config.yaml`

**Structure:**
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

custom_actions:
  - id: "open-figma"
    label: "Figma"
    icon: "🎨"
    action: "applescript"
    params:
      script: 'tell application "Figma" to activate'
```

**Loading in Swift:**
```swift
import Yams

struct Configuration: Codable {
    let server: ServerConfig
    let agents: [AgentConfig]
    let customActions: [CustomAction]?
}

func loadConfig() throws -> Configuration {
    let url = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".agent-deck")
        .appendingPathComponent("config.yaml")

    let data = try String(contentsOf: url)
    return try YAMLDecoder().decode(Configuration.self, from: data)
}
```

---

## AppleScript Patterns

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
    // Use lsof or /proc to get working directory
    // Simplified for macOS:
    let task = Process()
    task.launchPath = "/usr/bin/lsof"
    task.arguments = ["-p", "\(pid)", "-a", "-d", "cwd", "-F", "n"]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""

    // Parse lsof output
    // Format: "n/path/to/dir"
    if let line = output.split(separator: "\n").first(where: { $0.hasPrefix("n") }) {
        return String(line.dropFirst())
    }

    return "Unknown"
}
```

---

## WebSocket Communication

### Server (Swift)

**Using Network.framework:**
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

### Client (JavaScript)

```javascript
const ws = new WebSocket('ws://192.168.1.100:3000');

ws.onopen = () => {
    console.log('Connected to Agent Deck');
};

ws.onmessage = (event) => {
    const data = JSON.parse(event.data);

    if (data.type === 'update') {
        updateAgentList(data.instances);
    }
};

ws.onerror = (error) => {
    console.error('WebSocket error:', error);
};

ws.onclose = () => {
    console.log('Disconnected, reconnecting...');
    setTimeout(() => {
        // Reconnect logic
    }, 1000);
};
```

---

## QR Code Generation

**For mobile pairing:**

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
let url = "http://\(localIP):3000"
let qrCode = generateQRCode(from: url)
```

**Get local IP:**
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

## Bonjour/mDNS Service Discovery

**For auto-discovery on local network:**

```swift
import Foundation

class NetworkDiscovery {
    private var netService: NetService?

    func publish(port: Int) {
        netService = NetService(domain: "local.",
                               type: "_agentdeck._tcp.",
                               name: "Agent Deck",
                               port: Int32(port))
        netService?.publish()
    }

    func stop() {
        netService?.stop()
    }
}

// Usage:
let discovery = NetworkDiscovery()
discovery.publish(port: 3000)
```

**Mobile discovery (JavaScript):**
```javascript
// Most browsers don't support mDNS/Bonjour
// Use QR code instead (simpler, more reliable)
```

---

## Error Handling

### Swift

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

### JavaScript (PWA)

```javascript
class ErrorHandler {
    static show(message, details = '') {
        const errorDiv = document.createElement('div');
        errorDiv.className = 'error-toast';
        errorDiv.innerHTML = `
            <strong>Error:</strong> ${message}
            ${details ? `<br><small>${details}</small>` : ''}
        `;
        document.body.appendChild(errorDiv);

        setTimeout(() => errorDiv.remove(), 5000);
    }
}

// Usage:
ws.onerror = (error) => {
    ErrorHandler.show('Connection lost', 'Reconnecting...');
};
```

---

## Logging

### Swift

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

**View logs:**
```bash
# Console.app or:
log stream --predicate 'subsystem == "com.agentdeck.app"'
```

---

## Resources & References

**Official Documentation:**
- Agent Deck Spec: `agent-deck-spec-final.md` (full specification)
- SpecKit Docs: https://speckit.org
- Swift Documentation: https://swift.org/documentation/
- SwiftUI Tutorials: https://developer.apple.com/tutorials/swiftui

**Similar Projects:**
- Touch Portal: https://www.touch-portal.com/
- Stream Deck: https://www.elgato.com/stream-deck
- Omnara: https://omnara.ai/ (competitor analysis)

**Technologies:**
- Swift Package Manager: https://swift.org/package-manager/
- Vapor (if using): https://vapor.codes/
- WebSocket Protocol: https://datatracker.ietf.org/doc/html/rfc6455
- PWA Spec: https://web.dev/progressive-web-apps/

---

## Quick Reference Commands

**When starting work:**
```bash
# 1. Check SpecKit status
specify check

# 2. Start SpecKit workflow
/speckit.constitution    # Define principles
/speckit.specify          # Create spec
/speckit.plan            # Generate plan
/speckit.tasks           # Break into tasks
/speckit.implement       # Start coding

# 3. Xcode project
open AgentDeck-Mac/AgentDeck.xcodeproj

# 4. Run locally
# (Command+R in Xcode)
```

**When testing:**
```bash
# Check running processes
ps aux | grep claude

# Test WebSocket (Terminal 1)
# Run Mac app first

# Test WebSocket (Terminal 2)
wscat -c ws://localhost:3000

# View logs
log stream --predicate 'subsystem == "com.agentdeck.app"'

# Test on iPhone
# 1. Get local IP: ifconfig | grep "inet "
# 2. Open Safari on iPhone: http://[YOUR-IP]:3000
# 3. Tap "Add to Home Screen"
```

---

## Lessons Learned 📚

**IMPORTANT:** See `LESSONS_LEARNED.md` for comprehensive details. Summary of critical patterns below.

### 🔴 FSEvents C Pointer Handling
**Never try to cast eventPaths to CFArray or NSArray.** Use `assumingMemoryBound(to: UnsafePointer<CChar>.self)`.

```swift
let pathsPointer = eventPaths.assumingMemoryBound(to: UnsafePointer<CChar>.self)
for i in 0..<numEvents {
    let path = String(cString: pathsPointer[i])
}
```

**File:** `Services/TranscriptWatcher.swift:58`

### 🔴 @Published with Structs
**Mutating array elements in-place does NOT trigger Combine.** Must replace the element.

```swift
// ❌ WRONG - doesn't trigger @Published
instances[index].currentTask = "new"

// ✅ CORRECT - triggers @Published
var updated = instances[index]
updated.currentTask = "new"
instances[index] = updated
```

**File:** `Services/ProcessMonitor.swift:514-520`

### 🔴 Path Matching
**Don't try to convert directory names to paths.** Read `cwd` from transcript JSON.

```swift
// ✅ Read cwd from JSON, don't derive from directory name
func readCwdFromTranscript(path: String) -> String? {
    // Parse JSONL for "cwd" field
}
```

**File:** `Services/ProcessMonitor.swift:532`

### Pieces Memories Created
Three comprehensive memories saved covering:
1. FSEvents C pointer handling (crashes and fixes)
2. @Published struct replacement pattern (Combine triggering)
3. Complete real-time monitoring architecture

**Access with:** "Show me FSEvents Swift pattern" or "How did I fix @Published?"

---

## Version

**CLAUDE.md Version:** 1.1
**Last Updated:** 2025-01-05
**Agent Deck Phase:** MVP Phase 1-2 (Real-time monitoring complete)
**SpecKit Template:** spec-kit-template-claude-sh-v0.0.79

---

**Remember:** Speed to market. 2-week MVP. Ship, validate, iterate. 🚀

## Active Technologies
- Swift 5.7+ (Swift 6 compatible targeting macOS 12+) (001-mvp)
- FSEvents (macOS file system monitoring)
- Combine (reactive state management)
- WebSocket (real-time PWA updates)

## Recent Changes
- 2025-01-05: ✅ Real-time monitoring complete (FSEvents + Combine + WebSocket)
- 2025-01-05: Added LESSONS_LEARNED.md with critical patterns
- 2025-01-05: Created 3 Pieces memories for future reference
- 001-mvp: Added Swift 5.7+ (Swift 6 compatible targeting macOS 12+)
