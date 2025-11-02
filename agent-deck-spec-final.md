# Agent Deck - Product Specification

**📱 STRATEGIC DECISION: Hybrid Approach**

> **Launch Strategy:** Native Mac App + Progressive Web App (PWA) Mobile
>
> **Timeline:** 2 weeks to launch → validate → native mobile only if users demand it
>
> **Why?** Speed to market (2 weeks vs 6 weeks), universal mobile access (iOS/Android/iPad/any browser), zero app store friction, validate before investing in native mobile apps.
>
> **Native Mobile Apps:** Build iOS/Android apps in Phase 7-8 (Month 3+) ONLY after 100+ active users validate demand.

---

## Overview
A local network-based dashboard that monitors multiple agentic coding tool instances (Claude Code, Cursor, Codex, etc.) and provides real-time status visibility with one-tap window switching and custom macro execution from a mobile device.

**Product Name:** Agent Deck (agent-deck.dev)

**Positioning:** Stream Deck for AI agents - Your entire dev workflow in your pocket. Monitor agents, run macros, control your Mac.

**Market Timing:** Launching to capture the agentic coding wave (Cursor 2.0 agent mode, Claude Code expansion, rising agent tooling ecosystem).

## Platform Strategy

### Hybrid Approach: Native Mac + Progressive Web App

**Phase 1 (Launch - Weeks 1-2): Mac Native + Web Mobile**
- **Mac**: Native Swift/SwiftUI menubar application
- **Mobile**: Progressive Web App (works on iPhone/Android/iPad immediately)
- **Goal**: Ship in 2 weeks to catch the Cursor 2.0 hype window

**Phase 2 (After Validation - Month 3+): Native Mobile Apps**
- **iOS**: Native Swift/SwiftUI (share code with Mac app)
- **Android**: React Native or Kotlin
- **Goal**: Premium mobile experience after market validation

### Why This Approach?

**Speed to Market:**
- Native Mac app: 1 week (Swift expertise)
- PWA mobile interface: 3 days
- **Total: ~2 weeks to launch** vs. 4-6 weeks for full native across platforms

**Mac App Must Be Native:**
- ✅ Menubar app (can't do with web)
- ✅ AppleScript/window management (easier with Swift)
- ✅ Process monitoring (native system calls)
- ✅ Accessibility permissions (requires native)
- ✅ Professional feel (expected for dev tools)
- ✅ Background operation (no terminal required)

**Mobile Can Start Simple:**
- PWA handles remote control needs perfectly
- Works on ALL devices instantly (iOS/Android/iPad/any browser)
- No app store approval delays
- Easy iteration and immediate user testing
- Users care about functionality first, native feel second

**Easy Upgrade Path:**
```
Week 1-2:   Mac app (Swift) + Web mobile (works everywhere)
Week 3-4:   Validate, get users, iterate
Month 2-3:  iOS app (Swift - share 30-40% code with Mac!)
Month 4:    Android app (React Native or Kotlin)
```

**Competitive Advantage:**
- Touch Portal started Windows-only with basic mobile apps
- Agent Deck starts Mac-first (better for dev audience) with universal mobile access
- Polishing happens after validation, not before

## Core Requirements

### 1. Process Monitoring System
**Objective**: Detect and track all running agentic coding tool instances on macOS

**Requirements**:
- Monitor processes for Claude Code, Cursor, Windsurf, and other configurable agents
- Track per-instance metadata:
  - Process ID (PID)
  - Working directory
  - Current status (idle, working, done, error)
  - Current task description (extracted from stdout/logs)
  - Todo list (parsed from output)
  - Status line (parsed from output)
  - Last activity timestamp
  - Window/application identifier for focus switching

**Claude Code Output Parsing**:
- Parse stdout/logs to extract three distinct sections:
  1. **Current task line**: Look for "Currently:" or active task indicators
  2. **Todo list**: Parse markdown-style checklist (lines starting with `- [ ]` or `- [x]`)
  3. **Status line**: Last line of output or designated status message
- Each section stored separately in instance object for independent toggling
- Handle multi-line todo items
- Detect completion status (checked vs unchecked items)

**Implementation Notes**:
- Use Node.js `ps-list` or `ps-node` for process enumeration
- Poll every 1-2 seconds for status changes
- Parse agent output via configurable regex patterns per agent type
- Support plugin architecture for new agent types

### 2. Real-Time Communication Layer
**Objective**: Sync status updates to mobile device with <500ms latency

**Requirements**:
- WebSocket server embedded in Mac app
- Broadcast status updates when any instance state changes
- Receive focus commands from mobile client
- Receive custom action execution commands from mobile client
- Handle multiple concurrent mobile clients
- Auto-reconnect on connection loss

**Technical Stack**:
- Swift `Network.framework` for WebSocket server (or embedded Vapor)
- Serve on `0.0.0.0:3000` (configurable port)
- mDNS/Bonjour for easy device discovery on local network
- CORS enabled for local network access

### 3. Mac Application Interface
**Objective**: Native menubar app for seamless macOS integration

**Requirements**:

**Menubar Presence:**
- Icon in macOS menubar (status bar)
- Icon changes color based on agent status:
  - Gray: No active agents
  - Blue: Agents working
  - Green: All agents idle/done
  - Red: Agent errors
- Badge count showing number of active agents (optional)

**Menubar Dropdown:**
- Click icon to show dropdown with:
  - Agent status list (compact view)
  - Quick actions (configurable shortcuts)
  - "Open Settings" button
  - "View Mobile Interface" (opens browser to local URL)
  - Server status indicator
  - QR code for mobile pairing

**Settings Window:**
- Preferences panel with tabs:
  - **General**: Server port, auto-start on login
  - **Agents**: Configure monitored agent types
  - **Actions**: Visual action editor/manager
  - **Mobile**: Network settings, QR code display
  - **About**: Version info, credits, GitHub link

**System Integration:**
- Launch at login (optional)
- Dock icon (hidden by default, menubar only)
- Native macOS notifications for agent events
- Keyboard shortcuts for common actions (optional)

**Visual Design:**
- SwiftUI native look and feel
- Dark mode support (automatic)
- SF Symbols for icons
- System fonts
- Matches macOS Big Sur+ design language

### 4. Mobile Web Interface
**Objective**: Touch-optimized list view displaying detailed agent output and custom controls

**Requirements**:

**Agent Monitoring Section**:
- Vertical list layout (full-width items)
- Per-instance list item showing:
  - **Status indicator bar** (color-coded left border, 4px)
  - **Header row**: Agent type, working directory, timestamp
  - **Currently working on** (toggleable): The current task line from Claude Code
  - **Todo list** (toggleable): Bullet list of remaining tasks
  - **Custom status line** (toggleable): The status message (e.g., "3/5 tests passing")
- Tap list item to focus that instance's window on Mac

**Custom Actions Section**:
- Grid or list of custom action buttons below agent monitors
- Each button shows:
  - Icon/emoji
  - Label
  - Optional status indicator (for stateful actions)
- Buttons organized in configurable groups/categories
- Long-press for action options/confirmation (for dangerous actions)
- Visual feedback on tap (haptic + animation)

**Settings Panel** (slide-out or bottom sheet):
- Toggle switches for agent display:
  - ☑️ Show current task
  - ☑️ Show todo list
  - ☑️ Show status line
- Custom button visibility toggles
- Settings persist to localStorage

**UI States**:
- Status color coding:
  - **Idle**: Gray (#888)
  - **Working**: Blue (#4a9eff) with subtle left-border animation
  - **Done**: Green (#4ade80) with pulse on left border
  - **Error**: Red (#ff6b6b)
- Long text displays without wrapping (single-line truncation or full display based on setting)
- Smooth expand/collapse animation when toggling sections
- PWA manifest for "Add to Home Screen" capability
- Dark mode UI (default)
- Connection status indicator (top bar)

**UI Layout Example**:
```
┌─────────────────────────────────────┐
│ ● Connected          [⚙️ Settings] │ ← Top bar
├─────────────────────────────────────┤
│ ▌Claude Code · ~/my-app      2:34pm│ ← Agent (tap to focus)
│ ▌Currently: Writing auth tests     │ ← Current task (toggle)
│ ▌Todo:                              │ ← Todo list (toggle)
│ ▌  • Implement password hashing    │
│ ▌  • Add email verification        │
│ ▌  • Set up session management     │
│ ▌Status: 3/5 tests passing         │ ← Status line (toggle)
├─────────────────────────────────────┤
│ ▌Cursor · ~/other-project   2:31pm │
│ ▌Currently: Refactoring API routes │
│ ▌Status: Build successful          │
├─────────────────────────────────────┤
│           Custom Actions            │ ← Section header
├─────────────────────────────────────┤
│ 🎨 Figma      📝 Commit    🍅 Break │ ← Custom buttons
│ 📊 Dashboard  🧪 Run Tests  🔄 Pull │
└─────────────────────────────────────┘
```

**UI Framework**: Vanilla JS + CSS (no build step for simplicity)

**Display Settings Management**:

LocalStorage Schema:
```javascript
{
  displaySettings: {
    showCurrentTask: true,
    showTodoList: true,
    showStatusLine: true,
    showCustomActions: true
  }
}
```

Settings Panel:
- Gear icon in top right
- Slide-out panel with toggle switches
- Changes apply immediately (no save button needed)
- Default: all enabled

### 5. Window Management System
**Objective**: Focus/activate the correct window when user taps an instance card

**Requirements**:
- Execute AppleScript to focus window by PID
- Handle different application types:
  - Terminal (built-in Terminal.app, iTerm2, Warp)
  - VS Code
  - Cursor
  - Standalone Claude Code app
- Switch to correct macOS Space if needed
- Bring window to front and focus input
- Return success/failure status to mobile client
- Graceful degradation if accessibility permissions not granted

**Implementation**:
- Use Node.js `child_process.exec` to run AppleScript
- Maintain PID-to-window mapping
- Cache window IDs for faster switching

### 6. Custom Actions System
**Objective**: Enable user-defined macros and shortcuts executable from mobile

**Requirements**:

**Action Types**:
- `applescript`: Execute AppleScript commands
- `bash`: Run bash commands
- `keyboard`: Send keyboard shortcuts (using AppleScript or robotjs)
- `url`: Open URLs in default browser
- `http`: Make HTTP requests to local services
- `multi`: Execute multiple actions in sequence
- `agent-wait-idle`: Wait for all/specific agents to finish
- `agent-execute`: Run command in agent's working directory

**Action Configuration**:
- YAML-based configuration file (`~/.agent-deck/custom-actions.yaml`)
- Hot-reload on config file changes
- Validation on load with helpful error messages

**Action Schema**:
```yaml
custom_actions:
  - id: "unique-action-id"
    label: "Display Name"
    icon: "🎨"  # emoji or icon identifier
    group: "Development"  # optional grouping
    action: "applescript"
    params:
      script: |
        tell application "Figma" to activate
    confirmation: false  # require mobile confirmation before executing
    
  - id: "git-commit-all"
    label: "Commit All"
    icon: "📝"
    group: "Git"
    action: "bash"
    params:
      command: "git add . && git commit -m 'WIP'"
      cwd: "~/projects/current"
    confirmation: true
    
  - id: "review-ready"
    label: "Review Ready"
    icon: "✅"
    action: "multi"
    steps:
      - action: "agent-wait-idle"
      - action: "bash"
        params:
          command: "git diff > /tmp/changes.diff"
      - action: "applescript"
        params:
          script: 'tell application "Cursor" to activate'
```

**Agent-Aware Actions**:
- Actions can query agent state
- Actions can wait for agents to reach specific states
- Actions can execute commands in agent working directories
- Actions can trigger based on agent events (e.g., "on agent done")

**Security**:
- Mark dangerous actions requiring confirmation
- Whitelist/blacklist commands
- Execution logging for audit trail
- Optional action execution approval required on Mac

**Action Execution Flow**:
1. Mobile sends action execution request
2. Server validates action exists and user has permission
3. If confirmation required, prompt on mobile
4. Execute action and capture output
5. Stream output/status back to mobile in real-time
6. Log execution to history

**Action Library/Marketplace** (Future):
- Import/export action configs
- Community-contributed action packs
- Preset collections (Git workflows, Figma shortcuts, etc.)
- Action templates with parameter prompts

### 7. Configuration System
**Objective**: Allow user customization without code changes

**Requirements**:
- YAML or JSON config file (`~/.agent-deck/config.yaml`)
- Configurable settings:
  - Port number
  - Poll interval (ms)
  - Agent definitions (process patterns, log paths, status parsers)
  - UI theme colors
  - Window focus behavior
  - Custom action configurations
- Hot-reload config without restart
- CLI command to edit config
- Config validation with helpful error messages

**Default Agent Definitions**:
```yaml
agents:
  - name: "Claude Code"
    process_pattern: "claude.*code"
    log_path: "~/.claude/logs"
    status_patterns:
      working: ["Analyzing", "Writing", "Running"]
      done: ["Complete", "Finished", "Success"]
      error: ["Error", "Failed"]
  
  - name: "Cursor"
    process_pattern: "Cursor"
    # ... similar structure
```

### 8. Logging & Debugging
**Requirements**:
- Log all events to console with timestamps
- Log levels: DEBUG, INFO, WARN, ERROR
- Store recent logs in memory (last 100 entries)
- Expose `/logs` endpoint for troubleshooting
- Log custom action executions with output
- Display server startup info (local IP, QR code for easy mobile access)

---

## Architecture

### Technology Stack

**macOS Application (Native Swift)** - Phase 1
- SwiftUI for menubar UI and settings
- Combine for reactive state management
- Network.framework (or Vapor) for embedded WebSocket server
- NSWorkspace for process monitoring
- NSAppleScript for window management and automation
- UserDefaults for configuration storage
- YAML parsing via Swift libraries (Yams)
- **Distribution**: Single .app bundle (no Node.js dependency)

**Mobile Interface (Progressive Web App)** - Phase 1
- Vanilla JavaScript (minimal dependencies, fast loading)
- WebSocket client for real-time communication
- Service Workers for offline capability
- PWA manifest for "Add to Home Screen"
- Works on iOS, Android, iPad, any modern browser - **zero app store friction**
- Native feel with proper viewport and touch handling
- Installable on home screen (iOS Safari 14+, Chrome 90+)
- **Embedded in Mac app**: Served from Resources/WebRoot folder
- **Why PWA First:**
  - ✅ Works everywhere immediately (no platform-specific builds)
  - ✅ No app store approval delays (ship updates instantly)
  - ✅ Users can try it in 30 seconds (scan QR code)
  - ✅ Easy iteration based on feedback
  - ✅ Cross-platform for free
  - ✅ "Good enough" for remote control use case

**Future: Native Mobile Apps (Phase 7-8, After Validation)**
- **iOS (Phase 7)**: Native SwiftUI app
  - Share models/services with Mac app (30-40% code reuse)
  - Premium iOS features (haptics, widgets, ShareSheet)
  - App Store distribution
  - Build only after 100+ active users validate demand

- **Android (Phase 8)**: React Native or Kotlin
  - Material Design UI
  - Google Play distribution
  - Build after successful iOS launch

**Backend (Embedded in Mac App)**
- No separate server process required
- WebSocket server built into Swift app using Network.framework
- Cleaner for users: just install one .app, it handles everything
- Alternative: Embedded Vapor framework if more HTTP features needed

### File Structure

**macOS Application (Phase 1):**
```
AgentDeck-Mac/
├── AgentDeck.xcodeproj
├── Sources/
│   ├── AgentDeckApp.swift       # Main app entry point
│   ├── MenuBarController.swift  # Menubar app controller
│   ├── Models/
│   │   ├── AgentInstance.swift  # Agent data model
│   │   ├── CustomAction.swift   # Action data model
│   │   └── Configuration.swift  # App configuration
│   ├── Services/
│   │   ├── MonitorService.swift     # Process monitoring
│   │   ├── ParserService.swift      # Output parsing
│   │   ├── WebSocketServer.swift    # Real-time communication (Network.framework)
│   │   ├── HTTPServer.swift         # Serves PWA files (embedded)
│   │   ├── WindowManager.swift      # Window focus/switching
│   │   ├── ActionExecutor.swift     # Custom action execution
│   │   └── ConfigurationService.swift # YAML config management
│   ├── Views/
│   │   ├── MenuBarView.swift        # Menubar dropdown UI
│   │   ├── SettingsView.swift       # Settings window
│   │   ├── AgentListView.swift      # Agent status list
│   │   ├── ActionEditorView.swift   # Action configuration UI
│   │   └── QRCodeView.swift         # QR code for mobile pairing
│   └── Utilities/
│       ├── AppleScriptRunner.swift  # AppleScript execution
│       ├── Logger.swift             # Logging utilities
│       └── NetworkDiscovery.swift   # Bonjour/mDNS
├── Resources/
│   ├── Assets.xcassets           # App icons, images
│   ├── default-config.yaml       # Default configuration
│   ├── default-actions.yaml      # Default custom actions
│   └── WebRoot/                  # ⭐ EMBEDDED PWA (Phase 1)
│       ├── index.html            # Mobile interface
│       ├── app.js                # WebSocket client & UI logic
│       ├── styles.css            # Mobile-optimized styles
│       ├── manifest.json         # PWA manifest
│       ├── service-worker.js     # Offline support
│       └── icons/                # PWA icons (various sizes)
│           ├── icon-192.png
│           └── icon-512.png
└── Info.plist

# Note: PWA is embedded IN the Mac app, not a separate project
# Users access it by:
#   1. Opening Mac app menubar → "View Mobile Interface" → Shows QR code
#   2. Scanning QR code on phone → Opens http://[mac-ip]:3000
#   3. "Add to Home Screen" on phone → Works like native app
```

**Future: Native Mobile Apps (Phase 7-8, After Validation)**
```
AgentDeck-iOS/                 # Native iOS app (Phase 7 - Month 3+)
├── AgentDeck-iOS.xcodeproj
├── Shared/                    # ⭐ Share 30-40% of code with Mac app
│   ├── Models/
│   │   ├── AgentInstance.swift   # Reused from Mac app
│   │   └── CustomAction.swift    # Reused from Mac app
│   └── Services/
│       └── WebSocketClient.swift  # Shared networking
└── Views/
    └── (iOS-specific SwiftUI views)

AgentDeck-Android/             # Android app (Phase 8 - Month 4+)
├── app/
│   └── src/
│       └── (React Native or Kotlin)
└── package.json (if React Native)

# Build native mobile apps ONLY after:
#   - 100+ active users
#   - Validated product-market fit
#   - User feedback confirms need for native features
```

**Development Note:**
- Phase 1: Single codebase (Mac app with embedded PWA)
- Phase 7: Two codebases (Mac app + iOS app with shared Swift code)
- Phase 8: Three codebases (Mac, iOS, Android)

### API Endpoints

**HTTP Endpoints**:
- `GET /` - Serve mobile web interface
- `GET /status` - JSON status of all instances
- `GET /logs` - Recent server logs
- `GET /config` - Current configuration
- `GET /actions` - List of available custom actions
- `POST /actions/:id/execute` - Execute a custom action (with body params)

**WebSocket Events**:
- **Server → Client**:
  - `update`: Full instance status update
  - `instance_change`: Single instance status change
  - `connection_status`: Server health info
  - `action_start`: Custom action execution started
  - `action_progress`: Custom action progress update
  - `action_complete`: Custom action finished
  - `action_error`: Custom action failed

- **Client → Server**:
  - `focus`: Request to focus instance by ID
  - `execute_action`: Request to execute custom action
  - `ping`: Keep-alive

### Data Models

**Instance Object**:
```typescript
{
  id: string,              // Unique identifier (PID-based)
  name: string,            // Display name
  agent_type: string,      // "claude-code", "cursor", etc.
  pid: number,
  cwd: string,             // Working directory
  status: "idle" | "working" | "done" | "error",
  
  // Parsed output sections (all optional/null if not available)
  current_task: string | null,      // "Writing auth tests"
  todo_list: TodoItem[] | null,     // [{ text: "...", done: bool }]
  status_line: string | null,       // "3/5 tests passing"
  
  last_active: timestamp,
  window_id: string | null // For focus switching
}

interface TodoItem {
  text: string,
  done: boolean
}
```

**Custom Action Object**:
```typescript
{
  id: string,
  label: string,
  icon: string,
  group?: string,
  action: "applescript" | "bash" | "keyboard" | "url" | "http" | "multi" | "agent-wait-idle" | "agent-execute",
  params: Record<string, any>,
  confirmation: boolean,
  enabled: boolean
}
```

**Action Execution Result**:
```typescript
{
  action_id: string,
  status: "success" | "error" | "cancelled",
  output?: string,
  error?: string,
  execution_time_ms: number,
  timestamp: number
}
```

---

## Implementation Phases

**Strategic Timeline: 2 Weeks to Launch → Validate → Scale**

### Phase 1: Mac App MVP (Week 1) 🚀 LAUNCH CRITICAL
**Goal:** Professional native Mac app with core monitoring

- [ ] SwiftUI menubar app skeleton
- [ ] Menubar icon with status colors
- [ ] Basic agent process monitoring (Claude Code only)
- [ ] Agent status display in menubar dropdown
- [ ] Embedded WebSocket server (Network.framework)
- [ ] Embedded HTTP server for PWA files
- [ ] Settings window (basic: port, auto-start)
- [ ] Configuration file handling (YAML)
- [ ] Local network server running on configurable port
- [ ] QR code generation for mobile pairing
- [ ] Bonjour/mDNS service announcement

**Success Criteria:**
- ✅ Mac app runs from menubar (no terminal required)
- ✅ Detects running Claude Code instances
- ✅ Displays agent status in menubar dropdown
- ✅ WebSocket server accepts connections
- ✅ HTTP server serves static files

### Phase 2: PWA Mobile + Window Switching (Week 2) 🚀 LAUNCH CRITICAL
**Goal:** Full mobile experience working on all devices

- [ ] PWA mobile web interface (index.html, app.js, styles.css)
- [ ] PWA manifest and service worker
- [ ] Real-time WebSocket client
- [ ] Mobile agent list with status display
- [ ] Touch-optimized UI with color-coded status
- [ ] AppleScript window switching implementation
- [ ] Tap-to-focus window functionality
- [ ] Basic parsing (current task display)
- [ ] Connection status indicator
- [ ] "Add to Home Screen" functionality verified
- [ ] Error handling & auto-reconnect logic
- [ ] Dark mode mobile UI

**Success Criteria:**
- ✅ Mobile web interface loads on iPhone/Android
- ✅ Real-time status updates (<500ms latency)
- ✅ Window switching works reliably
- ✅ PWA installable on home screen
- ✅ Works offline after initial load

**🎯 END OF WEEK 2: SHIP TO FIRST USERS**
- Launch on Show HN
- Share with Claude Code community
- Gather initial feedback
- Monitor for critical bugs

### Phase 3: Enhanced Parsing & Polish (Week 3-4)
**Goal:** Complete output parsing and multi-agent support

- [ ] Full output parsing (todo list, status line)
- [ ] Support for multiple agent types (Cursor, Windsurf)
- [ ] Settings panel with display toggles (mobile)
- [ ] Mac app settings UI improvements
- [ ] App icon and branding
- [ ] Agent type detection/configuration
- [ ] Parser plugin architecture
- [ ] Improved error messages
- [ ] Performance monitoring

**Success Criteria:**
- ✅ All three output sections parse correctly
- ✅ Works with Cursor and Windsurf
- ✅ Users can customize display settings
- ✅ CPU usage <2% idle

### Phase 4: Custom Actions - Basic (Week 5)
**Goal:** User-defined shortcuts and macros

- [ ] YAML action configuration loading
- [ ] AppleScript action executor
- [ ] Bash action executor
- [ ] Custom action buttons in mobile UI
- [ ] Action execution feedback
- [ ] Action confirmation prompts
- [ ] Action management in Mac app settings
- [ ] Default action pack (common workflows)

**Success Criteria:**
- ✅ Users can define custom actions in YAML
- ✅ Actions execute reliably from mobile
- ✅ Confirmation works for dangerous actions

### Phase 5: Custom Actions - Advanced + Mobile Interaction (Month 2)
**Goal:** Agent-aware automation, workflows, and basic mobile interaction

**Custom Actions (Advanced):**
- [ ] Multi-step action sequences
- [ ] Agent-aware actions (wait-idle, execute-in-cwd)
- [ ] Keyboard shortcut actions
- [ ] HTTP action executor
- [ ] URL opener action
- [ ] Action groups/categories in mobile UI
- [ ] Action execution history
- [ ] Visual action editor in Mac app
- [ ] Action templates

**Mobile Interaction (Terminal Agents Only):**
- [ ] PTY wrapper for terminal Claude Code processes
- [ ] Parse approval prompts from stdout
- [ ] Display approval prompts on mobile as buttons
- [ ] Send Y/N/A to agent stdin
- [ ] Approval prompt detection (regex patterns)
- [ ] Handle multiple concurrent approval requests
- [ ] Timeout handling for stale prompts

**Success Criteria:**
- ✅ Complex workflows execute successfully
- ✅ Agent-aware actions work reliably
- ✅ Action library growing
- ✅ Users can approve Claude Code prompts from phone (terminal only)
- ✅ <2s latency from prompt to mobile display

### Phase 6: Production Polish (Month 2-3)
**Goal:** Professional release quality

- [ ] Code signing and notarization
- [ ] DMG installer creation
- [ ] Comprehensive error handling
- [ ] Performance optimizations
- [ ] Accessibility permission checks/prompts
- [ ] Auto-update mechanism (Sparkle framework)
- [ ] Crash reporting (optional)
- [ ] Documentation website
- [ ] Onboarding flow
- [ ] Video tutorials

**Success Criteria:**
- ✅ App notarized and installable without warnings
- ✅ Smooth installation experience
- ✅ Auto-updates working

**🎯 END OF MONTH 3: PRODUCT HUNT LAUNCH**

### Phase 7: Native iOS App (Month 3-4) 📱 AFTER VALIDATION
**Trigger:** 100+ active users, validated product-market fit

**Goal:** Premium native iOS experience

- [ ] Native SwiftUI iOS app
- [ ] Share models/services with Mac app (create Shared framework)
- [ ] iOS-specific UI optimizations
- [ ] Haptic feedback
- [ ] iOS widgets (agent status at a glance)
- [ ] ShareSheet integration
- [ ] Siri shortcuts (optional)
- [ ] App Store submission
- [ ] App Store optimization (screenshots, description)

**Success Criteria:**
- ✅ Code sharing achieves 30-40% reuse
- ✅ iOS app feels native, not like PWA
- ✅ App Store approved

**Why Wait?**
- ❌ Don't build native iOS before validating PWA works
- ❌ Don't invest 2-3 weeks if users don't want this
- ✅ Let users tell you if they need native features
- ✅ Focus on speed to market first

### Phase 8: Android App (Month 4-5) 🤖 AFTER iOS SUCCESS
**Trigger:** Successful iOS launch, Android user demand

**Goal:** Cross-platform native experience

- [ ] Choose platform: React Native or native Kotlin
- [ ] React Native advantages: share code with iOS, faster dev
- [ ] Kotlin advantages: better performance, native feel
- [ ] Material Design UI
- [ ] Android-specific features (widgets, quick tiles)
- [ ] Google Play submission
- [ ] Play Store optimization

**Success Criteria:**
- ✅ Android app on par with iOS experience
- ✅ Play Store approved

### Phase 9: Commercial Features (Month 6+)
**Goal:** Monetization and team features

- [ ] Action library/marketplace
- [ ] Community-contributed action packs
- [ ] Action templates with parameter prompts
- [ ] Analytics dashboard (agent usage, action usage)
- [ ] Task history per instance
- [ ] Team features (monitor multiple Macs)
- [ ] Cloud sync option (optional)
- [ ] Subscription/license management
- [ ] Payment integration

**Success Criteria:**
- ✅ 50+ paying Pro customers
- ✅ 5+ community action packs
- ✅ Recurring revenue established

---

## Technical Constraints

**Phase 1-6: macOS + PWA Mobile**

**macOS Application:**
- **Platform**: macOS 12+ (Monterey or later)
- **Language**: Swift 5.7+ (Swift 6 compatible)
- **Framework**: SwiftUI for UI, Combine for reactive state
- **Xcode**: 14.0+ required for development
- **Permissions**: Accessibility access required for window switching
- **Distribution**: DMG installer (notarized), potential Mac App Store
- **Memory**: Target <100MB RAM usage
- **CPU**: Target <2% idle, <5% active

**Progressive Web App (Mobile Interface):**
- **Browsers**:
  - iOS Safari 14+ (primary target)
  - Chrome 90+ (Android, desktop)
  - Firefox 90+ (cross-platform)
- **Network**: Requires both devices on same WiFi/local network
- **Storage**: LocalStorage for settings persistence (small footprint)
- **Offline**: Service Worker for basic offline functionality
- **Viewport**: Mobile-first design (320px min width)
- **Performance**: <100ms tap response, <500ms WebSocket latency
- **Why PWA First:**
  - ✅ Zero platform lock-in
  - ✅ Works on ANY device with a browser
  - ✅ No 30% app store tax
  - ✅ Instant updates (no app review delays)
  - ✅ Users can test in 30 seconds
  - ✅ Perfect for remote control use case

**Phase 7+: Native Mobile Apps (After Validation)**

**iOS Native App (Phase 7):**
- **Platform**: iOS 15+ (for native app)
- **Language**: Swift (shared with Mac app)
- **Framework**: SwiftUI
- **Xcode**: Same as Mac app (shared workspace)
- **Distribution**: App Store only
- **Triggers for building:**
  - 100+ active users on PWA
  - User feedback requests native features
  - Validated product-market fit
  - Revenue to support iOS development costs

**Android Native App (Phase 8):**
- **Platform**: Android 8+ (API 26+)
- **Language**: Kotlin or JavaScript (React Native)
- **Framework**: Native Android or React Native
- **Distribution**: Google Play Store
- **Triggers for building:**
  - Successful iOS native app launch
  - Android user demand (survey/requests)
  - Revenue to support Android development

**Development Philosophy:**
- **Phase 1-2**: Ship fast, validate quickly
- **Phase 3-6**: Polish and grow user base
- **Phase 7-8**: Native mobile only if users demand it
- **Don't build native mobile until:**
  - ❌ You have 100+ active users
  - ❌ Users explicitly request native features
  - ❌ PWA limitations are blocking adoption
  - ✅ You've validated product-market fit

---

## Success Criteria

**Phase 1-2 (MVP - Week 2): Ship to First Users**
- ✅ Latency <500ms from status change to mobile UI update
- ✅ Latency <1s from window focus tap to execution
- ✅ CPU usage <2% idle, <5% active monitoring
- ✅ Memory usage <100MB
- ✅ Zero setup required after initial install (no environment vars, etc.)
- ✅ PWA installable on iOS/Android home screens
- ✅ Works with Claude Code instances
- ✅ Graceful handling of 3+ concurrent instances
- ✅ Basic output parsing (current task) works
- ✅ Window switching works reliably
- ✅ 10+ testers using it successfully

**Phase 3-4 (Polish - Month 1):**
- ✅ Works with at least 3 different agent types (Claude Code, Cursor, Windsurf)
- ✅ Graceful handling of 10+ concurrent instances
- ✅ All three output sections (current task, todo, status) parse correctly
- ✅ Custom actions execute reliably with proper error handling
- ✅ 50+ active users
- ✅ Positive feedback on Show HN

**Phase 5-6 (Production - Month 2-3):**
- ✅ Action execution history retained for debugging
- ✅ App notarized and signed
- ✅ DMG installer working smoothly
- ✅ Auto-updates functioning
- ✅ 100+ active users
- ✅ Featured on Product Hunt
- ✅ 10+ community-created action configs

**Phase 7+ (Native Mobile - Month 3+):**
- ✅ 100+ active users requesting native mobile features
- ✅ User survey confirms PWA limitations
- ✅ Revenue to support native development
- ✅ iOS app achieves 30-40% code sharing with Mac app
- ✅ Native mobile app on par with PWA functionality

**Key Performance Indicators (KPIs):**

**Week 2 (Launch):**
- 10 active users
- 0 critical bugs

**Month 1:**
- 50 active users
- 100+ GitHub stars
- 5 community action configs

**Month 3:**
- 100 active users
- 500+ GitHub stars
- 20+ community action configs
- 10+ paying Pro customers

**Month 6:**
- 500 active users
- 1000+ GitHub stars
- 50+ paying Pro customers
- Decision point: Build native mobile or not?

---

## Future Enhancements (Post-MVP)

### Short-Term (Phase 3-4, PWA Mobile)
**These can ship before interaction features:**
- Historical task tracking/analytics
- Custom parsing rules per project (YAML-based)
- Scheduled actions (cron-like)
- Conditional actions (if-then rules)
- Integration with project management tools (Jira, Linear, Notion)
- Browser notifications (PWA Push API)

### Phase 5-6: Mobile Interaction (Terminal Agents) 🎯 HIGH VALUE
**Goal:** Allow users to interact with agents from phone, not just monitor

**Use Case:** User is away from desk, Claude Code asks "Allow this file edit? Y/N" - user can approve from phone instead of walking back to Mac.

**Important Limitation:** Initially only works for **terminal-based agents** (Claude Code CLI). VS Code/Cursor integration requires separate approaches.

#### Phase 5: Approval Prompts (Terminal Only)
**Implementation:**
- PTY (pseudo-terminal) wrapper around terminal Claude Code processes
- Parse stdout for approval prompts ("Allow this action? Y/N")
- Display prompts on mobile as tap-able buttons
- Send Y/N/A to agent stdin when user taps

**Mobile UI:**
```
┌─────────────────────────────────────┐
│ ⚠️ Claude Code is asking:           │
│                                     │
│ "Allow file edit to src/auth.js?"  │
│                                     │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐│
│ │✅ Approve│ │❌ Deny  │ │⚡ Always││
│ └─────────┘ └─────────┘ └─────────┘│
└─────────────────────────────────────┘
```

**Why This Matters:**
- Solves primary pain point: "can't approve from phone"
- Keeps agents working while away from desk
- Fits "Stream Deck" model (tap to approve = one action)
- Natural extension of monitoring

**Complexity:** MEDIUM (1 week)
**Value:** HIGH (requested feature)

#### Phase 6: Simple Commands (Terminal Only)
**Expand to predefined commands:**
- Button grid with common commands
- "Continue", "Stop", "Clear", "Retry", "Skip"
- No typing required (button taps only)
- Still terminal-based agents only

**Mobile UI Addition:**
```
┌─────────────────────────────────────┐
│        Agent Commands               │
├─────────────────────────────────────┤
│ ▶️ Continue    ⏸️ Pause    ⏹️ Stop  │
│ 🔄 Retry      ⏭️ Skip      🗑️ Clear │
└─────────────────────────────────────┘
```

**Complexity:** MEDIUM (3-4 days)
**Value:** MEDIUM

### Phase 7-8: Extended Interaction Support

#### Phase 7: VS Code Extension Integration 🔬
**Challenge:** VS Code Claude Code extension doesn't expose stdin/stdout like terminal

**Approach:**
- Build custom VS Code extension for Agent Deck
- Extension bridges VS Code Claude Code ↔ Agent Deck backend
- User installs both extensions
- Agent Deck can then interact with VS Code-based agents

**Complexity:** HIGH (2 weeks, requires VS Code API research)
**Value:** HIGH (many users run in VS Code)
**Risk:** May not be technically feasible without Claude team cooperation

#### Phase 8: Full Terminal Emulation (Advanced)
**For power users who want full control:**
- xterm.js terminal emulator on mobile
- Full keyboard input (typing on phone)
- Complete bidirectional communication
- Still limited to terminal-based agents

**Complexity:** HIGH (2 weeks)
**Value:** MEDIUM (typing on phone is painful, most users won't use this)
**When:** Only if users explicitly request it

### Phase 9+: Universal Agent Control (Long-Term Vision)

**Goal:** Interact with ANY agent in ANY environment

**Requires:**
- Partnerships with Cursor, Windsurf, other agent platforms
- Standardized agent control protocol
- Official integrations vs. reverse engineering

**Feasibility by Platform:**
| Platform | Current Feasibility | Path Forward |
|----------|-------------------|--------------|
| **Terminal Claude Code** | ✅ HIGH | PTY wrapper (Phase 5-6) |
| **VS Code Extension** | ⚠️ MEDIUM | Custom extension (Phase 7) |
| **Cursor Built-In** | ❌ LOW | Requires Cursor partnership |
| **Windsurf** | ❓ UNKNOWN | Need to research |

**Reality Check:**
- "Mix of environments" means we can't build one solution
- Terminal interaction ships first (Phase 5-6)
- VS Code requires extension development (Phase 7)
- Cursor/Windsurf may never support external control
- Universal control requires industry cooperation

**Timeline:** Unknown (6+ months, depends on partnerships)

### Short-Term (Phase 3-6, Additional PWA Features)
**These don't require agent interaction:**
- Keyboard shortcuts from mobile (using Web Keyboard API)
- Action chaining/workflows (advanced custom actions)

### Medium-Term (Phase 7-8, Native Mobile)
**These benefit from native mobile:**
- Native haptic feedback (iOS/Android)
- Voice commands ("Hey Siri, focus Claude instance 1")
- Native notifications (richer than PWA)
- iOS widgets (agent status at a glance)
- Android quick tiles
- ShareSheet integration (iOS)
- Siri shortcuts
- System-level integrations

### Long-Term (Phase 9+, Platform Expansion)
**Major new platforms:**
- Windows/Linux support (separate Mac app port)
- Windows native app (C# or Electron)
- Linux support (likely Electron or GTK)
- Web-only mode (no desktop app, cloud-based monitoring)

### Collaboration Features (Enterprise)
**Team-focused features:**
- Team dashboard (monitor multiple developers' Macs)
- Shared action libraries across team
- Action usage analytics across team
- Remote agent triggering for team members
- Role-based access control
- Audit logs
- SSO integration

**Philosophy: PWA Mobile First**
- Most features can ship with PWA mobile
- Native mobile is an optimization, not a requirement
- Platform expansion (Windows/Linux) has higher priority than native mobile
- Build what users ask for, not what you think they need

---

## Competitive Positioning

### vs. Omnara
**Advantages**:
- ✅ Fully local (no cloud dependency)
- ✅ Window switching from mobile
- ✅ Custom macros/actions
- ✅ Agent-aware automation
- ✅ No monthly cost

**Disadvantages**:
- ❌ Same WiFi required
- ❌ No mobile access outside home network
- ❌ Single-user focused (initially)

### vs. Touch Portal
**Advantages**:
- ✅ Agent monitoring built-in
- ✅ Agent-aware actions
- ✅ Developer-focused
- ✅ Config-as-code
- ✅ Open source potential

**Disadvantages**:
- ❌ Mac-only (initially)
- ❌ Smaller action library
- ❌ Less polish (initially)

### vs. Conductor/Crystal
**Advantages**:
- ✅ Mobile interface
- ✅ Remote monitoring
- ✅ Custom actions
- ✅ Multi-agent support

**Disadvantages**:
- ❌ Different focus (they're about git worktrees)
- ❌ Desktop-only

### Unique Value Proposition
**"Stream Deck for AI agents"** - The only tool that combines:
1. Multi-agent monitoring with detailed output parsing
2. One-tap window switching
3. Custom macro execution
4. Agent-aware automation
5. Fully local operation

---

## Branding & Go-To-Market Strategy

### Brand Identity

**Name:** Agent Deck
**Domain:** agent-deck.dev
**Tagline:** "Stream Deck for AI agents"

**Visual Identity:**
- UI should mirror Stream Deck aesthetic (colorful icon grid)
- Control deck/command center theme
- Dark mode primary (developer-friendly)
- Emphasis on touch-optimized, tactile controls

### Positioning Strategy

**Primary Hook:** Stream Deck Association
- "Like Stream Deck, but in your pocket"
- "Stream Deck costs $150, Agent Deck is free/cheap"
- Target r/StreamDeck and r/ElgatoStreamDeck communities
- SEO: "Stream Deck alternative," "mobile Stream Deck," "Stream Deck for Mac"

**Secondary Hook:** Agentic Coding Wave
- "Monitor Claude Code & Cursor agents from anywhere"
- Launch timing coincides with Cursor 2.0 agent mode release
- Ride the "agentic coding" buzzword of 2025
- Position as essential infrastructure for AI coding

**Target Audience:**
- Primary: Solo developers using Claude Code, Cursor
- Secondary: Stream Deck owners looking for mobile alternatives
- Tertiary: Touch Portal users wanting agent integration

### Launch Timing & Messaging

**Q4 2024 - Q1 2025 (Launch):**
> "Agent Deck - Monitor Claude Code & Cursor agents from your phone. Like Stream Deck, but for AI agents."

**Q1 2025 (Feature expansion):**
> "Agent Deck - Stream Deck for your dev workflow. Monitor agents, trigger macros, all from your pocket."

**Q2 2025+ (Market expansion):**
> "Agent Deck - Your entire dev workflow in your pocket. Because your agents don't stop when you leave your desk."

### Marketing Channels

**Developer Communities:**
- r/ClaudeCode, r/cursor, r/vscode
- Hacker News (Show HN: Agent Deck)
- Product Hunt launch
- Dev.to, Hashnode blog posts

**Stream Deck Crossover:**
- "Why I replaced my Stream Deck with Agent Deck" blog post
- Demo video showing side-by-side comparison
- Stream Deck subreddits and forums

**Content Marketing:**
- "The Rise of Agentic Coding and Why You Need Agent Deck"
- "5 Custom Actions That Will Change Your Workflow"
- "How to Monitor 10 Claude Code Instances Simultaneously"

**Social Proof:**
- Early access for influencers in AI coding space
- Demo videos on Twitter/X during Cursor 2.0 hype
- Integration showcases with popular workflows

### Competitive Messaging

**vs. Omnara:**
"Agent Deck is fully local - no cloud required, no monthly fees. Plus Stream Deck-style custom actions."

**vs. Touch Portal:**
"Agent Deck adds AI agent monitoring to everything Touch Portal does, with better mobile UX."

**vs. Stream Deck:**
"Agent Deck turns your phone into a Stream Deck with AI superpowers. No $150 hardware required."

**vs. Conductor/Crystal:**
"Agent Deck adds mobile monitoring and custom actions to your multi-agent workflow."

---

## Monetization Options

**Pricing Philosophy:** Accessible to indie developers, scalable to teams

### Free Tier (Open Source)
- Up to 3 monitored agents
- Up to 10 custom actions
- Core features only
- Community support
- GitHub self-hosting option

### Pro ($9-15/month or $49-79 one-time)
- Unlimited agents
- Unlimited custom actions
- Action library access
- Priority support
- Advanced features (action scheduling, workflows)
- Early access to new features

### Team ($29-49/month)
- Multi-Mac monitoring
- Shared action libraries
- Team analytics
- Admin controls
- Priority support
- Team dashboard

### Enterprise (Custom)
- On-premise deployment
- Custom integrations
- SLA
- Dedicated support
- Training
- White-label options

**Launch Strategy:**
- Free tier forever (build community)
- Pro tier at launch (early adopters)
- Team tier Q2 2025
- Enterprise Q3 2025

**Alternative Model - Stream Deck Comparison:**
- Position as "Stream Deck is $150, Agent Deck Pro is $49 lifetime"
- One-time purchase emphasis vs. subscription fatigue
- Aligns with indie dev economics

---

## Notes for Implementation

### MVP (Phase 1-4)
- Start with Claude Code only, add other agents incrementally
- Use feature flags for experimental features
- Keep zero-dependency philosophy where possible
- Optimize for "works immediately" experience
- Document macOS permission setup clearly
- Consider security: only bind to local network, no auth needed initially
- Test with 5+ concurrent Claude Code instances
- Ensure todo list parsing handles nested items gracefully
- Make status line parsing flexible (last non-empty line as fallback)
- Custom actions should fail gracefully with clear error messages
- Action execution should be atomic (all-or-nothing for multi-step)
- Consider action rollback/undo for dangerous operations

### Mobile Interaction (Phase 5+)
**When adding PTY wrapper for terminal interaction:**
- Only wrap terminal-based Claude Code processes (detect via process args)
- Don't try to wrap VS Code/Cursor processes (won't work)
- Use `node-pty` or Swift equivalent (Swift Vapor has PTY support)
- Capture stdout/stderr independently (don't merge streams)
- Buffer output before parsing (prompts might span multiple chunks)
- Use regex patterns to detect approval prompts:
  - "Allow this action? (Y/n/a)"
  - "Approve file edit? (Y/N)"
  - "Continue? (y/n)"
- Consider prompt variations across Claude Code versions
- Timeout stale prompts after 5 minutes (don't block forever)
- Handle multiple concurrent prompts (queue on mobile)
- Log all stdin injections for debugging
- Graceful degradation: if PTY fails, fall back to monitoring-only

**Environment Detection:**
- Check process name and args to determine environment:
  - `claude code` in terminal → PTY wrapper ✅
  - VS Code process with Claude extension → Monitoring only ⚠️
  - Cursor process → Monitoring only ⚠️
- Display environment type in mobile UI ("Terminal", "VS Code", etc.)
- Show "Interaction available" badge only for terminal instances
- Document limitations clearly in UI and docs

**Security Considerations:**
- PTY wrapper gives full stdin access → dangerous if compromised
- Only allow approved commands (Y/N/A, predefined buttons)
- Log all interaction attempts
- Consider requiring Mac confirmation for first interaction
- WebSocket should use WSS (TLS) for non-local network access
- Rate limit stdin injections to prevent abuse

**User Experience:**
- Make it obvious which instances support interaction
- Show "Interaction not available" message for VS Code/Cursor
- Provide helpful error messages: "Interaction only works for terminal-based agents"
- Consider adding "Run in terminal?" suggestion in docs
- Don't confuse users with features that only work sometimes

---

## Quick Reference

### Elevator Pitch
"Agent Deck is Stream Deck for AI agents. Monitor Claude Code and Cursor from your phone, trigger custom macros, and switch windows with one tap. No cloud required."

### One-Liner Positioning
"Like Stream Deck, but in your pocket - for AI coding agents."

### Key Differentiators
1. **Stream Deck familiarity** - Instant recognition, proven category
2. **Fully local** - No cloud, no subscription (vs. Omnara)
3. **Window switching** - Unique mobile-to-Mac control
4. **Agent-aware actions** - Macros that understand agent state
5. **Perfect timing** - Launching with Cursor 2.0 and agentic coding wave
6. **Universal mobile access** - PWA works on ANY device immediately

### Platform Strategy Summary
**Launch (Week 1-2):**
- ✅ Native Mac app (menubar, professional)
- ✅ PWA mobile (works everywhere, zero friction)
- ❌ NO native mobile apps yet

**After Validation (Month 3+):**
- ✅ Native iOS app (if users demand it)
- ✅ Native Android app (if iOS succeeds)
- ✅ Only build after 100+ active users

**Why?**
- Speed to market (2 weeks vs 6 weeks)
- Universal device support (iOS + Android + iPad + any browser)
- No app store delays (iterate daily)
- Validate before investing in native
- Touch Portal started simple too

### Target Launch Date
**Week 2 (Soft Launch):** Q1 2025 - Show HN, early adopters
**Month 3 (Product Hunt):** Q1 2025 - Public launch
**Month 3+ (Native Mobile):** Only if validated

### Success Metrics - Year 1
- 1,000 GitHub stars
- 500 active users (PWA)
- 50 paying Pro customers
- 5 community-contributed action packs
- Featured on Hacker News front page
- **Decision: Build native mobile only if users demand it**

---

## Getting Started

### SpecKit Integration (Recommended) 🚀

**Agent Deck uses SpecKit for spec-driven development with AI assistants.**

**Why SpecKit?**
- ✅ Keeps Mac and PWA codebases aligned
- ✅ Prevents AI drift during 2-week MVP sprint
- ✅ Documents architecture for Phase 2+ (iOS, Android)
- ✅ Reduces rework cycles (structured specs upfront)
- ✅ Native Claude Code integration (slash commands)

**Setup (< 10 minutes):**
```bash
# Install uv package manager
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install SpecKit
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# Initialize in Agent Deck project
cd /Users/tonyofthehills/dev/apps/app-009-agent-deck
specify init --agent claude-code
```

**Day 1 Workflow (Before Coding):**
```bash
# 1. Define project principles (30 min)
/speckit.constitution

# Principles to include:
# - Speed to market: 2-week MVP over perfection
# - Mac-first: Native Swift menubar app is core
# - Mobile validation: PWA first, native later
# - Local-first: No cloud dependencies in Phase 1
# - Developer audience: Functionality over polish

# 2. Convert spec to SpecKit format (1 hour)
/speckit.specify

# Import sections from agent-deck-spec-final.md:
# - Platform Strategy (hybrid Mac + PWA)
# - Phase 1-2 requirements
# - Technical constraints
# - Success criteria

# 3. Generate implementation plan (1 hour)
/speckit.plan

# Expected plan output:
# - Swift menubar app architecture
# - WebSocket server design (Vapor or Network.framework)
# - PWA structure (vanilla JS)
# - Communication protocol
# - Configuration management (YAML)

# 4. Break into tasks (30 min)
/speckit.tasks

# Week 1: Mac app core
# Week 2: PWA + window switching

# 5. Start implementing (Days 1-14)
/speckit.implement [task-name]
```

**SpecKit Files Created:**
```
.speckit/
├── constitution.md      # Project governance principles
├── spec.md             # What to build (Phase 1: Mac + PWA)
├── plan.md             # How to build it (architecture)
└── tasks/              # Week 1-2 task breakdown
```

**Benefits:**
- Saves 8+ hours in rework (structured specs prevent ambiguity)
- Multi-platform consistency (Swift and JS stay aligned)
- Phase planning (documented architecture for iOS/Android later)
- Task tracking (clear breakdown for 2-week sprint)

**Resources:**
- Docs: https://speckit.org
- GitHub: https://github.com/github/spec-kit

---

### For Claude Code Development (Without SpecKit)

**Phase 1 - Mac App Core (Week 1) 🚀:**
```bash
claude code "Build Agent Deck Phase 1 according to agent-deck-spec-final.md:

GOAL: Professional native Mac menubar app with embedded WebSocket server

REQUIREMENTS:
1. SwiftUI menubar app with icon and dropdown
2. Process monitoring for Claude Code instances (NSWorkspace)
3. Embedded WebSocket server (Network.framework or Vapor)
4. Embedded HTTP server to serve PWA files
5. Basic agent status display in menubar dropdown
6. Settings window (port, auto-start)
7. YAML configuration loading (Yams library)
8. QR code generation for mobile pairing
9. Bonjour/mDNS service announcement

DELIVERABLES:
- Single .app bundle (no Node.js dependency)
- Menubar app that runs in background
- WebSocket server on port 3000
- HTTP server serving Resources/WebRoot/
- Configuration at ~/.agent-deck/config.yaml

See Phase 1 section and File Structure in spec."
```

**Phase 2 - PWA Mobile + Window Switching (Week 2) 🚀:**
```bash
claude code "Build Agent Deck Phase 2 according to agent-deck-spec-final.md:

GOAL: Full mobile experience working on all devices

REQUIREMENTS:
1. PWA mobile web interface (vanilla JS, no build step)
   - index.html, app.js, styles.css
   - Dark mode mobile UI
   - Touch-optimized agent list
   - Color-coded status indicators
2. PWA manifest and service worker (offline support)
3. Real-time WebSocket client connecting to Mac app
4. AppleScript-based window switching
5. Tap-to-focus functionality (mobile → Mac window)
6. Basic output parsing (current task line)
7. Connection status indicator
8. Error handling & auto-reconnect
9. "Add to Home Screen" verified on iOS Safari

DELIVERABLES:
- PWA embedded in Mac app Resources/WebRoot/
- Works on iOS Safari, Chrome, Android browsers
- <500ms update latency
- Installable on home screen
- Works offline after initial load

See Phase 2 section and Mobile Web Interface requirements in spec.

🎯 END OF WEEK 2: READY TO SHIP TO FIRST USERS"
```

**Phase 3 - Enhanced Parsing & Polish (Week 3-4):**
```bash
claude code "Build Agent Deck Phase 3 according to agent-deck-spec-final.md:

GOAL: Complete output parsing and multi-agent support

REQUIREMENTS:
1. Full output parsing (current task, todo list, status line)
2. Support for Cursor, Windsurf agents (configurable parsers)
3. Mobile settings panel with display toggles
4. Mac app settings UI improvements
5. App icon and branding
6. Parser plugin architecture (YAML-based)
7. Performance monitoring and optimization

See Phase 3 section in spec."
```

**Phase 4 - Custom Actions (Week 5):**
```bash
claude code "Build Agent Deck Phase 4 according to agent-deck-spec-final.md:

GOAL: User-defined shortcuts and macros

REQUIREMENTS:
1. YAML action configuration loading (~/.agent-deck/custom-actions.yaml)
2. AppleScript action executor
3. Bash action executor
4. Custom action buttons in mobile UI
5. Action execution feedback (real-time output)
6. Action confirmation dialogs (for dangerous actions)
7. Action management UI in Mac app settings
8. Default action pack (Git, Figma, common workflows)

See Phase 4 and Custom Actions System section in spec."
```

**Important Development Notes:**
- **Week 1-2 are LAUNCH CRITICAL** - focus on speed, not perfection
- **Embedded PWA** - don't build separate projects, embed in Mac app
- **No Node.js** - everything in Swift (cleaner for users)
- **PWA first** - native mobile only after validation
- **Ship Week 2** - don't wait for Phase 3+

### Manual Development Setup

**Prerequisites:**
- macOS 12+ (Monterey or later)
- Xcode 14.0+
- Swift 5.7+

**Project Setup:**
1. Create new Xcode project (macOS App)
2. Select SwiftUI as interface
3. Enable App Sandbox with network access
4. Add required entitlements (Accessibility, Network)
5. Add dependencies:
   - `Yams` for YAML parsing (Swift Package Manager)
   - `Vapor` or custom Network.framework implementation

**Development Workflow:**
1. Build and run from Xcode
2. Grant Accessibility permissions when prompted
3. Server runs on `localhost:3000` by default
4. Open mobile interface from iPhone/iPad Safari
5. Scan QR code from Mac app to connect

**Testing:**
1. Run multiple Claude Code instances
2. Connect mobile device to same WiFi
3. Verify real-time status updates
4. Test window switching
5. Test custom actions
