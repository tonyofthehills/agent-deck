# Implementation Plan: Agent Deck MVP

**Branch**: `001-mvp` | **Date**: 2025-01-02 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-mvp/spec.md`

**⚠️ IMPORTANT**: See [CORRECTIONS.md](./CORRECTIONS.md) for critical updates to toolchain, polling interval, parsing scope, and testing strategy.

## Summary

Agent Deck MVP delivers a native macOS menubar application that monitors running AI coding agents (Claude Code) with real-time status broadcasting to a Progressive Web App accessible from mobile devices. Users can view agent status, switch windows remotely, and complete setup in under 60 seconds via QR code pairing. The system operates entirely on local network with zero cloud dependencies, targeting 2-week delivery for Show HN launch.

**Technical Approach**: Native Swift/SwiftUI Mac app embedding WebSocket + HTTP servers to communicate with vanilla JavaScript PWA. Process monitoring via NSWorkspace, window control via AppleScript, stdout parsing for task extraction. Single .app bundle distribution with embedded Resources/WebRoot/ for PWA files.

## Technical Context

**Language/Version**: Swift 5.7+ (Swift 6 compatible targeting macOS 12+)
**Primary Dependencies**:
- SwiftUI (UI framework)
- Combine (reactive state management)
- Network.framework or Vapor (WebSocket/HTTP server)
- Yams (YAML configuration parsing)
- NSWorkspace (process monitoring)
- NSAppleScript (window management)

**Storage**:
- UserDefaults (app preferences: port, auto-start)
- YAML files (configuration at ~/.agent-deck/config.yaml)
- LocalStorage (PWA client-side: display settings)
- In-memory state (agent instances, connections)

**Testing**: Manual testing in Phase 1-2 (XCTest framework for Phase 3+)

**Target Platform**:
- Mac: macOS 12+ (Monterey through Sonoma)
- Mobile: iOS Safari 14+, Chrome 90+, Android browsers (PWA)

**Project Type**: Hybrid (Native Mac app + embedded PWA web interface)

**Performance Goals**:
- <500ms status update latency (Mac → mobile)
- <1s window switching latency (mobile tap → Mac window focus)
- <100MB RAM usage (monitoring 3 agents)
- <2% CPU idle, <5% CPU active
- <2s app launch time

**Constraints**:
- Local network only (no WAN access)
- No authentication layer in MVP
- No cloud services/external APIs
- Single .app bundle (no runtime dependencies like Node.js)
- PWA vanilla JavaScript (no build step, no React/Vue)
- Claude Code monitoring only (Cursor/Windsurf in Phase 3+)

**Scale/Scope**:
- 3-10 concurrent agent instances
- 1-5 concurrent mobile clients
- 10+ early testers for MVP validation
- 2-week development timeline

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Speed to Market ✅

**Requirement**: 2-week MVP, no scope creep, working features over polish

**Compliance**:
- ✅ Plan targets 2-week delivery (Week 1: Mac app, Week 2: PWA + window switching)
- ✅ Scope limited to P1 user stories (monitoring, window switching, QR setup)
- ✅ Manual testing acceptable in Phase 1-2
- ✅ P2 features deferred (parsed output, zero-config can slip)

**Status**: PASS

---

### Principle II: Mac-First Architecture ✅

**Requirement**: Native Swift menubar app, no Electron, single .app bundle

**Compliance**:
- ✅ Swift 5.7+ with SwiftUI for Mac app
- ✅ Menubar-only (NSStatusBar, no dock icon)
- ✅ macOS integration (NSWorkspace, NSAppleScript, Network.framework)
- ✅ Single .app bundle with embedded WebSocket/HTTP servers
- ✅ No Node.js runtime required

**Status**: PASS

---

### Principle III: Mobile Validation Strategy ✅

**Requirement**: PWA first, native mobile only after 100+ users validate

**Compliance**:
- ✅ PWA using vanilla JavaScript (no build step)
- ✅ Works on iOS Safari, Chrome, Android browsers
- ✅ "Add to Home Screen" installable
- ✅ Native mobile apps explicitly deferred to Phase 7+ (not in scope)

**Status**: PASS

---

### Principle IV: Local-First ✅

**Requirement**: No cloud dependencies, local network only, YAML config

**Compliance**:
- ✅ WebSocket server binds to local network (0.0.0.0:3000)
- ✅ No authentication layer
- ✅ No external API calls (except monitoring Claude Code stdout)
- ✅ Configuration via ~/.agent-deck/config.yaml
- ✅ No cloud services

**Status**: PASS

---

### Principle V: Developer Audience ✅

**Requirement**: Functionality over polish, clear errors, text-based config

**Compliance**:
- ✅ Manual testing acceptable in Phase 1-2
- ✅ YAML configuration (not hidden in UI)
- ✅ Error messages specified in FR-031 (accessibility), edge cases
- ✅ Working features prioritized (P1 before P2)
- ✅ Technical limitations documented (local network requirement)

**Status**: PASS

---

**GATE RESULT**: ✅ ALL PRINCIPLES SATISFIED - Proceed to Phase 0

## Project Structure

### Documentation (this feature)

```text
specs/001-mvp/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0: Technology research
├── data-model.md        # Phase 1: Entity design
├── quickstart.md        # Phase 1: Developer setup guide
├── contracts/           # Phase 1: API contracts
│   └── websocket-protocol.md
└── checklists/
    └── requirements.md  # Spec validation checklist
```

### Source Code (repository root)

```text
AgentDeck-Mac/                      # Xcode project
├── AgentDeck.xcodeproj
├── Sources/
│   ├── AgentDeckApp.swift          # Main app entry (@main)
│   ├── AppDelegate.swift           # Menubar app lifecycle
│   ├── Models/
│   │   ├── AgentInstance.swift     # Agent process model
│   │   ├── StatusUpdate.swift      # WebSocket message model
│   │   ├── Configuration.swift     # App config model
│   │   └── AgentStatus.swift       # Enum: idle/working/done/error
│   ├── Services/
│   │   ├── ProcessMonitor.swift    # NSWorkspace process polling
│   │   ├── OutputParser.swift      # Claude Code stdout parser
│   │   ├── WebSocketServer.swift   # Real-time communication
│   │   ├── HTTPServer.swift        # Serves PWA files
│   │   ├── WindowManager.swift     # AppleScript window focus
│   │   └── ConfigManager.swift     # YAML config loader
│   ├── Views/
│   │   ├── MenuBarView.swift       # Menubar dropdown UI
│   │   ├── SettingsView.swift      # Settings window
│   │   ├── AgentListView.swift     # Agent status list
│   │   └── QRCodeView.swift        # QR code for pairing
│   └── Utilities/
│       ├── Logger.swift             # Logging utility
│       └── QRGenerator.swift        # QR code generation
├── Resources/
│   ├── Assets.xcassets              # App icons
│   ├── default-config.yaml          # Default configuration template
│   └── WebRoot/                     # ⭐ Embedded PWA
│       ├── index.html               # Mobile UI
│       ├── app.js                   # WebSocket client + UI logic
│       ├── styles.css               # Dark mode mobile styles
│       ├── manifest.json            # PWA manifest
│       ├── service-worker.js        # Offline support
│       └── icons/
│           ├── icon-192.png
│           └── icon-512.png
└── Info.plist

# User configuration (created at runtime)
~/.agent-deck/
└── config.yaml                      # User-editable configuration
```

**Structure Decision**: Hybrid Mac + PWA structure chosen because:
1. Mac app is the core product (native menubar app with embedded servers)
2. PWA is embedded within Mac app Resources/WebRoot/ (not a separate project)
3. Single distribution unit (.app bundle) containing both components
4. Aligns with "single .app bundle" constitutional requirement
5. Enables 2-week delivery (no multi-project coordination overhead)

## Complexity Tracking

> No constitutional violations to justify. All principles satisfied.

---

## Phase 0: Research (Completed Inline)

All technology decisions resolved from constitution's Technology Constraints section and CLAUDE.md guidance:

### Decision 1: WebSocket Server Framework

**Decision**: Start with Swift Network.framework, migrate to Vapor if needed

**Rationale**:
- Network.framework built into Swift (no external dependencies)
- Lightweight for simple WebSocket broadcasting
- Vapor available as fallback if HTTP file serving proves complex
- Constitution requires single .app bundle (both options satisfy)

**Alternatives Considered**:
- Vapor immediately: More overhead, but easier HTTP + WebSocket in one
- Node.js server: Violates "single .app bundle" principle

**Implementation Note**: Evaluate Network.framework first (Week 1 Day 1-2), migrate to Vapor only if file serving becomes blocker

---

### Decision 2: Process Monitoring Approach

**Decision**: NSWorkspace.runningApplications polling every 1-2 seconds

**Rationale**:
- NSWorkspace is native macOS API (no external dependencies)
- Polling approach simple and reliable for MVP
- FR-024 specifies 1-2 second poll interval
- Can detect new instances and terminations

**Alternatives Considered**:
- Launch Services notifications: More complex, overkill for MVP
- `ps` command parsing: Fragile, less reliable than NSWorkspace

**Implementation Note**: Use `NSWorkspace.shared.runningApplications` filtered by executable name pattern

---

### Decision 3: Claude Code Output Parsing

**Decision**: Stdout pattern matching with regex for "Currently:" prefix

**Rationale**:
- FR-021 specifies parsing "Currently:" line
- Simple regex pattern matching sufficient for MVP
- Graceful degradation (FR-023: show "Unknown" if pattern fails)

**Alternatives Considered**:
- Structured logging integration: Too complex for MVP, requires Claude Code modification
- Machine learning-based extraction: Over-engineered for simple pattern

**Implementation Note**: Use `NSRegularExpression` or basic String methods to find "Currently:" prefix

---

### Decision 4: Configuration Storage

**Decision**: YAML for user config (~/.agent-deck/config.yaml), UserDefaults for app preferences

**Rationale**:
- Constitution requires "text-based (YAML)" configuration
- UserDefaults for simple flags (port, auto-start) persisted by macOS
- YAML for complex config (agent patterns, custom actions in Phase 4+)
- Developer-friendly (easy to edit, version control)

**Alternatives Considered**:
- JSON: Less human-readable than YAML
- Plist: Not text-friendly for developers

**Implementation Note**: Use Yams library for YAML parsing (Swift Package Manager dependency)

---

### Decision 5: QR Code Generation

**Decision**: CoreImage CIQRCodeGenerator filter

**Rationale**:
- Built into macOS (no external dependencies)
- Simple API for generating QR code images
- Native integration with SwiftUI Image views

**Alternatives Considered**:
- Third-party QR library: Unnecessary, CoreImage sufficient
- HTML canvas QR generation: Wrong layer (need Mac-side QR display)

**Implementation Note**: See CLAUDE.md lines 840-865 for reference implementation pattern

---

### Decision 6: Window Switching Mechanism

**Decision**: NSAppleScript to focus window by PID

**Rationale**:
- AppleScript can focus windows and switch Spaces (FR-029)
- NSAppleScript built into macOS
- Handles cross-Space window switching automatically
- Requires accessibility permissions (FR-031 documents this)

**Alternatives Considered**:
- Accessibility API (AXUIElement): More complex, same permissions needed
- CGWindowListCopyWindowInfo + focus: Doesn't switch Spaces reliably

**Implementation Note**: Script pattern: `tell application "System Events" to set frontmost of first process whose unix id is <PID> to true`

---

## Phase 1: Design & Contracts

### Data Model

See [data-model.md](./data-model.md) for complete entity definitions.

**Core Entities**:
1. **AgentInstance** - Running agent process
2. **StatusUpdate** - WebSocket message
3. **Configuration** - App settings
4. **AgentStatus** - Enum (idle/working/done/error)

### API Contracts

See [contracts/websocket-protocol.md](./contracts/websocket-protocol.md) for complete WebSocket protocol.

**WebSocket Events**:
- Server → Client: `update`, `instance_change`, `connection_status`
- Client → Server: `focus`, `ping`

### Quickstart

See [quickstart.md](./quickstart.md) for developer setup instructions.

---

## Implementation Phases

### Week 1: Mac Application Core

**Days 1-2: Project Setup + Process Monitoring**
- Create Xcode project (macOS App, SwiftUI)
- Setup menubar app structure (AppDelegate, NSStatusBar)
- Implement ProcessMonitor service (NSWorkspace polling)
- Basic AgentInstance model
- Display detected instances in menubar dropdown

**Days 3-4: WebSocket Server + Configuration**
- Implement WebSocketServer (Network.framework or Vapor)
- Implement ConfigManager (Yams YAML parsing)
- Create default config template
- Broadcast status updates to connected clients
- Basic error handling

**Days 5-7: QR Code + HTTP Server**
- Implement HTTPServer for serving PWA files
- Generate QR code with local network URL
- Display QR code in menubar dropdown
- Test server with browser access
- Settings window (basic: port configuration)

### Week 2: PWA + Window Switching

**Days 8-9: PWA Mobile Interface**
- Create index.html with mobile-optimized layout
- Implement WebSocket client (app.js)
- Display agent list with status indicators
- Real-time status updates
- Connection status indicator
- Dark mode CSS

**Days 10-11: Window Switching**
- Implement WindowManager (AppleScript execution)
- Handle tap events on mobile → send focus command
- Return success/failure status
- Error messaging for missing accessibility permissions
- Test cross-Space window switching

**Days 12-13: PWA Polish + Testing**
- Implement PWA manifest.json
- Implement service worker for offline capability
- "Add to Home Screen" functionality
- Test on iOS Safari, Android Chrome
- Edge case handling (disconnect/reconnect, sleep/wake)

**Day 14: Integration Testing + Bug Fixes**
- End-to-end testing (Mac + mobile)
- Performance validation (latency <500ms, <1s)
- Edge case testing (multiple instances, network changes)
- Critical bug fixes
- Prepare for Show HN launch

---

## Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Network.framework complexity | Medium | Switch to Vapor framework if HTTP serving difficult (Day 3 decision point) |
| Accessibility permissions UX | Medium | Clear error messages (FR-031), prompt on first window switch attempt |
| AppleScript window switching reliability | High | Test cross-Space switching early (Day 10), fallback to activation without Space switch if needed |
| PWA "Add to Home Screen" browser compatibility | Medium | Test on iOS Safari 14+, Chrome 90+ early (Day 12), document browser requirements |
| QR code readability on small screens | Low | Generate high-resolution QR code (scale factor 10x), test scanning distance |
| Claude Code process detection pattern | Medium | Use flexible executable name matching (regex), test with multiple Claude Code versions |

---

## Success Metrics Validation

All 18 success criteria from spec.md will be validated during Day 14 integration testing:

- **SC-001 to SC-005**: Performance & responsiveness
- **SC-006 to SC-009**: User experience & setup
- **SC-010 to SC-013**: Reliability & stability
- **SC-014 to SC-016**: Platform compatibility
- **SC-017 to SC-018**: Adoption & validation

See [spec.md](./spec.md#success-criteria-mandatory) for complete criteria.

---

## Next Steps

1. **Immediate**: `/speckit.tasks` to break Week 1-2 plan into executable tasks
2. **Week 1 Start**: Begin Mac app core development
3. **Week 2 Start**: Shift to PWA + window switching
4. **Day 14 End**: Ship to Show HN, gather early user feedback
5. **Post-MVP**: Iterate based on user feedback (Phase 3+)
