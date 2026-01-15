# CLAUDE.md - Agent Deck

**Project-specific guidance for Claude Code when working on Agent Deck**

---

## Current Environment

**Last Updated:** November 2025

**When researching libraries, APIs, or best practices, always use these current versions to find the most up-to-date information:**

### macOS App (Swift/SwiftUI)
| Platform/Tool | Current Version | Notes |
|---------------|-----------------|-------|
| macOS | 26.0 (Tahoe) | Latest stable |
| Xcode | 18.0 | Latest stable |
| Swift | 6.0 | Swift 6 with strict concurrency |
| SwiftUI | Latest (macOS 26+) | Use modern APIs |

### Mobile App (React Native)
| Platform/Tool | Current Version | Notes |
|---------------|-----------------|-------|
| iOS/iPadOS | 26.1 | Latest stable |
| Android | API 35 (Android 15) | Latest stable |
| Node.js | 22.x LTS | Use LTS version |
| React Native | 0.76.x | Check Expo SDK compatibility |
| Expo SDK | 52 | Latest stable |
| TypeScript | 5.6.x | Latest stable |

**Year:** 2025

**Research Tips:**
- When searching documentation, include "2025" or the specific version numbers above
- For Swift macOS apps, include "Swift 6" and "SwiftUI" in searches
- For React Native, check Expo SDK compatibility matrix
- Prefer official documentation over older blog posts
- For SwiftUI macOS, look for macOS 26+ patterns

**Maintenance:** Update this section at the start of each month or when major releases occur. Check Apple platform updates, Expo SDK releases, and React Native versions.

---

## Quick Links 🔗

- 🚀 **[Quick Start Guide](./QUICK_START.md)** - Get started in 5 minutes
- 🔌 **[MCP Integration](./MCP_INTEGRATION.md)** - MCP server usage (Exa, Ref, Context7, Pieces, Semgrep)
- 🔒 **[Security Guide](./SECURITY.md)** - Security scanning with Semgrep MCP
- 🔨 **[XcodeBuildMCP](#xcodebuildmcp-integration-)** - Build, test, and automate Xcode projects
- ⚛️ **[React Native Guide](./REACT_NATIVE_GUIDE.md)** - Mobile development patterns
- 🍎 **[Swift Guide](./SWIFT_GUIDE.md)** - macOS app development patterns
- 🧪 **[Testing Guide](./TESTING_GUIDE.md)** - Testing procedures
- 📚 **[Lessons Learned](./LESSONS_LEARNED.md)** - Critical Swift patterns discovered

---

## Project Overview

**Agent Deck** - Stream Deck for AI agents. Monitor Claude Code, Cursor, and other agentic coding tools from your phone. Switch windows with one tap, run custom macros.

**Repository:** `/Users/tonyofthehills/dev/apps/app-009-agent-deck/`

**Platform Strategy:** Hybrid approach
- 🖥️ **Mac**: Native Swift/SwiftUI dock app (standard window, lives in Dock)
- 📱 **Mobile**: React Native + Expo (iOS/Android with single codebase)
- 🌐 **Web (Optional)**: PWA as backup web interface

> **Note (Nov 2025):** Changed from menubar app to dock app due to menubar icon visibility issues on macOS. Can add menubar functionality back later.

**Timeline:** 2.5-week MVP (Phase 0 + Phases 1-2) → validate → iterate

---

## Core Principles (Constitution)

### 1. Speed to Market
- **2.5-week MVP over perfection** (0.5 weeks setup + 2 weeks development)
- Ship Phase 0-2 in 2.5 weeks, no scope creep
- Iterate based on user feedback
- "Done is better than perfect" for MVP

### 2. Mac-First Architecture
- **Native Swift dock app is the core product**
- Professional macOS integration (standard window, AppleScript, NSWorkspace)
- No Electron, no web wrappers for Mac app
- Single .app bundle (no Node.js dependency for users)

### 3. Mobile-Native Experience
- **React Native for mobile in MVP** (not PWA)
- Native iOS/Android performance and UX
- Shared TypeScript codebase (iOS + Android from single code)
- Expo for rapid development and testing
- PWA as optional backup/web interface

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

- **Utilize MCP Servers strategically** (see [MCP Integration Guide](./MCP_INTEGRATION.md))
- Spend extra tokens thinking harder for significant output improvements
- Ask for clarification instead of assuming intent (especially UI/UX)
- Suggest better implementations

## NEVER

- Be lazy by eliminating functionality to force completion
- Make a workaround for a persistent issue that will need to be solved later in development

## ALWAYS

- **📋 Check documentation at the start of every session** - Understand current sprint, current task, and dependencies
- **✅ Update task checkboxes when completing work** - Mark [ ] as [x] and update progress tracking
- **📊 Report progress** at end of session
- Use subagents for implementation as much as possible in accordance with best practices for using claude code subagents
- Check spec docs to ensure alignment
- Add lessons learned to LESSONS_LEARNED.md after fixing unexpected issues

---

## MCP Server Integration

**This project uses MCP servers to enhance development capabilities.**

⚠️ **CRITICAL**: Always use subagents (Task tool with `subagent_type=Explore` or `general-purpose`) for MCP research/exploration tasks!

### Available Servers

- **Exa Search** - Web research, current information, troubleshooting
- **Ref** - Agentic documentation search, exploratory learning
- **Context7** - Comprehensive library documentation retrieval
- **Pieces** - Historical and contextual memory from user's environment
- **Semgrep** - Security vulnerability scanning and code quality analysis
- **XcodeBuildMCP** - Xcode project building, testing, simulator management, and UI automation
- **iOS Simulator MCP** - iOS simulator automation (tap, swipe, type, screenshots, video recording)

### Quick Reference

| Scenario | Use This |
|----------|----------|
| "How do I implement X with Y library?" | **Ref** |
| "What are the latest best practices?" | **Exa Search** |
| "Get comprehensive docs for Library X" | **Context7** |
| "What was I working on yesterday?" | **Pieces** |
| "Scan AI-generated code for security issues" | **Semgrep** |
| "Build and run the macOS app" | **XcodeBuildMCP** |
| "Run tests on simulator" | **XcodeBuildMCP** |
| "Take screenshot or automate UI" | **XcodeBuildMCP** |
| "Test mobile UI on iOS simulator" | **iOS Simulator MCP** |
| "Record video of iOS app" | **iOS Simulator MCP** |

**📖 For detailed usage, see [MCP_INTEGRATION.md](./MCP_INTEGRATION.md)**

---

### iOS Simulator (Dedicated)

This project has a dedicated iOS simulator to prevent conflicts with other Expo apps:

| Setting | Value |
|---------|-------|
| **Simulator Name** | `iPhone 17 - AgentDeck` |
| **UDID** | `{{CREATE_ON_FIRST_USE}}` |
| **Metro Port** | `8084` |
| **Runtime** | iOS 26.1 |

```bash
# Run on dedicated simulator (from packages/mobile/)
pnpm start --port 8084  # Then press 'i', select "iPhone 17 - AgentDeck"

# Or run directly
npx expo run:ios --port 8084 --device "iPhone 17 - AgentDeck"
```

**Create simulator if not exists:**
```bash
xcrun simctl create "iPhone 17 - AgentDeck" \
    com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro \
    com.apple.CoreSimulator.SimRuntime.iOS-26-1
```

**See `/apps/CLAUDE.md` for complete multi-app testing guidelines.**

### iOS Simulator MCP

For React Native mobile iOS testing, use iOS Simulator MCP for UI automation.

**CRITICAL: Always pass UDID parameter to MCP calls:**
```javascript
// WRONG - unreliable with multiple simulators
mcp__ios-simulator__ui_tap({ x: 100, y: 200 })

// CORRECT - explicit UDID targeting
mcp__ios-simulator__ui_tap({
  x: 100,
  y: 200,
  udid: "YOUR_AGENTDECK_SIMULATOR_UDID"
})
```

**Tools available:**
| Tool | Description |
|------|-------------|
| `ui_view` | Screenshot simulator directly to Claude |
| `ui_tap` | Tap at coordinates |
| `ui_swipe` | Swipe gestures |
| `ui_type` | Input text |
| `ui_describe_all` | Get full accessibility tree |
| `screenshot` | Save screenshot to file |
| `record_video` / `stop_recording` | Video capture |
| `launch_app` / `install_app` | App management |

**Usage example:**
```
# Take a screenshot (always include udid)
Use ui_view with udid parameter

# Tap on agent card (always include udid)
Use ui_tap with x: 200, y: 300 and udid parameter

# Get accessibility info (always include udid)
Use ui_describe_all with udid parameter
```

**Note:** Android (Pixel 7a physical device) is the priority for mobile testing. Use iOS Simulator MCP when iOS-specific testing is needed.

---

## Security Scanning

**CRITICAL: Always scan AI-generated code before committing!**

Agent Deck is a dual-platform project (Swift menubar + React Native mobile) requiring security vigilance across both stacks.

### When to Scan

**ALWAYS scan before committing when you:**
1. Generate or modify authentication code
2. Implement WebSocket communication
3. Add file operations or path handling
4. Implement AsyncStorage or SecureStore
5. Handle user input
6. Add dependencies (`pnpm install`)

### Quick Scan Commands

```bash
# Swift menubar app
semgrep_scan: apps/macos/*/Sources/**/*.swift

# React Native mobile
semgrep_scan: apps/mobile/src/**/*.{ts,tsx}

# Supply chain (after pnpm install)
cd apps/mobile && semgrep_scan_supply_chain
```

**🔒 For comprehensive security guidance, see [SECURITY.md](./SECURITY.md)**

---

## XcodeBuildMCP Integration 🔨

**XcodeBuildMCP provides Xcode automation without leaving Claude Code.**

### Project Paths (Agent Deck)

```
# macOS menubar app (PRIMARY)
Project: /Users/tonyofthehills/dev/apps/app-009-agent-deck/apps/macos/Agent-Deck/AgentDeck.xcodeproj
Scheme: AgentDeck
Bundle ID: com.TheHillPack.AgentDeck

# React Native iOS (if needed)
Workspace: /Users/tonyofthehills/dev/apps/app-009-agent-deck/apps/mobile/ios/mobile.xcworkspace
```

### When to Use XcodeBuildMCP

**USE for these scenarios:**

| Task | XcodeBuildMCP Tool |
|------|-------------------|
| Build macOS app | `build_macos` |
| Build + run macOS app | `build_run_macos` |
| Clean build artifacts | `clean` |
| List available schemes | `list_schemes` |
| Show build settings | `show_build_settings` |
| Run tests | `test_macos` |
| Get app bundle path | `get_mac_app_path` |
| Launch built app | `launch_mac_app` |
| Stop running app | `stop_mac_app` |

**For iOS/React Native (if needed):**

| Task | XcodeBuildMCP Tool |
|------|-------------------|
| List simulators | `list_sims` |
| Boot simulator | `boot_sim` |
| Build for simulator | `build_sim` |
| Build + run on simulator | `build_run_sim` |
| Install app on simulator | `install_app_sim` |
| Take screenshot | `screenshot` |
| Describe UI hierarchy | `describe_ui` |
| UI automation (tap, swipe) | `tap`, `swipe`, `type_text` |

### Quick Commands for Agent Deck

**Build macOS menubar app:**
```
mcp__XcodeBuildMCP__build_macos({
  projectPath: "/Users/tonyofthehills/dev/apps/app-009-agent-deck/apps/macos/Agent-Deck/AgentDeck.xcodeproj",
  scheme: "AgentDeck"
})
```

**Build and run:**
```
mcp__XcodeBuildMCP__build_run_macos({
  projectPath: "/Users/tonyofthehills/dev/apps/app-009-agent-deck/apps/macos/Agent-Deck/AgentDeck.xcodeproj",
  scheme: "AgentDeck"
})
```

**Clean build:**
```
mcp__XcodeBuildMCP__clean({
  projectPath: "/Users/tonyofthehills/dev/apps/app-009-agent-deck/apps/macos/Agent-Deck/AgentDeck.xcodeproj",
  scheme: "AgentDeck",
  platform: "macOS"
})
```

**Run tests:**
```
mcp__XcodeBuildMCP__test_macos({
  projectPath: "/Users/tonyofthehills/dev/apps/app-009-agent-deck/apps/macos/Agent-Deck/AgentDeck.xcodeproj",
  scheme: "AgentDeck"
})
```

**Discover projects (useful after restructuring):**
```
mcp__XcodeBuildMCP__discover_projs({
  workspaceRoot: "/Users/tonyofthehills/dev/apps/app-009-agent-deck"
})
```

### Troubleshooting with XcodeBuildMCP

**Check environment:**
```
mcp__XcodeBuildMCP__doctor()
```

**Common issues:**
1. **Build fails** → Use `clean` first, then rebuild
2. **Wrong scheme** → Use `list_schemes` to see available schemes
3. **Stale DerivedData** → Delete `~/Library/Developer/Xcode/DerivedData/AgentDeck-*`
4. **Accessibility issues** → Rebuild app, then re-grant permissions in System Settings

### When NOT to Use XcodeBuildMCP

❌ **Don't use for:**
- Simple file edits (use Edit tool instead)
- Reading Swift code (use Read tool)
- Git operations (use Bash)
- Debugging runtime issues (use Xcode directly with breakpoints)

✅ **Use Xcode directly for:**
- Setting breakpoints
- Profiling with Instruments
- Managing certificates and provisioning
- Complex project configuration changes

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

**Note**: SpecKit memory files (spec.md, plan.md, tasks.md) have been copied to `.specify/memory/` from `specs/001-mvp/`. ✅

---

## Tech Stack

### macOS Application (Phase 1-2)
**Language:** Swift 5.7+ (Swift 6 compatible)
**UI:** SwiftUI (native macOS look and feel)
**IDE:** Xcode 26.1.1 (Build 17B100)

**Frameworks:**
- `Combine` - Reactive state management
- `Network.framework` - WebSocket server
- `NSWorkspace` - Process monitoring
- `NSAppleScript` - Window management
- `UserDefaults` - Configuration storage

**Target:** macOS 12+ (Monterey or later)

**Xcode 26 Notes:**
- Scheme renaming: Use Product → Scheme → Edit Scheme, or single-click + pause + single-click in Manage Schemes
- Project/target renaming through Project Navigator works automatically
- Bundle identifier updated in Signing & Capabilities tab

### Mobile Application (Phase 0-2)
**Framework:** React Native 0.73+ (Expo SDK 50+)
**Language:** TypeScript 5.0+
**Runtime:** Node.js 18+

**Key Dependencies:**
- `expo` (~50.0.0) - Expo SDK
- `react-native` (0.73.x) - React Native framework
- `@react-navigation/native` - Navigation
- `expo-keep-awake` - Prevent screen sleep during monitoring
- `expo-barcode-scanner` - QR code scanning for pairing (⚠️ needs installation)
- `@react-native-async-storage/async-storage` - Local persistence

**Target Platforms:**
- iOS 13.0+
- Android API 21+ (Android 5.0+)

### Monorepo Management (Phase 0)
**Tool:** pnpm (v8+) with workspaces

**Package Manager Note:** This project uses **pnpm** (monorepo with workspaces). Not migrated to Bun due to established workspace configuration with explicit `packageManager` field. See workspace CLAUDE.md for package manager guidance.

**Why pnpm:**
- Faster than npm/yarn
- Efficient disk space usage (hard links)
- Strict dependency resolution
- Native workspace support

**📖 For detailed patterns, see:**
- **[REACT_NATIVE_GUIDE.md](./REACT_NATIVE_GUIDE.md)** - Mobile development
- **[SWIFT_GUIDE.md](./SWIFT_GUIDE.md)** - macOS development

---

## File Structure (Monorepo)

```
agent-deck/                              # Root monorepo
├── apps/
│   ├── macos/                           # Swift menubar app
│   │   └── Agent-Deck/
│   │       ├── Agent-Deck.xcodeproj/
│   │       ├── Agent-Deck/
│   │       │   ├── Models/              (6 Swift files)
│   │       │   ├── Services/            (8 Swift files, 2701 total lines)
│   │       │   ├── Views/               (3 SwiftUI views)
│   │       │   └── Utilities/           (2 utility files)
│   │       └── Resources/
│   │           └── WebRoot/             ⚠️ PWA kept as backup
│   │
│   └── mobile/                          # React Native app
│       ├── app.json                     # Expo configuration
│       ├── package.json                 # Mobile dependencies
│       ├── App.tsx                      # Root component
│       └── src/
│           ├── screens/                 (AgentListScreen, QRScannerScreen, SettingsScreen)
│           ├── components/              (AgentCard, ConnectionStatus, etc.)
│           ├── hooks/                   (useWebSocket, useKeepAwake)
│           ├── services/                (websocket)
│           ├── theme/                   (colors, spacing)
│           └── types/                   (imports from @agent-deck/shared-types)
│
├── packages/                            # Shared JavaScript/TypeScript
│   └── shared-types/
│       ├── package.json
│       └── src/
│           ├── agent.ts                 # AgentInstance, AgentStatus types
│           ├── websocket.ts             # WebSocketMessage types
│           └── config.ts                # Configuration types
│
├── .specify/                            # SpecKit artifacts
│   └── memory/                          (constitution.md, spec.md, plan.md, tasks.md)
├── specs/001-mvp/                       # MVP specifications
├── pnpm-workspace.yaml                  # Workspace definition
├── package.json                         # Root package (workspace scripts)
├── tsconfig.json                        # Shared TypeScript config
├── CLAUDE.md                            # This file
└── [60+ documentation files]            # Comprehensive documentation
```

---

## Monorepo Development

### Workspace Commands

**Installing dependencies:**
```bash
# Install all dependencies (root + all workspaces)
pnpm install

# Add dependency to mobile app
pnpm --filter mobile add <package-name>

# Add dev dependency to root
pnpm add -D -w <package-name>
```

**Running scripts:**
```bash
# Start Expo dev server (mobile)
pnpm mobile

# Run on iOS simulator
pnpm mobile:ios

# Run on Android emulator
pnpm mobile:android

# Type check all packages
pnpm typecheck
```

### Mobile Development (Android Priority)

**ALWAYS use the physical Android device (Pixel 7a) for mobile testing.** Only fall back to Android emulator if the device is unavailable.

**Physical Device (Preferred):**
- **Device:** Pixel 7a (connected via USB)
- **ADB Serial:** `35051JEHN13181`
- **Expo Go** must be installed on the device

```bash
# Run on physical Android device (PREFERRED)
cd apps/mobile && npx expo start --android --clear

# Check device is connected first
adb devices  # Should show 35051JEHN13181

# If device not detected, try:
adb kill-server && adb start-server
```

**Android Emulator (Fallback - Only if physical device unavailable):**
- **AVD Name:** `Medium_Phone_API_36.1`
- **SDK Location:** `~/Library/Android/sdk`

```bash
# Set up environment
export ANDROID_HOME=~/Library/Android/sdk
export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH

# Start emulator
$ANDROID_HOME/emulator/emulator -avd "Medium_Phone_API_36.1" &

# Then start Expo
cd apps/mobile && npx expo start --android --clear
```

**Priority Order:**
1. Physical Android device (Pixel 7a) - ALWAYS try first
2. Android emulator - Only if device unavailable
3. iOS simulator - NOT recommended for this project

### Shared Types Usage

**In mobile app:**
```typescript
import type { AgentInstance, AgentStatus, WebSocketMessage } from '@agent-deck/shared-types';
```

**In shared-types package:**
```typescript
export interface AgentInstance {
  id: string;
  pid: number;
  name: string;
  agentType: 'claude-code' | 'cursor' | 'windsurf';
  cwd: string;
  status: AgentStatus;
  currentTask?: string;
  branch?: string;
  model?: string;
}
```

---

## Development Patterns

### React Native Patterns

**Key concepts:**
- Expo project structure with app.json
- Functional components with hooks (useState, useEffect, useCallback)
- Custom hooks for reusable logic (useWebSocket, useKeepAwake)
- Pressable for touch interactions with press states
- FlatList for performant lists
- Navigation with @react-navigation/native
- Dark mode theming with theme/colors.ts

**📖 For detailed patterns and code examples, see [REACT_NATIVE_GUIDE.md](./REACT_NATIVE_GUIDE.md)**

---

### Swift/SwiftUI Patterns

**Key concepts:**
- Menubar app structure with NSApplicationDelegate
- State management with Combine (@Published, ObservableObject)
- Process monitoring with NSWorkspace
- AppleScript for window management
- WebSocket server with Network.framework
- QR code generation with CoreImage
- Structured logging with os.log

**📖 For detailed patterns and code examples, see [SWIFT_GUIDE.md](./SWIFT_GUIDE.md)**

---

## Development Constraints

### Phase 0 Focus (Monorepo Setup - Complete ✅)

- ✅ Create monorepo structure (apps/, packages/)
- ✅ Configure pnpm workspaces
- ✅ Set up shared-types package
- ✅ Initialize React Native project with Expo
- ✅ Configure dark mode theme

### Phase 1-2 Focus (MVP - In Progress 🟡)

**IN SCOPE:**
- ✅ Monitoring only (no interaction with agents yet)
- ✅ Claude Code process detection (Swift)
- ✅ Basic output parsing (current task)
- ✅ Window switching (AppleScript)
- ✅ WebSocket server (Swift, localhost:3000)
- 🟡 React Native mobile interface (40% complete)
- 🟡 QR code pairing (needs QRScannerScreen implementation)
- ✅ Custom actions (basic: AppleScript, Bash)
- 🟡 Real-time updates (WebSocket client needs testing)

**OUT OF SCOPE (Phase 3+):**
- ❌ Mobile interaction (approval prompts) - Phase 5
- ❌ Full output parsing (todo list, status line) - Phase 3
- ❌ Multiple agent types (Cursor, Windsurf) - Phase 3
- ❌ Advanced custom actions - Phase 5
- ❌ Code signing/notarization - Phase 6

### Performance Targets

**macOS App:**
- CPU: <2% idle, <5% active
- Memory: <100MB RAM
- Latency: <500ms status update, <1s window switch
- Startup: <2s to menubar ready

**React Native App:**
- Memory: <150MB RAM on device
- FPS: 60fps for animations
- WebSocket reconnect: <2s
- Cold start: <3s to first screen

---

## Testing Strategy

### Phase 0-2 (MVP)
**Manual testing only** - No automated tests initially

**Test checklist:**

**macOS App:**
- [ ] Mac app launches and appears in menubar
- [ ] Detects running Claude Code processes
- [ ] WebSocket server accepts connections
- [ ] Window switching works (AppleScript)
- [ ] Status updates appear in real-time (<500ms)

**React Native Mobile:**
- [ ] App launches on iOS simulator
- [ ] App launches on Android emulator
- [ ] QR scanner opens camera
- [ ] QR scanner connects to Mac app
- [ ] Agent list displays connected agents
- [ ] Tapping agent card focuses window
- [ ] WebSocket reconnects after disconnect
- [ ] Screen stays awake during monitoring

**📖 For detailed testing procedures, see [TESTING_GUIDE.md](./TESTING_GUIDE.md)**

---

## Common Pitfalls & Solutions

### 1. ❌ Don't Use npm or yarn
**Use:** pnpm for all package operations

### 2. ❌ Don't Import Relative Paths from Shared
**Use:** Workspace protocol in package.json:
```json
{
  "dependencies": {
    "@agent-deck/shared-types": "workspace:*"
  }
}
```

### 3. ❌ Don't Store Sensitive Data in AsyncStorage
**Use:** expo-secure-store for tokens/secrets

### 4. ❌ Don't Bind WebSocket to 127.0.0.1
**Use:** 0.0.0.0:3000 (all interfaces on local network)

### 5. ❌ Don't Forget Accessibility Permissions
**Mac app requires Accessibility access for window switching**

**📖 For comprehensive pitfalls and Swift-specific patterns, see [LESSONS_LEARNED.md](./LESSONS_LEARNED.md)**

---

## Lessons Learned 📚

**IMPORTANT:** See `LESSONS_LEARNED.md` for comprehensive details. Critical patterns:

### 🔴 FSEvents C Pointer Handling
**Never try to cast eventPaths to CFArray or NSArray.** Use `assumingMemoryBound(to: UnsafePointer<CChar>.self)`.

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

### 🔴 Path Matching
**Don't try to convert directory names to paths.** Read `cwd` from transcript JSON.

**📖 For full details and Pieces memories, see [LESSONS_LEARNED.md](./LESSONS_LEARNED.md)**

---

## Quick Reference Commands

### First-Time Setup

```bash
# Install pnpm
npm install -g pnpm

# Install all dependencies
pnpm install

# Open Mac app in Xcode
cd apps/macos && open Agent-Deck.xcodeproj
```

### Running the System

```bash
# Start Mac app (in Xcode: Command+R)

# Start mobile app
pnpm mobile              # Expo dev server
pnpm mobile:ios          # iOS simulator
pnpm mobile:android      # Android emulator
```

### SpecKit Workflow

```bash
/speckit.constitution    # Define principles
/speckit.specify         # Create spec
/speckit.plan            # Generate plan
/speckit.tasks           # Break into tasks
/speckit.implement       # Start coding
```

### Testing & Debugging

```bash
# Check WebSocket server
lsof -i :3000

# View Mac app logs
log stream --predicate 'subsystem == "com.agentdeck.app"'

# Clear Expo cache
pnpm mobile -- --clear
```

**📖 For complete setup guide, see [QUICK_START.md](./QUICK_START.md)**

---

## Current Implementation Status

### ✅ Production-Ready
- Swift macOS menubar app (2,701 lines, fully functional)
- Real-time monitoring via FSEvents
- WebSocket server broadcasting updates
- Window switching via AppleScript
- Rich data parsing (model, branch, subagents, todos, tokens)
- HTTP server with QR code generation
- Monorepo infrastructure (pnpm workspaces)
- Shared TypeScript types package

### ✅ Complete (100%)
- React Native mobile app (~2,160 lines of production code)
  - AgentListScreen (262 lines) - FlatList, status indicators, pull-to-refresh
  - QRScannerScreen (406 lines) - expo-camera, manual URL entry, AsyncStorage
  - SettingsScreen (270 lines) - disconnect, keep awake toggle, about
  - ActionsScreen (158 lines) - 4-column grid for custom action buttons
  - useWebSocket hook (160 lines) - reconnection, message handling
  - AgentCard component (460 lines) - rich data display (model, branch, todos, lastStatement)
  - ActionButton component (166 lines) - square buttons with loading/success/error states
  - Navigation (107 lines) - full flow with AsyncStorage persistence
  - Theme (dark mode styling complete)

### ⚠️ Remaining (Testing & Deployment)
- End-to-end testing (Mac ↔ mobile WebSocket communication) - TEST_CHECKLIST.md created
- Expo builds for iOS/Android (EAS Build setup required)
- Test on physical devices (T145-T148)

**Status**: Development 92% complete (122/132 tasks). Ready for manual testing and Expo builds.

---

## Version

**CLAUDE.md Version:** 3.2
**Last Updated:** 2025-12-10
**Agent Deck Phase:** Phase 0-10 (92% complete - 122/132 tasks done)
**SpecKit Template:** spec-kit-template-claude-sh-v0.0.79

### Recent Changes
- 2025-12-10: ✅ **MVP Development Complete** - All code tasks done. ActionsScreen, ActionButton, TEST_CHECKLIST.md, RELEASE_NOTES.md, LICENSE created. 92% overall completion.
- 2025-11-25: 🖥️ **Converted from menubar to dock app** - Standard window instead of menubar icon due to visibility issues. App now lives in Dock.
- 2025-11-25: 🔨 **Added XcodeBuildMCP documentation** - Build, test, run macOS app via MCP. Added Quick Links, usage tables, and troubleshooting guide.
- 2025-01-24: 📄 **Major restructure** - Extracted content into focused guides (MCP, Security, React Native, Swift, Quick Start). Reduced from 2,345 to ~450 lines (81% reduction). Added Quick Links section.
- 2025-01-24: ✅ Fixed SpecKit integration (copied spec.md, plan.md, tasks.md to .specify/memory/)
- 2025-01-08: ✅ Updated for monorepo + React Native architecture (Constitution v2.0)
- 2025-01-05: ✅ Real-time monitoring complete (FSEvents + Combine + WebSocket)

---

## Active Technologies
- Swift 5.7+ (Swift 6 compatible targeting macOS 12+) - macOS dock app
- React Native 0.73+ (Expo SDK 50+) - Mobile app (iOS/Android)
- TypeScript 5.0+ - Mobile app and shared types
- pnpm 8+ - Monorepo package management
- FSEvents (macOS file system monitoring)
- Combine (reactive state management)
- WebSocket (real-time communication)

---

**Remember:** Speed to market. 2.5-week MVP (0.5 weeks setup + 2 weeks dev). Ship, validate, iterate. 🚀

---

## External AI CLI Tools

Use these authenticated CLIs for research and code review (preferred over Perplexity MCP):

### Gemini CLI - Deep Research
```bash
# Complex research, comparisons, technology decisions
gemini -m gemini-3-pro-preview "Your research question here"
echo "Question" | gemini
```
**Best for:** Technology comparisons, architecture decisions, best practices research, multi-factor analysis.

### Codex CLI - Expert Code Review
```bash
# From project directory:
codex exec "Review this codebase for [specific concern]"
codex exec --skip-git-repo-check "Quick question"
```
**Best for:** Code review, bug hunting, security analysis, architecture assessment, refactoring suggestions.

**Note:** Both CLIs use the user's authenticated accounts (Gemini Pro, ChatGPT Plus).

---

**For detailed information, see the Quick Links at the top of this document.**
