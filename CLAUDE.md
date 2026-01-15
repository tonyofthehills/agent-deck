# CLAUDE.md - Agent Deck

Project-specific guidance for Claude Code.

---

## Quick Links

| Guide | Purpose |
|-------|---------|
| [Quick Start](docs/guides/QUICK_START.md) | Get running in 5 minutes |
| [Swift Guide](docs/guides/SWIFT_GUIDE.md) | macOS app patterns |
| [React Native Guide](docs/guides/REACT_NATIVE_GUIDE.md) | Mobile app patterns |
| [MCP Integration](docs/guides/MCP_INTEGRATION.md) | MCP server usage |
| [Security](docs/guides/SECURITY.md) | Semgrep scanning |
| [Testing](docs/guides/TESTING_GUIDE.md) | Test procedures |
| [Lessons Learned](docs/guides/LESSONS_LEARNED.md) | Critical patterns |
| [Documentation Index](docs/README.md) | Full docs index |

---

## Project Overview

**Agent Deck** - Stream Deck for AI agents. Monitor Claude Code, Cursor, and other agentic coding tools from your phone.

**Repository:** `/Users/tonyofthehills/dev/apps/app-009-agent-deck/`

**Platform:**
- **Mac**: Native Swift/SwiftUI dock app
- **Mobile**: React Native + Expo (iOS/Android)
- **Web**: PWA backup interface

**Status**: MVP 92% complete (122/132 tasks). Ready for testing.

---

## Core Principles

1. **Speed to Market** - 2.5-week MVP, iterate based on feedback
2. **Mac-First** - Native Swift dock app is core product
3. **Mobile-Native** - React Native, not PWA, for mobile
4. **Local-First** - No cloud dependencies, local network only
5. **Developer Audience** - Functionality over polish

---

## Behavioral Guidelines

### ALWAYS
- Check documentation at session start
- Update task checkboxes when completing work
- Use subagents for research/exploration
- Add lessons to `docs/guides/LESSONS_LEARNED.md` after fixing unexpected issues

### NEVER
- Eliminate functionality to force completion
- Make workarounds for issues that need solving later

---

## Tech Stack

### macOS App
- **Language**: Swift 6 (macOS 12+)
- **UI**: SwiftUI
- **Frameworks**: Combine, Network.framework, NSWorkspace, NSAppleScript

### Mobile App
- **Framework**: React Native 0.73+ (Expo SDK 50+)
- **Language**: TypeScript 5.0+
- **Package Manager**: pnpm (monorepo)

### Current Versions (2025)
| Platform | Version |
|----------|---------|
| macOS | 26.0 (Tahoe) |
| Xcode | 18.0 |
| Swift | 6.0 |
| iOS | 26.1 |
| Expo SDK | 52 |

---

## File Structure

```
agent-deck/
├── apps/
│   ├── macos/Agent-Deck/     # Swift dock app
│   │   └── Agent-Deck/
│   │       ├── Models/       # Data models
│   │       ├── Services/     # Core services
│   │       ├── Views/        # SwiftUI views
│   │       └── Utilities/    # Helpers
│   └── mobile/               # React Native app
│       └── src/
│           ├── screens/      # App screens
│           ├── components/   # UI components
│           ├── hooks/        # Custom hooks
│           └── services/     # WebSocket, etc.
├── packages/shared-types/    # Shared TypeScript types
├── specs/001-mvp/            # MVP specifications
├── docs/                     # Documentation
│   ├── guides/               # Development guides
│   ├── release/              # Release materials
│   └── archive/              # Historical docs
└── .specify/                 # SpecKit artifacts
```

---

## Development Commands

### Setup
```bash
pnpm install                  # Install all dependencies
cd apps/macos && open Agent-Deck/AgentDeck.xcodeproj  # Open Xcode
```

### Running
```bash
# Mac app: Xcode → Command+R

# Mobile
pnpm mobile                   # Expo dev server
pnpm mobile:android           # Android (priority)
pnpm mobile:ios               # iOS simulator
```

### Mobile Testing (Android Priority)
```bash
# Physical Pixel 7a (PREFERRED)
adb devices                   # Should show 35051JEHN13181
cd apps/mobile && npx expo start --android --clear

# Android emulator (fallback)
$ANDROID_HOME/emulator/emulator -avd "Medium_Phone_API_36.1" &
```

---

## MCP Servers

**Always use subagents for research/exploration tasks.**

| Server | Use For | Direct/Subagent |
|--------|---------|-----------------|
| Exa | Web research | Subagent |
| Ref | Documentation | Subagent |
| Context7 | Library docs | Subagent |
| Perplexity | Deep research | Subagent (only when user requests) |
| Pieces | Historical context | Subagent |
| Semgrep | Security scans | Direct |
| XcodeBuildMCP | Build/test/run | Direct |
| iOS Simulator MCP | UI automation | Direct |
| GitHub | Issues, PRs | Direct |

### XcodeBuildMCP Quick Reference

```
# Build macOS app
mcp__XcodeBuildMCP__build_macos({
  projectPath: ".../apps/macos/Agent-Deck/AgentDeck.xcodeproj",
  scheme: "AgentDeck"
})

# Build and run
mcp__XcodeBuildMCP__build_run_macos({ ... })

# Run tests
mcp__XcodeBuildMCP__test_macos({ ... })

# Clean
mcp__XcodeBuildMCP__clean({ ..., platform: "macOS" })
```

**Full details:** [MCP Integration Guide](docs/guides/MCP_INTEGRATION.md)

---

## iOS Simulator (Dedicated)

| Setting | Value |
|---------|-------|
| Simulator Name | `iPhone 17 - AgentDeck` |
| Metro Port | `8084` |
| Runtime | iOS 26.1 |

**Always pass UDID to MCP calls when using iOS Simulator MCP.**

---

## Security Scanning

**Scan before committing:**
- AI-generated code
- Auth/WebSocket changes
- File operations
- New dependencies

```bash
# Swift
semgrep_scan: apps/macos/*/Sources/**/*.swift

# React Native
semgrep_scan: apps/mobile/src/**/*.{ts,tsx}
```

**Full guide:** [Security Guide](docs/guides/SECURITY.md)

---

## SpecKit Workflow

```bash
/speckit.constitution        # Define principles
/speckit.specify             # Create spec
/speckit.plan                # Generate plan
/speckit.tasks               # Break into tasks
/speckit.implement           # Start coding
```

Files in `.specify/memory/`. Don't edit directly.

---

## Common Pitfalls

| Don't | Do |
|-------|-----|
| Use npm/yarn | Use pnpm |
| Import relative from shared | Use `@agent-deck/shared-types` |
| Store secrets in AsyncStorage | Use expo-secure-store |
| Bind WebSocket to 127.0.0.1 | Use 0.0.0.0:3000 |
| Forget Accessibility permissions | Grant in System Settings |

---

## Critical Lessons

### FSEvents C Pointer Handling
**Never cast eventPaths to CFArray/NSArray.** Use `assumingMemoryBound(to: UnsafePointer<CChar>.self)`.

### @Published with Structs
**Mutating array elements in-place doesn't trigger Combine.** Replace the element:
```swift
var updated = instances[index]
updated.currentTask = "new"
instances[index] = updated  // Triggers @Published
```

**Full list:** [Lessons Learned](docs/guides/LESSONS_LEARNED.md)

---

## Debugging

```bash
# Check WebSocket server
lsof -i :3000

# Mac app logs
log stream --predicate 'subsystem == "com.agentdeck.app"'

# Clear Expo cache
pnpm mobile -- --clear
```

---

## External AI Tools

```bash
# Gemini CLI - Deep research
gemini -m gemini-3-pro-preview "question"

# Codex CLI - Code review
codex exec "Review this codebase for [concern]"
```

---

## Claude Memory

| Command | Purpose |
|---------|---------|
| `/memory-context` | Retrieve previous session context |
| `/memory-save` | Save notes before ending session |

Sessions auto-log via SessionEnd hook.

---

## Version

**CLAUDE.md Version:** 4.0
**Last Updated:** 2026-01-15
**Status:** MVP 92% complete

### Recent Changes
- 2026-01-15: Major restructure - moved 51 files to archive, created docs/guides/ structure
- 2025-12-10: MVP development complete (122/132 tasks)
- 2025-11-25: Converted from menubar to dock app

---

**Remember:** Speed to market. Ship, validate, iterate.
