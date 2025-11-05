# Research: Agent Deck MVP Technology Decisions

**Feature**: Agent Deck MVP (Phases 1-2)
**Date**: 2025-01-02
**Status**: Completed

## Overview

This document captures technology research and decision rationale for Agent Deck MVP implementation. All decisions align with constitutional principles (Mac-First Architecture, Local-First, Developer Audience, Speed to Market, Mobile Validation Strategy).

---

## Decision 1: WebSocket Server Framework

### Context
Need embedded WebSocket server for real-time Mac → mobile communication. Server must be embedded in Swift .app bundle (no separate Node.js process).

### Options Evaluated

| Option | Pros | Cons | Constitutional Alignment |
|--------|------|------|-------------------------|
| **Swift Network.framework** | Built-in, lightweight, no dependencies | Manual WebSocket protocol handling | ✅ Single .app bundle |
| **Vapor framework** | Full HTTP + WebSocket, easier file serving | Heavier dependency, more overhead | ✅ Single .app bundle |
| **Node.js + Express** | Simple, familiar patterns | Violates single .app bundle | ❌ Requires Node.js runtime |

### Decision

**Start with Swift Network.framework, migrate to Vapor if HTTP file serving proves complex**

### Rationale

- Network.framework built into Swift standard library (zero additional dependencies)
- Lightweight for simple WebSocket broadcasting use case
- Vapor available as fallback if HTTP static file serving becomes blocker
- Both options satisfy "single .app bundle" constitutional requirement
- Decision point: Day 3 of Week 1 (after initial HTTP server attempt)

### Implementation Notes

- Use `NWListener` for TCP server on port 3000
- Manual WebSocket handshake implementation (upgrade from HTTP)
- Broadcast JSON messages to all connected clients
- Reference: Swift Network.framework documentation (macOS 12+)

---

## Decision 2: Process Monitoring Approach

### Context
Need to detect running Claude Code processes, track lifecycle (start/terminate), extract metadata (PID, working directory, window ID).

### Options Evaluated

| Option | Pros | Cons | Constitutional Alignment |
|--------|------|------|-------------------------|
| **NSWorkspace.runningApplications polling** | Native macOS API, reliable, simple | Polling overhead (1-2s interval) | ✅ Native integration |
| **Launch Services notifications** | Event-driven, lower overhead | Complex setup, overkill for MVP | ⚠️ Over-engineered |
| **`ps` command parsing** | Simple shell execution | Fragile, unreliable, no window ID | ❌ Not production-quality |

### Decision

**NSWorkspace.runningApplications polling every 1-2 seconds**

### Rationale

- NSWorkspace is native macOS AppKit API (no external dependencies)
- Polling approach simple and reliable for MVP
- FR-024 explicitly specifies 1-2 second poll interval
- Can detect new instances and terminations
- Provides executable path, PID, and localized name
- Aligns with "Functionality over polish" (developer audience principle)

### Implementation Notes

- Use `NSWorkspace.shared.runningApplications`
- Filter by executable name pattern (regex: `claude.*code`)
- Extract PID via `processIdentifier` property
- Use `lsof -p <PID> -a -d cwd -F n` for working directory
- Timer.publish(every: 2.0) with Combine for polling loop

---

## Decision 3: Claude Code Output Parsing

### Context
Need to extract "current task" line from Claude Code stdout for display on mobile (P2 user story).

### Options Evaluated

| Option | Pros | Cons | Constitutional Alignment |
|--------|------|------|-------------------------|
| **Regex pattern matching ("Currently:")** | Simple, reliable for known pattern | Fragile to format changes | ✅ MVP-appropriate |
| **Structured logging integration** | Robust, flexible | Requires Claude Code modification | ❌ Out of scope |
| **ML-based extraction** | Handles unknown patterns | Over-engineered, slow | ❌ Violates simplicity |

### Decision

**Stdout pattern matching with regex for "Currently:" prefix**

### Rationale

- FR-021 explicitly specifies parsing line starting with "Currently:"
- Simple NSRegularExpression or String.contains() sufficient
- Graceful degradation specified (FR-023: show "Unknown" if pattern fails)
- Aligns with "Functionality over polish" principle
- Can be enhanced in Phase 3+ if pattern proves unreliable

### Implementation Notes

- Pattern: `Currently: (.+)`
- Capture group 1 = task description
- Fallback: Display last known task or "Unknown"
- No PTY wrapper needed in MVP (read from log files or process output cache)

---

## Decision 4: Configuration Storage

### Context
Need to store user preferences (server port, auto-start) and agent monitoring patterns (process names, custom actions in Phase 4+).

### Options Evaluated

| Option | Pros | Cons | Constitutional Alignment |
|--------|------|------|-------------------------|
| **YAML files + UserDefaults** | Text-editable, version-controllable | Two storage mechanisms | ✅ Text-based config required |
| **JSON files only** | Simpler, single mechanism | Less human-readable than YAML | ⚠️ Not as developer-friendly |
| **Plist only** | Native macOS format | Not text-friendly for developers | ❌ Violates developer audience principle |

### Decision

**YAML for user config (~/.agent-deck/config.yaml), UserDefaults for app preferences**

### Rationale

- Constitution explicitly requires "text-based (YAML)" configuration
- UserDefaults for simple flags persisted by macOS (port, auto-start)
- YAML for complex config (agent patterns, custom actions in Phase 4+)
- Developer-friendly (easy to edit in any text editor, git-friendly)
- Separation of concerns (app prefs vs user config)

### Implementation Notes

- Use Yams Swift library for YAML parsing (Swift Package Manager)
- Config location: `~/.agent-deck/config.yaml`
- Create default config on first launch if missing
- UserDefaults keys: `serverPort`, `autoStartOnLogin`
- YAML schema validation on load (fail gracefully with defaults)

---

## Decision 5: QR Code Generation

### Context
Need to generate QR code with local network URL (e.g., `http://192.168.1.100:3000`) for mobile device pairing (P1 user story).

### Options Evaluated

| Option | Pros | Cons | Constitutional Alignment |
|--------|------|------|-------------------------|
| **CoreImage CIQRCodeGenerator** | Built-in macOS, zero dependencies | Requires CoreImage knowledge | ✅ Native integration |
| **Third-party QR library** | Simpler API | External dependency | ⚠️ Unnecessary complexity |
| **HTML canvas (server-side render)** | Cross-platform | Wrong layer (need Mac-side QR) | ❌ Misaligned architecture |

### Decision

**CoreImage CIQRCodeGenerator filter**

### Rationale

- Built into macOS Core Image framework (no external dependencies)
- Simple API for generating QR code CIImage
- Native integration with SwiftUI Image views
- Aligns with "Mac-First Architecture" principle
- Reference implementation available in CLAUDE.md lines 840-865

### Implementation Notes

- Use `CIFilter(name: "CIQRCodeGenerator")`
- Input: Local network URL string (http://<local-ip>:3000)
- Scale transform: 10x for readability
- Convert CIImage → NSImage → SwiftUI Image
- Display in menubar dropdown alongside "View Mobile Interface" text

---

## Decision 6: Window Switching Mechanism

### Context
Need to bring Claude Code window to front when user taps instance on mobile (P1 user story). Must handle cross-Space window switching.

### Options Evaluated

| Option | Pros | Cons | Constitutional Alignment |
|--------|------|------|-------------------------|
| **NSAppleScript (System Events)** | Built-in, handles Spaces switching | Requires accessibility permissions | ✅ Native integration |
| **Accessibility API (AXUIElement)** | Direct window control | Complex, same permissions, no Space switch | ⚠️ More complex |
| **CGWindowListCopyWindowInfo + focus** | Low-level control | Doesn't switch Spaces reliably | ❌ Incomplete solution |

### Decision

**NSAppleScript to focus window by process PID**

### Rationale

- AppleScript can focus windows AND switch macOS Spaces automatically (FR-029)
- NSAppleScript built into Foundation framework
- Handles cross-Space window switching (critical for user story)
- Requires accessibility permissions (FR-031 documents this requirement)
- Simpler than Accessibility API for MVP use case

### Implementation Notes

- Script pattern: `tell application "System Events" to set frontmost of first process whose unix id is <PID> to true`
- Wrap in `NSAppleScript(source:)` and execute
- Check for accessibility permissions before first execution
- Return success/failure status to mobile client (FR-030)
- Error message: "Agent Deck needs Accessibility permissions to switch windows" (FR-031)

---

## Decision 7: PWA Offline Strategy

### Context
Need basic offline capability for PWA (FR-019: service worker for cached UI shell).

### Options Evaluated

| Option | Pros | Cons | Constitutional Alignment |
|--------|------|------|-------------------------|
| **Service Worker cache-first** | Full offline UI | Complex cache invalidation | ⚠️ Over-engineered for MVP |
| **Service Worker network-first** | Fresh content, fallback cache | Requires careful cache strategy | ✅ Balanced for MVP |
| **No service worker** | Simplest | No offline capability | ❌ Violates FR-019 |

### Decision

**Service Worker with network-first strategy, cache UI shell as fallback**

### Rationale

- Network-first ensures fresh content when online
- Cache UI shell (HTML/CSS/JS) for offline access
- Aligns with "basic offline capability" requirement (FR-019)
- Simple enough for 2-week MVP timeline
- Progressive enhancement (works without service worker in older browsers)

### Implementation Notes

- Cache static assets (index.html, app.js, styles.css, manifest.json, icons)
- Network-first for WebSocket connection (graceful degradation)
- Service worker lifecycle: install → activate → fetch
- Cache version: `v1` (increment for updates)
- Fallback: Display "Offline - Waiting for connection" when cache used

---

## Decision 8: Local Network IP Discovery

### Context
Need to determine Mac's local network IP address for QR code generation and mobile connection.

### Options Evaluated

| Option | Pros | Cons | Constitutional Alignment |
|--------|------|------|-------------------------|
| **getifaddrs() + filter en0** | Reliable, native C API | Low-level C API complexity | ✅ Native integration |
| **Third-party network library** | Simpler Swift API | External dependency | ⚠️ Unnecessary |
| **Shell command (`ifconfig`)** | Simple | Fragile, parsing-dependent | ❌ Not production-quality |

### Decision

**getifaddrs() filtering en0 (WiFi interface) for IPv4 address**

### Rationale

- Native POSIX API available on macOS
- Reliable for finding local network IP
- Reference implementation in CLAUDE.md lines 871-898
- No external dependencies
- Handles multiple network interfaces gracefully

### Implementation Notes

- Call `getifaddrs(&ifaddr)` from Foundation
- Iterate interfaces, filter by name == "en0" (WiFi)
- Filter by address family == AF_INET (IPv4)
- Extract address via `getnameinfo()`
- Fallback: Display error if no WiFi interface active

---

## Summary of Technology Stack

**Mac Application**:
- Language: Swift 5.7+ (Swift 6 compatible)
- UI: SwiftUI (native macOS)
- Reactive: Combine framework
- Server: Network.framework or Vapor (decision Day 3)
- Config: Yams (YAML parsing)
- APIs: NSWorkspace, NSAppleScript, CoreImage, getifaddrs()

**Mobile Interface (PWA)**:
- Language: Vanilla JavaScript (ES6+)
- No build tools (no webpack/vite/babel)
- Offline: Service Worker (network-first strategy)
- Storage: localStorage (display settings)

**Communication Protocol**:
- WebSocket (JSON messages)
- HTTP (static file serving for PWA)

**Development Tools**:
- Xcode 14.0+
- Swift Package Manager (dependencies)
- Manual testing (Phase 1-2)

---

## Risks & Mitigations

See [plan.md Risk Mitigation section](./plan.md#risk-mitigation) for complete risk table.

**Key Risks Addressed by Research**:
1. **Network.framework complexity**: Vapor as fallback (Day 3 decision)
2. **AppleScript reliability**: Tested early (Day 10), fallback to activation without Space switch
3. **QR code readability**: High-resolution generation (10x scale factor)
4. **Process detection**: Flexible regex matching for Claude Code variants

---

## References

- Swift Network.framework: [Apple Developer Documentation](https://developer.apple.com/documentation/network)
- Vapor framework: [https://vapor.codes/](https://vapor.codes/)
- NSWorkspace: [Apple Developer Documentation](https://developer.apple.com/documentation/appkit/nsworkspace)
- CoreImage QR: [Apple Developer Documentation](https://developer.apple.com/documentation/coreimage)
- PWA Service Workers: [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- CLAUDE.md: Project-specific implementation patterns (lines 451-1097)
- Constitution: `.specify/memory/constitution.md`
