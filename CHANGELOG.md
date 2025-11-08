# Changelog

All notable changes to Agent Deck will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned (Phase 2)
- Support for Cursor and Windsurf agents
- Custom actions (bash scripts, app launching)
- Configuration UI (settings window improvements)

---

## [0.1.1] - 2025-01-07

### Fixed
- **Process Detection:** Agent Deck now correctly counts Claude Code instances
  - BEFORE: Showed 14 instances when only 5 running (inflated count due to child processes)
  - AFTER: Shows accurate count (5 instances)
  - Filters out node helper processes (Zed external agents)
  - Filters out shell wrapper processes
  - Only counts main `claude` executable processes
  - Fixes confusing duplicate instance display

### Changed
- **Idle Display:** PWA now shows Claude's last statement instead of "Idle - Waiting for input"
  - When Claude finishes tasks, displays last meaningful statement
  - Example: "✅ Agent Deck killed successfully" instead of "Idle - Waiting for input"
  - "Waiting for input" only shown for new sessions or after `/clear`
  - Provides better context and continuity
  - Added `lastStatement` field to AgentInstance model (max 300 chars)

### Technical
- Added `isChildOfNodeProcess()` helper to filter process tree
- Enhanced `detectCLIProcesses()` with multi-level filtering
- Added `extractLastStatement()` to TranscriptParser
- Updated PWA display logic with 4-tier hierarchy (currentTask → lastStatement → waiting)
- Updated data model spec with lastStatement documentation

---

## [0.1.0] - 2025-01-06

### Added - MVP Release 🎉

**Core Features:**
- Real-time monitoring of Claude Code instances via FSEvents
- Rich data parsing from transcript files:
  - Model name (e.g., claude-sonnet-4-5-20250929)
  - Git branch detection
  - Current task description
  - Todo list with completion status
  - Subagent activity tracking
- One-tap window switching via AppleScript
- Progressive Web App mobile interface
  - Dark mode, touch-optimized UI
  - Expandable sections for detailed agent info
  - WebSocket real-time updates (< 500ms latency)
  - Installable on iOS/Android home screen
- QR code pairing for mobile setup
- Embedded HTTP server serving PWA files
- Embedded WebSocket server (port 3000)
- Native macOS menubar app (Swift/SwiftUI)
- First-run experience with permissions flow

**Technical:**
- FSEvents-based transcript file monitoring
- Combine reactive state management
- Thread-safe data handling (@MainActor)
- WebSocket protocol for client-server communication
- JSONL transcript parsing
- AppleScript integration for window management
- Local network only (no cloud dependencies)

**Documentation:**
- Comprehensive README.md
- Developer guide (CLAUDE.md)
- Testing procedures and test suite
- WebSocket protocol specification
- Lessons learned from implementation

### Known Limitations (MVP)
- macOS 12+ only (Monterey or later)
- Claude Code support only (other agents in Phase 2)
- Single Claude Code instance (multi-instance in Phase 2)
- Local network only (same WiFi required)
- No authentication (trusted local network assumed)
- No mobile interaction (monitoring only, no approval/rejection)
- PWA only (native mobile apps in Phase 3+ if demand exists)

### Known Issues
- First launch requires Gatekeeper bypass (right-click → Open)
- Accessibility permissions required for window switching
- WebSocket reconnection delay (1-2 seconds)
- Transcript file location hardcoded (may break if Claude Code changes paths)

---

## Version History

- **0.1.0** (2025-01-06) - MVP release with core monitoring and window switching
- **[Future]** - Cursor/Windsurf support, custom actions, configuration UI

---

## Legend

- **Added** - New features
- **Changed** - Changes to existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Vulnerability fixes

---

**Roadmap:** See `ROADMAP.md` for planned features
**Issues:** https://github.com/tonyofthehills/agent-deck/issues
**Releases:** https://github.com/tonyofthehills/agent-deck/releases
