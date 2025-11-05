# Feature Specification: Agent Deck MVP (Phases 1-2)

**Feature Branch**: `001-mvp`
**Created**: 2025-01-02
**Status**: Draft
**Input**: Agent Deck MVP - Native Mac menubar app + PWA mobile interface for monitoring AI coding agents with real-time status updates and window switching

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Monitor Running AI Agents from Mobile (Priority: P1) 🎯 MVP

Developer runs Claude Code on their Mac while working. They step away from desk but want to see if their agent is still working or has encountered an error. They open Agent Deck PWA on their phone, see real-time status of their Claude Code instance with rich context including: current task being executed, AI model name, git branch, active subagents, todo list with progress, and whether it's idle, working, done, or errored.

**Why this priority**: Core value proposition. Without this, there's no product. Solves the primary pain point: "I can't monitor my agents when away from my desk." Enhanced visibility (model, branch, todos, subagents) provides actionable context for decision-making.

**Independent Test**: Install Mac app, run Claude Code, open PWA on phone, verify real-time status with rich data (model, branch, todos, subagents) appears and updates within 500ms of changes.

**Acceptance Scenarios**:

1. **Given** Mac app is running and Claude Code is active, **When** user opens PWA on mobile device, **Then** PWA displays Claude Code instance with current status, working directory, and last update timestamp
2. **Given** PWA is connected, **When** Claude Code status changes from idle to working, **Then** mobile UI updates status indicator color and displays new current task within 500ms
3. **Given** multiple Claude Code instances are running, **When** user views PWA, **Then** all instances appear in list with independent status indicators
4. **Given** Claude Code encounters an error, **When** PWA receives update, **Then** status indicator turns red and displays error state
5. **Given** network connection is lost, **When** PWA detects disconnection, **Then** connection status indicator shows "Disconnected" and attempts auto-reconnect

---

### User Story 2 - Switch Windows from Mobile Device (Priority: P1) 🎯 MVP

Developer is away from desk when they see an agent needs attention on their phone. They tap the agent card in the PWA, and the Mac instantly brings that agent's window to the front and focuses it. When they return to their desk, the correct window is already visible and ready for interaction.

**Why this priority**: Critical differentiator from pure monitoring tools. Enables remote control workflow that transforms mobile device into action tool, not just dashboard.

**Independent Test**: Open PWA on phone, tap agent instance card, verify Mac switches to that window within 1 second and window is frontmost.

**Acceptance Scenarios**:

1. **Given** Claude Code window is in background, **When** user taps that instance card on mobile, **Then** Mac brings Claude Code window to front within 1 second
2. **Given** Claude Code is on different macOS Space, **When** user taps instance, **Then** Mac switches to correct Space and focuses window
3. **Given** multiple agents are running in different windows, **When** user taps specific instance, **Then** only that instance's window comes to front
4. **Given** window switching fails (accessibility permissions not granted), **When** user taps instance, **Then** PWA displays error message explaining permission requirement
5. **Given** Mac app is not running, **When** user attempts to tap instance, **Then** PWA displays "Mac app disconnected" state

---

### User Story 3 - Quick Mobile Setup via QR Code (Priority: P1) 🎯 MVP

Developer installs Mac app for first time. They click menubar icon, select "View Mobile Interface", and see a QR code with local network URL. They scan QR code with phone camera, Safari opens to PWA, they tap "Add to Home Screen", and icon appears on home screen like a native app. Total setup time: under 60 seconds.

**Why this priority**: Zero-friction mobile setup is critical for adoption. If setup takes more than 2 minutes or requires typing long URLs, users abandon the product.

**Independent Test**: Install Mac app, scan QR code from menubar dropdown, verify PWA loads and can be added to home screen successfully.

**Acceptance Scenarios**:

1. **Given** Mac app is running, **When** user opens menubar dropdown, **Then** dropdown displays QR code for mobile pairing
2. **Given** QR code is displayed, **When** user scans with phone camera, **Then** phone opens PWA URL in default browser automatically
3. **Given** PWA loads in Safari, **When** user taps "Add to Home Screen", **Then** PWA icon appears on home screen and launches in fullscreen
4. **Given** devices are on different WiFi networks, **When** user tries to connect, **Then** PWA displays error explaining same network requirement
5. **Given** Mac app port 3000 is already in use, **When** Mac app starts, **Then** Mac app displays error with suggestion to change port in settings

---

### User Story 4 - View Parsed Agent Output (Priority: P2)

Developer wants to see not just status, but what specific task Claude Code is working on. PWA displays parsed current task line extracted from Claude Code stdout (e.g., "Writing authentication tests"). This gives developer context about agent progress without returning to desk.

**Why this priority**: Enhances monitoring value with actionable context. P2 because basic status (P1) is sufficient for MVP validation, but parsed output significantly improves user experience.

**Independent Test**: Run Claude Code with active task output, verify PWA displays current task description parsed from stdout.

**Acceptance Scenarios**:

1. **Given** Claude Code outputs "Currently: Writing tests", **When** PWA receives update, **Then** current task section displays "Writing tests"
2. **Given** Claude Code output doesn't match expected pattern, **When** parser runs, **Then** current task shows "Unknown" or last known task
3. **Given** user toggles "Show current task" off, **When** PWA refreshes, **Then** current task section is hidden from display
4. **Given** current task is very long text, **When** displayed on mobile, **Then** text truncates with ellipsis and remains readable

---

### User Story 5 - Install and Run Mac App Without Configuration (Priority: P2)

Developer downloads .app bundle, double-clicks to install, grants accessibility permissions when prompted, and Mac app immediately starts monitoring Claude Code instances without any configuration file editing or terminal commands. App appears in menubar with status icon.

**Why this priority**: Zero-config installation is critical for developer audience who value simplicity. P2 because early testers can handle basic setup, but production requires this.

**Independent Test**: Install Mac app on clean macOS system, verify it launches, appears in menubar, and detects running Claude Code without any configuration.

**Acceptance Scenarios**:

1. **Given** fresh Mac app install, **When** user double-clicks .app, **Then** app launches and menubar icon appears within 2 seconds
2. **Given** accessibility permissions not granted, **When** app needs window switching, **Then** macOS prompts user with permission dialog
3. **Given** no config file exists, **When** app starts, **Then** app creates default config at ~/.agent-deck/config.yaml
4. **Given** Claude Code is already running, **When** Mac app starts, **Then** app detects and lists instance in menubar dropdown within 2 seconds
5. **Given** app is running, **When** user quits, **Then** app stops cleanly without leaving background processes

---

### User Story 6 - Execute Custom Actions via Stream Deck Style Buttons (Priority: P3)

Developer wants quick access to frequently-used apps and commands while monitoring agents. PWA displays a grid of customizable square buttons below agent list. Each button has a label and emoji icon. Tapping "Figma" button switches to Figma, tapping "Build" runs a build script, tapping "Chrome" opens browser. Buttons are configured via YAML file with support for AppleScript and Bash commands.

**Why this priority**: Transforms Agent Deck from pure monitoring tool to productivity hub. P3 because agent monitoring (P1) and window switching (P1) must work first, but this significantly increases utility by enabling one-tap access to common workflows.

**Independent Test**: Configure custom actions in YAML (Figma app launch, build script), verify PWA displays buttons, tap buttons and confirm Mac executes commands within 1 second.

**Acceptance Scenarios**:

1. **Given** config contains custom action for Figma, **When** PWA loads, **Then** PWA displays "Figma" button with 🎨 icon in custom actions grid
2. **Given** custom action button is displayed, **When** user taps "Figma" button, **Then** Mac executes AppleScript to launch/focus Figma app within 1 second
3. **Given** custom action runs Bash script, **When** user taps button, **Then** Mac executes script and returns success/error status to PWA
4. **Given** user has 6 custom actions configured, **When** viewing PWA, **Then** all 6 buttons display in scrollable grid with labels and icons visible
5. **Given** custom action execution fails, **When** PWA receives error response, **Then** PWA shows toast notification with error message
6. **Given** no custom actions configured, **When** PWA loads, **Then** custom actions section is hidden from display

---

### Edge Cases

- What happens when Mac goes to sleep while PWA is connected? (Expected: PWA shows disconnected, auto-reconnects on wake)
- What happens when Claude Code process terminates while being monitored? (Expected: Instance removed from list or marked as terminated)
- What happens when 10+ Claude Code instances are running simultaneously? (Expected: All listed, UI remains performant, scrollable list)
- What happens when user taps instance repeatedly within 1 second? (Expected: Debounce duplicate requests, execute once)
- What happens when WiFi network changes on either device? (Expected: Connection drops, user must re-scan QR code)
- What happens when port 3000 is already in use by another service? (Expected: Mac app shows error, offers to change port)
- What happens when custom action button is tapped while previous action still executing? (Expected: Queue or ignore until completion)
- What happens when custom action AppleScript references non-existent application? (Expected: Return error to PWA with descriptive message)
- What happens when custom action Bash script has syntax errors or permission issues? (Expected: Return execution error to PWA)
- What happens when user configures 20+ custom actions? (Expected: PWA displays scrollable grid, performance remains acceptable)

## Requirements *(mandatory)*

### Functional Requirements

**Mac Application Core**:
- **FR-001**: System MUST detect running Claude Code processes using macOS process monitoring APIs
- **FR-002**: System MUST run as menubar-only application (no dock icon) with status icon that changes color based on agent activity
- **FR-003**: System MUST provide menubar dropdown showing list of detected agent instances with status
- **FR-004**: System MUST start embedded WebSocket server on configurable port (default 3000) for real-time communication
- **FR-005**: System MUST start embedded HTTP server to serve PWA static files from embedded Resources/WebRoot/ directory
- **FR-006**: System MUST generate QR code containing local network URL for mobile device pairing
- **FR-007**: System MUST broadcast agent status updates via WebSocket when any instance state changes
- **FR-008**: System MUST execute AppleScript to focus/activate window when receiving focus command from mobile
- **FR-009**: System MUST create default YAML configuration file at ~/.agent-deck/config.yaml if none exists
- **FR-010**: System MUST persist user preferences (port, auto-start on login) using UserDefaults

**Mobile Interface (PWA)**:
- **FR-011**: PWA MUST connect to Mac WebSocket server using URL from QR code or manual entry
- **FR-012**: PWA MUST display list of agent instances with color-coded status indicators (idle: gray, working: blue, done: green, error: red)
- **FR-013**: PWA MUST show per-instance metadata: agent type, working directory, timestamp of last activity
- **FR-014**: PWA MUST update display within 500ms when receiving status change via WebSocket
- **FR-015**: PWA MUST send window focus command to Mac when user taps agent instance card
- **FR-016**: PWA MUST display connection status indicator and show "Disconnected" when WebSocket connection lost
- **FR-017**: PWA MUST attempt automatic reconnection with exponential backoff when connection drops
- **FR-018**: PWA MUST be installable on iOS/Android home screen via "Add to Home Screen" functionality
- **FR-019**: PWA MUST provide service worker for basic offline capability (cached UI shell)
- **FR-020**: PWA MUST persist display settings (show/hide sections) to localStorage

**Agent Output Parsing**:
- **FR-021**: System MUST parse Claude Code stdout to extract current task line (e.g., line starting with "Currently:")
- **FR-022**: System MUST store parsed current task separately from raw status for independent display toggling
- **FR-023**: System MUST handle unparseable output gracefully by showing last known task or "Unknown"
- **FR-065**: System MUST parse and display active subagents from Claude Code transcript
- **FR-066**: System MUST parse and display todo list with status indicators (pending, in_progress, completed) from transcript
- **FR-067**: System MUST extract and display AI model name and current git branch from transcript

**Process Monitoring**:
- **FR-024**: System MUST poll for process changes every 1-2 seconds to detect new instances and terminated processes
- **FR-025**: System MUST track per-instance: PID, executable path, working directory, window ID for focus switching
- **FR-026**: System MUST remove instances from list when process terminates
- **FR-027**: System MUST support monitoring Claude Code only in Phase 1-2 (Cursor/Windsurf in Phase 3+)

**Window Management**:
- **FR-028**: System MUST use AppleScript to focus window by process PID
- **FR-029**: System MUST switch to correct macOS Space if target window is on different Space
- **FR-030**: System MUST return success/failure status to mobile client after window switch attempt
- **FR-031**: System MUST provide clear error message when accessibility permissions not granted

**Configuration**:
- **FR-032**: System MUST load configuration from ~/.agent-deck/config.yaml with schema: server port, host, agent patterns
- **FR-033**: System MUST provide settings window accessible from menubar with tabs: General, Agents, Mobile, About
- **FR-034**: Users MUST be able to configure server port and auto-start on login via settings UI

**Custom Actions**:
- **FR-035**: System MUST load custom actions from YAML configuration with schema: action id, label, icon (emoji), action type (applescript/bash), and command/script content
- **FR-036**: System MUST broadcast custom actions list to PWA via WebSocket on initial connection
- **FR-037**: System MUST execute AppleScript commands when receiving custom action request with type "applescript"
- **FR-038**: System MUST execute Bash scripts when receiving custom action request with type "bash"
- **FR-039**: System MUST return execution result (success/error) to PWA within 2 seconds of action execution
- **FR-040**: System MUST prevent concurrent execution of the same custom action (queue or reject duplicate requests)
- **FR-041**: System MUST provide error messages when custom action fails (e.g., "Application 'Figma' not found", "Script execution failed: permission denied")
- **FR-042**: PWA MUST display custom actions as grid of square buttons with label and emoji icon
- **FR-043**: PWA MUST send custom action execution request to Mac when user taps action button
- **FR-044**: PWA MUST show loading indicator on button while action executes
- **FR-045**: PWA MUST display toast notification with success/error message after action completes
- **FR-046**: PWA MUST hide custom actions section when no actions are configured

### Key Entities

- **AgentInstance**: Represents a running AI coding agent process
  - Attributes: unique ID (UUID), PID, agent type (e.g., "claude-code"), working directory path, current status (idle/working/done/error), current task description (nullable), last activity timestamp, window identifier for focus switching, model name (nullable), git branch (nullable), active subagents array (nullable), todos array (nullable), current task description from activeForm (nullable)

- **SubagentInfo**: Represents an active subagent spawned by the main agent
  - Attributes: agent ID, type (e.g., "Explore", "general-purpose"), description

- **TodoItem**: Represents a task from the agent's todo list
  - Attributes: id, content (imperative form), status (pending/in_progress/completed), activeForm (present continuous form)

- **StatusUpdate**: Real-time status change event
  - Attributes: instance ID, new status value, current task text (nullable), timestamp
  - Broadcast via WebSocket when any tracked field changes

- **Configuration**: Application settings
  - Attributes: server port number, server host address, auto-start enabled flag, agent monitoring patterns (process name regexes)
  - Persisted to YAML file, loaded on app start

- **CustomAction**: User-defined command or script executable from PWA
  - Attributes: unique action ID, display label, emoji icon, action type (applescript/bash), command or script content, execution status
  - Loaded from YAML configuration, broadcast to PWA on connection

- **WebSocketConnection**: Active connection from mobile client
  - Attributes: connection ID, remote IP address, connected timestamp
  - Multiple concurrent connections supported

## Success Criteria *(mandatory)*

### Measurable Outcomes

**Performance & Responsiveness**:
- **SC-001**: Status updates appear on mobile device within 500ms of agent state change on Mac
- **SC-002**: Window switching executes within 1 second from mobile tap to Mac window focus
- **SC-003**: Mac app uses less than 100MB RAM during normal operation (monitoring 3 agents)
- **SC-004**: Mac app uses less than 2% CPU when idle, less than 5% when actively monitoring
- **SC-005**: Mac app launches and appears in menubar within 2 seconds of user double-clicking .app
- **SC-019**: Custom action execution completes within 2 seconds from mobile tap to Mac execution (excluding long-running scripts)

**User Experience & Setup**:
- **SC-006**: Users complete mobile setup (QR scan to home screen icon) in under 60 seconds
- **SC-007**: Mac app detects running Claude Code instances within 2 seconds of app startup
- **SC-008**: PWA loads and displays agent list within 3 seconds of opening URL
- **SC-009**: 90% of users successfully install and connect mobile device on first attempt without documentation

**Reliability & Stability**:
- **SC-010**: System handles 3+ concurrent Claude Code instances without performance degradation
- **SC-011**: PWA reconnects automatically within 5 seconds after network interruption
- **SC-012**: System runs continuously for 24+ hours without crashes or memory leaks
- **SC-013**: Window switching succeeds 95%+ of attempts when accessibility permissions granted
- **SC-020**: Custom actions fail gracefully with descriptive error messages when execution errors occur (app not found, permission denied, etc.)

**Platform Compatibility**:
- **SC-014**: Mac app runs on macOS 12 (Monterey) through macOS 14 (Sonoma) without compatibility issues
- **SC-015**: PWA works on iOS Safari 14+, Chrome 90+, and Android browsers without functionality loss
- **SC-016**: PWA "Add to Home Screen" functionality works on both iOS and Android devices

**Adoption & Validation** (Phase 1-2 End Goal):
- **SC-017**: 10+ early testers successfully run Agent Deck MVP without critical bugs
- **SC-018**: Positive feedback from Show HN launch indicating product-market fit potential
