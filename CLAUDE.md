# CLAUDE.md - Agent Deck

**Project-specific guidance for Claude Code when working on Agent Deck**

---

## Project Overview

**Agent Deck** - Stream Deck for AI agents. Monitor Claude Code, Cursor, and other agentic coding tools from your phone. Switch windows with one tap, run custom macros.

**Repository:** `/Users/tonyofthehills/dev/apps/app-009-agent-deck/`

**Platform Strategy:** Hybrid approach
- 🖥️ **Mac**: Native Swift/SwiftUI menubar app
- 📱 **Mobile**: React Native + Expo (iOS/Android with single codebase)
- 🌐 **Web (Optional)**: PWA as backup web interface

**Timeline:** 2.5-week MVP (Phase 0 + Phases 1-2) → validate → iterate

---

## Core Principles (Constitution)

### 1. Speed to Market
- **2.5-week MVP over perfection** (0.5 weeks setup + 2 weeks development)
- Ship Phase 0-2 in 2.5 weeks, no scope creep
- Iterate based on user feedback
- "Done is better than perfect" for MVP

### 2. Mac-First Architecture
- **Native Swift menubar app is the core product**
- Professional macOS integration (menubar, AppleScript, NSWorkspace)
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

- **Utilize MCP Servers strategically** (see MCP Server Integration section below)
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
"How to implement WebSocket reconnection in React Native"
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
"How do I implement navigation with React Navigation v6?"
"Show me best practices for SwiftUI navigation in macOS apps"
"What's the proper way to use expo-keep-awake?"
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
"Get comprehensive React Native documentation for hooks (use context7)"
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
"What was I working on in React Native yesterday?" (use pieces)
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
- Scanning AI-generated Swift and TypeScript/JavaScript code before committing
- Finding macOS security issues (Keychain, file permissions, URL schemes)
- Checking React Native security (XSS, insecure storage, API exposure)
- Validating authentication and session handling
- OWASP Top 10 vulnerability detection

**Tools:**
- `semgrep_scan` - Scan files for security vulnerabilities
- `semgrep_scan_with_custom_rule` - Run custom security rules
- `semgrep_scan_supply_chain` - Check dependency vulnerabilities
- `get_supported_languages` - List supported languages (Swift, TypeScript, JavaScript, etc.)

**CRITICAL - Always scan before committing:**
- AI-generated code (Swift menubar app OR React Native mobile)
- Authentication/authorization changes
- WebSocket communication code
- Session management
- File operations
- API endpoint implementations
- AsyncStorage usage (React Native)

**Example usage:**
```
"Scan the Swift authentication code for security issues"
"Check the React Native TypeScript for insecure storage"
"Run supply chain scan after pnpm install"
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
- Mention the specific technology stack (React Native, Swift, etc.)
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

Agent Deck is a dual-platform project (Swift menubar + React Native mobile) requiring security vigilance across both stacks.

### When to Scan

**ALWAYS scan before committing when you:**
1. Generate or modify authentication code (session tokens, API keys)
2. Implement WebSocket communication or real-time updates
3. Add file operations or path handling (Swift menubar app)
4. Work with clipboard or pasteboard monitoring
5. Implement AsyncStorage or SecureStore (React Native)
6. Handle user input in either platform
7. Add pnpm dependencies (`pnpm install` for mobile)
8. Implement cross-origin communication (Swift ↔ React Native)

### How to Scan

**Swift menubar app:**
```
Scan these files with semgrep_scan:
[
  {"path": "/absolute/path/to/apps/macos/Agent-Deck/Sources/Auth/*.swift"},
  {"path": "/absolute/path/to/apps/macos/Agent-Deck/Sources/WebSocket/*.swift"}
]
```

**React Native mobile app:**
```
Scan these files with semgrep_scan:
[
  {"path": "/absolute/path/to/apps/mobile/src/services/websocket.ts"},
  {"path": "/absolute/path/to/apps/mobile/src/screens/QRScannerScreen.tsx"}
]
```

**Supply chain (after pnpm install):**
```
cd apps/mobile && semgrep_scan_supply_chain
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

**React Native Mobile (ERROR severity):**
- XSS vulnerabilities in WebView components
- Insecure AsyncStorage for tokens/secrets
- Unvalidated WebSocket messages
- Deep link injection attacks
- Expo SDK misconfigurations
- Insecure network requests
- Unencrypted sensitive data storage

**Cross-Platform (ERROR severity):**
- Session token exposure in transit
- Authentication bypass vulnerabilities
- Insecure communication channels
- API credential leakage

### Secure AI Coding Workflow

```
1. Request: "Add WebSocket authentication"
2. AI generates Swift + React Native code
3. ⚠️ STOP - Scan both platforms:
   - semgrep_scan: Swift files
   - semgrep_scan: TypeScript/TSX files
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
    languages: [swift, typescript]
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
      ws.onmessage = (event) => {
        ...
        eval(event.data)
      }
    languages: [typescript, javascript]
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

**React Native Mobile:**
- [ ] Use SecureStore for sensitive data (not AsyncStorage)
- [ ] Validate all WebSocket messages before processing
- [ ] Sanitize all user input
- [ ] Implement deep link validation
- [ ] Use HTTPS for all network requests
- [ ] Implement certificate pinning for production
- [ ] Validate QR code scanner input

**Cross-Platform:**
- [ ] Encrypt sensitive data in transit
- [ ] Implement proper session management
- [ ] Validate authentication on both platforms
- [ ] Test offline/online state transitions
- [ ] Audit all communication channels

### Quick Reference

| Scenario | Semgrep Command |
|----------|-----------------|
| Scan Swift auth code | `semgrep_scan: apps/macos/*/Sources/Auth/*.swift` |
| Scan React Native code | `semgrep_scan: apps/mobile/src/**/*.{ts,tsx}` |
| Check WebSocket code | `semgrep_scan: */services/*WebSocket*` |
| Scan shared types | `semgrep_scan: packages/shared-types/src/**/*.ts` |
| Supply chain (mobile) | `cd apps/mobile && semgrep_scan_supply_chain` |
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

### Mobile Application (Phase 0-2)
**Framework:** React Native 0.73+ (Expo SDK 50+)
**Language:** TypeScript 5.0+
**Runtime:** Node.js 18.0+

**Why React Native:**
- Single codebase for iOS + Android
- Native performance and UX
- Rapid iteration with Expo
- Hot reload for fast development
- Large ecosystem of libraries

**Key Dependencies:**
- `expo` (~50.0.0) - Expo SDK
- `react-native` (0.73.x) - React Native framework
- `@react-navigation/native` - Navigation
- `@react-navigation/native-stack` - Stack navigator
- `expo-keep-awake` - Prevent screen sleep during monitoring
- `expo-barcode-scanner` - QR code scanning for pairing
- `@react-native-async-storage/async-storage` - Local persistence
- `react-native-gesture-handler` - Touch gestures
- `react-native-reanimated` - Smooth animations

**Project Structure:**
- `app.json` - Expo configuration
- `App.tsx` - Root component
- `src/` - Application source code
- `assets/` - Images, fonts, icons

**Target Platforms:**
- iOS 13.0+
- Android API 21+ (Android 5.0+)

### Monorepo Management (Phase 0)
**Tool:** pnpm (v8+) with workspaces
**Why pnpm:**
- Faster than npm/yarn
- Efficient disk space usage (hard links)
- Strict dependency resolution
- Native workspace support

**Structure:**
```
apps/
  macos/          # Swift menubar app
  mobile/         # React Native + Expo
packages/
  shared-types/   # Shared TypeScript types
```

**Workspace Configuration:**
- `pnpm-workspace.yaml` - Workspace definition
- `package.json` (root) - Workspace scripts
- `tsconfig.json` (root) - Shared TypeScript config

**Shared Code:**
- `@agent-deck/shared-types` - TypeScript types shared between mobile and future web clients
- Includes: AgentInstance, WebSocketMessage, Configuration types
- Prevents type drift between platforms

### Backend (Phase 1-2)
**Embedded in Mac app** - No separate server process

**Options:**
1. **Swift Network.framework** (lightweight)
   - Built into Swift
   - No external dependencies
   - Good for simple WebSocket

2. **Vapor** (full-featured)
   - HTTP + WebSocket in one
   - Easier to serve static files
   - More overhead

**Choose:** Start with Network.framework, migrate to Vapor if needed

---

## File Structure (Monorepo)

```
agent-deck/                              # Root monorepo
├── apps/
│   ├── macos/                           # Swift menubar app
│   │   ├── Agent-Deck.xcodeproj/
│   │   ├── Agent-Deck/
│   │   │   ├── Agent_DeckApp.swift      # Main app entry
│   │   │   ├── AppDelegate.swift        # Menubar app controller
│   │   │   ├── Models/
│   │   │   │   ├── AgentInstance.swift  # Agent data model
│   │   │   │   ├── CustomAction.swift   # Action data model
│   │   │   │   └── Configuration.swift  # App config
│   │   │   ├── Services/
│   │   │   │   ├── ProcessMonitor.swift    # Process monitoring
│   │   │   │   ├── TranscriptParser.swift  # Output parsing
│   │   │   │   ├── WebSocketServer.swift   # Real-time communication
│   │   │   │   ├── WindowManager.swift     # Window focus/switching
│   │   │   │   └── ConfigManager.swift     # YAML config management
│   │   │   ├── Views/
│   │   │   │   ├── MenuBarView.swift       # Menubar dropdown UI
│   │   │   │   ├── SettingsView.swift      # Settings window
│   │   │   │   └── QRCodeView.swift        # QR code for mobile pairing
│   │   │   └── Utilities/
│   │   │       ├── AppleScriptRunner.swift # AppleScript execution
│   │   │       └── Logger.swift            # Logging
│   │   └── Resources/
│   │       ├── Assets.xcassets/         # App icons
│   │       ├── default-config.yaml      # Default configuration
│   │       ├── default-actions.yaml     # Default custom actions
│   │       └── WebRoot/                 # ⭐ Optional PWA (backup web interface)
│   │           ├── index.html
│   │           ├── app.js
│   │           ├── styles.css
│   │           └── manifest.json
│   │
│   └── mobile/                          # React Native + Expo
│       ├── app.json                     # Expo configuration
│       ├── package.json                 # Mobile dependencies
│       ├── tsconfig.json                # TypeScript config
│       ├── App.tsx                      # Root component
│       ├── src/
│       │   ├── screens/
│       │   │   ├── AgentListScreen.tsx      # Main agent list view
│       │   │   ├── QRScannerScreen.tsx      # QR scanner for pairing
│       │   │   └── SettingsScreen.tsx       # App settings
│       │   ├── components/
│       │   │   ├── AgentCard.tsx            # Agent status card
│       │   │   ├── ActionButton.tsx         # Custom action button
│       │   │   └── ConnectionStatus.tsx     # WebSocket status indicator
│       │   ├── hooks/
│       │   │   ├── useWebSocket.ts          # WebSocket connection hook
│       │   │   └── useKeepAwake.ts          # Screen awake hook
│       │   ├── services/
│       │   │   └── websocket.ts             # WebSocket client service
│       │   ├── types/                       # Local types (imports from shared)
│       │   │   └── index.ts
│       │   ├── theme/
│       │   │   └── colors.ts                # Dark mode colors
│       │   └── utils/
│       │       └── storage.ts               # AsyncStorage utilities
│       └── assets/
│           ├── icon.png
│           └── splash.png
│
├── packages/                            # Shared JavaScript/TypeScript
│   └── shared-types/
│       ├── package.json
│       ├── tsconfig.json
│       └── src/
│           ├── index.ts                 # Export all types
│           ├── agent.ts                 # AgentInstance, AgentStatus types
│           ├── websocket.ts             # WebSocketMessage types
│           └── config.ts                # Configuration types
│
├── pnpm-workspace.yaml                  # Workspace definition
├── package.json                         # Root package (workspace scripts)
├── tsconfig.json                        # Shared TypeScript config
├── .gitignore
├── .specify/                            # SpecKit artifacts
├── .claude/                             # SpecKit commands
├── README.md
└── CLAUDE.md                            # This file
```

---

## Monorepo Development

### Package Manager: pnpm

**Why pnpm:**
- **Fast**: 2x faster than npm, faster than yarn
- **Efficient**: Hard links save disk space
- **Strict**: Prevents phantom dependencies
- **Native workspaces**: First-class monorepo support

**Installation:**
```bash
# Install pnpm globally
npm install -g pnpm

# Or use Corepack (Node.js 16.13+)
corepack enable
corepack prepare pnpm@latest --activate
```

### Workspace Commands

**Installing dependencies:**
```bash
# Install all dependencies (root + all workspaces)
pnpm install

# Add dependency to mobile app
pnpm --filter mobile add react-native-reanimated

# Add dependency to shared-types
pnpm --filter @agent-deck/shared-types add -D typescript

# Add dev dependency to root
pnpm add -D -w prettier
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

# Type check mobile only
pnpm --filter mobile typecheck

# Build shared types
pnpm --filter @agent-deck/shared-types build
```

### Shared Types Usage

**In mobile app (`apps/mobile/src/types/index.ts`):**
```typescript
// Import from shared package
import type { AgentInstance, AgentStatus, WebSocketMessage } from '@agent-deck/shared-types';

// Use in components
export interface AgentListProps {
  agents: AgentInstance[];
  onFocus: (agent: AgentInstance) => void;
}
```

**In shared-types package (`packages/shared-types/src/agent.ts`):**
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

export enum AgentStatus {
  idle = 'idle',
  running = 'running',
  error = 'error',
}
```

### Type Checking Across Packages

**Root `tsconfig.json`:**
```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@agent-deck/shared-types": ["./packages/shared-types/src"]
    }
  },
  "references": [
    { "path": "./packages/shared-types" },
    { "path": "./apps/mobile" }
  ]
}
```

**Mobile `tsconfig.json`:**
```json
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "jsx": "react-native"
  },
  "references": [
    { "path": "../../packages/shared-types" }
  ]
}
```

---

## React Native Patterns

### Expo Project Structure

**app.json configuration:**
```json
{
  "expo": {
    "name": "Agent Deck",
    "slug": "agent-deck-mobile",
    "version": "1.0.0",
    "platforms": ["ios", "android"],
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "splash": {
      "image": "./assets/splash.png",
      "backgroundColor": "#1a1a1a"
    },
    "ios": {
      "bundleIdentifier": "com.agentdeck.mobile",
      "supportsTablet": true
    },
    "android": {
      "package": "com.agentdeck.mobile",
      "adaptiveIcon": {
        "foregroundImage": "./assets/icon.png",
        "backgroundColor": "#1a1a1a"
      }
    }
  }
}
```

### Creating Screens and Components

**AgentListScreen.tsx:**
```typescript
import React from 'react';
import { FlatList, StyleSheet, View } from 'react-native';
import { AgentCard } from '../components/AgentCard';
import { ConnectionStatus } from '../components/ConnectionStatus';
import { useWebSocket } from '../hooks/useWebSocket';
import type { AgentInstance } from '@agent-deck/shared-types';

export function AgentListScreen() {
  const { agents, connected, sendFocusCommand } = useWebSocket();

  const handleFocus = (agent: AgentInstance) => {
    sendFocusCommand(agent.id);
  };

  return (
    <View style={styles.container}>
      <ConnectionStatus connected={connected} />
      <FlatList
        data={agents}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <AgentCard agent={item} onPress={() => handleFocus(item)} />
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#1a1a1a',
  },
});
```

**AgentCard.tsx:**
```typescript
import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import type { AgentInstance } from '@agent-deck/shared-types';

interface AgentCardProps {
  agent: AgentInstance;
  onPress: () => void;
}

export function AgentCard({ agent, onPress }: AgentCardProps) {
  const statusColor = {
    idle: '#666',
    running: '#4ade80',
    error: '#f87171',
  }[agent.status];

  return (
    <Pressable
      style={({ pressed }) => [
        styles.card,
        { borderLeftColor: statusColor },
        pressed && styles.pressed,
      ]}
      onPress={onPress}
    >
      <Text style={styles.name}>{agent.name}</Text>
      <Text style={styles.task}>{agent.currentTask || 'Idle'}</Text>
      {agent.branch && <Text style={styles.branch}>Branch: {agent.branch}</Text>}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#2a2a2a',
    borderLeftWidth: 4,
    borderRadius: 8,
    padding: 16,
    marginHorizontal: 16,
    marginVertical: 8,
    minHeight: 44, // Touch target size
  },
  pressed: {
    opacity: 0.8,
    transform: [{ scale: 0.98 }],
  },
  name: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '600',
  },
  task: {
    color: '#aaa',
    fontSize: 14,
    marginTop: 4,
  },
  branch: {
    color: '#888',
    fontSize: 12,
    marginTop: 4,
  },
});
```

### useWebSocket Hook Pattern

**hooks/useWebSocket.ts:**
```typescript
import { useState, useEffect, useCallback, useRef } from 'react';
import type { AgentInstance, WebSocketMessage } from '@agent-deck/shared-types';

export function useWebSocket() {
  const [agents, setAgents] = useState<AgentInstance[]>([]);
  const [connected, setConnected] = useState(false);
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout>();

  const connect = useCallback((url: string) => {
    try {
      const ws = new WebSocket(url);

      ws.onopen = () => {
        console.log('Connected to Agent Deck');
        setConnected(true);
      };

      ws.onmessage = (event) => {
        const message: WebSocketMessage = JSON.parse(event.data);

        if (message.type === 'update') {
          setAgents(message.agents);
        }
      };

      ws.onerror = (error) => {
        console.error('WebSocket error:', error);
      };

      ws.onclose = () => {
        console.log('Disconnected, reconnecting...');
        setConnected(false);

        // Auto-reconnect after 2 seconds
        reconnectTimeoutRef.current = setTimeout(() => {
          connect(url);
        }, 2000);
      };

      wsRef.current = ws;
    } catch (error) {
      console.error('Failed to connect:', error);
    }
  }, []);

  const disconnect = useCallback(() => {
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
    }
    if (wsRef.current) {
      wsRef.current.close();
      wsRef.current = null;
    }
  }, []);

  const sendFocusCommand = useCallback((agentId: string) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify({
        type: 'focus',
        agentId,
      }));
    }
  }, []);

  useEffect(() => {
    return () => {
      disconnect();
    };
  }, [disconnect]);

  return {
    agents,
    connected,
    connect,
    disconnect,
    sendFocusCommand,
  };
}
```

### Keep Screen Awake Implementation

**hooks/useKeepAwake.ts:**
```typescript
import { useEffect } from 'react';
import { activateKeepAwake, deactivateKeepAwake } from 'expo-keep-awake';

export function useKeepAwake() {
  useEffect(() => {
    // Prevent screen from sleeping while monitoring agents
    activateKeepAwake();

    return () => {
      deactivateKeepAwake();
    };
  }, []);
}
```

**Usage in AgentListScreen:**
```typescript
import { useKeepAwake } from '../hooks/useKeepAwake';

export function AgentListScreen() {
  useKeepAwake(); // Screen stays awake while on this screen

  // ... rest of component
}
```

### QR Scanner Implementation

**screens/QRScannerScreen.tsx:**
```typescript
import React, { useState, useEffect } from 'react';
import { Text, View, StyleSheet, Button } from 'react-native';
import { BarCodeScanner } from 'expo-barcode-scanner';

interface QRScannerScreenProps {
  onScan: (url: string) => void;
}

export function QRScannerScreen({ onScan }: QRScannerScreenProps) {
  const [hasPermission, setHasPermission] = useState<boolean | null>(null);
  const [scanned, setScanned] = useState(false);

  useEffect(() => {
    (async () => {
      const { status } = await BarCodeScanner.requestPermissionsAsync();
      setHasPermission(status === 'granted');
    })();
  }, []);

  const handleBarCodeScanned = ({ data }: { data: string }) => {
    setScanned(true);

    // Validate URL format: ws://192.168.x.x:3000
    if (data.startsWith('ws://') || data.startsWith('http://')) {
      onScan(data);
    } else {
      alert('Invalid QR code format');
    }
  };

  if (hasPermission === null) {
    return <Text style={styles.text}>Requesting camera permission...</Text>;
  }

  if (hasPermission === false) {
    return <Text style={styles.text}>No access to camera</Text>;
  }

  return (
    <View style={styles.container}>
      <BarCodeScanner
        onBarCodeScanned={scanned ? undefined : handleBarCodeScanned}
        style={StyleSheet.absoluteFillObject}
      />
      {scanned && (
        <Button title="Tap to Scan Again" onPress={() => setScanned(false)} />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
  },
  text: {
    color: '#fff',
    textAlign: 'center',
  },
});
```

### AsyncStorage for Persistence

**utils/storage.ts:**
```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';

const KEYS = {
  SERVER_URL: '@agent_deck:server_url',
  LAST_CONNECTED: '@agent_deck:last_connected',
};

export async function saveServerUrl(url: string): Promise<void> {
  try {
    await AsyncStorage.setItem(KEYS.SERVER_URL, url);
  } catch (error) {
    console.error('Failed to save server URL:', error);
  }
}

export async function getServerUrl(): Promise<string | null> {
  try {
    return await AsyncStorage.getItem(KEYS.SERVER_URL);
  } catch (error) {
    console.error('Failed to get server URL:', error);
    return null;
  }
}

export async function saveLastConnectedTimestamp(): Promise<void> {
  try {
    await AsyncStorage.setItem(KEYS.LAST_CONNECTED, Date.now().toString());
  } catch (error) {
    console.error('Failed to save timestamp:', error);
  }
}
```

### Navigation with @react-navigation

**App.tsx:**
```typescript
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { AgentListScreen } from './src/screens/AgentListScreen';
import { QRScannerScreen } from './src/screens/QRScannerScreen';
import { SettingsScreen } from './src/screens/SettingsScreen';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName="AgentList"
        screenOptions={{
          headerStyle: {
            backgroundColor: '#1a1a1a',
          },
          headerTintColor: '#fff',
        }}
      >
        <Stack.Screen
          name="AgentList"
          component={AgentListScreen}
          options={{ title: 'Agent Deck' }}
        />
        <Stack.Screen
          name="QRScanner"
          component={QRScannerScreen}
          options={{ title: 'Scan QR Code' }}
        />
        <Stack.Screen
          name="Settings"
          component={SettingsScreen}
          options={{ title: 'Settings' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

### Theme and Dark Mode

**theme/colors.ts:**
```typescript
export const colors = {
  background: '#1a1a1a',
  card: '#2a2a2a',
  text: '#ffffff',
  textSecondary: '#aaaaaa',
  textTertiary: '#888888',
  border: '#333333',

  // Status colors
  statusIdle: '#666666',
  statusRunning: '#4ade80',
  statusError: '#f87171',

  // Accent
  primary: '#3b82f6',
  primaryPressed: '#2563eb',
};
```

**Usage in components:**
```typescript
import { colors } from '../theme/colors';

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.background,
  },
  card: {
    backgroundColor: colors.card,
  },
  text: {
    color: colors.text,
  },
});
```

---

## Development Constraints

### Phase 0 Focus (Monorepo Setup - 4 Days)

**IN SCOPE:**
- ✅ Create monorepo structure (apps/, packages/)
- ✅ Configure pnpm workspaces
- ✅ Set up shared-types package
- ✅ Configure TypeScript across workspaces
- ✅ Initialize React Native project with Expo
- ✅ Set up basic navigation (React Navigation)
- ✅ Configure dark mode theme

**OUT OF SCOPE:**
- ❌ Implementing features (Phase 1-2)
- ❌ WebSocket integration (Phase 1-2)
- ❌ QR scanner (Phase 1-2)

### Phase 1-2 Focus (MVP - 2 Weeks)

**IN SCOPE:**
- ✅ Monitoring only (no interaction with agents yet)
- ✅ Claude Code process detection (Swift)
- ✅ Basic output parsing (current task)
- ✅ Window switching (AppleScript)
- ✅ WebSocket server (Swift, localhost:3000)
- ✅ React Native mobile interface (basic)
- ✅ QR code pairing (Expo barcode scanner)
- ✅ Custom actions (basic: AppleScript, Bash)
- ✅ Real-time updates (WebSocket client in React Native)

**OUT OF SCOPE (Phase 3+):**
- ❌ Mobile interaction (approval prompts) - Phase 5
- ❌ Full output parsing (todo list, status line) - Phase 3
- ❌ Multiple agent types (Cursor, Windsurf) - Phase 3
- ❌ Advanced custom actions - Phase 5
- ❌ Code signing/notarization - Phase 6
- ❌ Auto-updates - Phase 6

### Performance Targets

**macOS App:**
- **CPU**: <2% idle, <5% active
- **Memory**: <100MB RAM
- **Latency**: <500ms status update, <1s window switch
- **Startup**: <2s to menubar ready

**React Native App:**
- **Memory**: <150MB RAM on device
- **FPS**: 60fps for animations
- **WebSocket reconnect**: <2s
- **Cold start**: <3s to first screen

### Security Constraints

**Phase 1-2:**
- Local network only (bind to 0.0.0.0:3000)
- No authentication (trust local network)
- No encryption (plain WebSocket, not WSS)
- Accessibility permissions required (for window switching)
- Camera permission required (for QR scanning)

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

### React Native Patterns

**Functional components with hooks:**
```typescript
import React, { useState, useEffect } from 'react';
import { View, Text } from 'react-native';

export function ExampleComponent() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    // Component mounted
    console.log('Mounted');

    return () => {
      // Component unmounted (cleanup)
      console.log('Unmounted');
    };
  }, []); // Empty deps = run once on mount

  return (
    <View>
      <Text>Count: {count}</Text>
    </View>
  );
}
```

**Custom hooks for reusable logic:**
```typescript
// hooks/useConnectionStatus.ts
import { useState, useEffect } from 'react';

export function useConnectionStatus(ws: WebSocket | null) {
  const [connected, setConnected] = useState(false);

  useEffect(() => {
    if (!ws) return;

    const handleOpen = () => setConnected(true);
    const handleClose = () => setConnected(false);

    ws.addEventListener('open', handleOpen);
    ws.addEventListener('close', handleClose);

    return () => {
      ws.removeEventListener('open', handleOpen);
      ws.removeEventListener('close', handleClose);
    };
  }, [ws]);

  return connected;
}
```

**Pressable for touch interactions:**
```typescript
<Pressable
  style={({ pressed }) => [
    styles.button,
    pressed && styles.buttonPressed,
  ]}
  onPress={handlePress}
>
  <Text style={styles.buttonText}>Press Me</Text>
</Pressable>
```

**Animated feedback with Reanimated:**
```typescript
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';

export function AnimatedCard() {
  const scale = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const handlePress = () => {
    scale.value = withSpring(0.95, {}, () => {
      scale.value = withSpring(1);
    });
  };

  return (
    <Animated.View style={[styles.card, animatedStyle]}>
      {/* Card content */}
    </Animated.View>
  );
}
```

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
- [ ] Agent cards show status (idle/running/error)
- [ ] Tapping agent card focuses window
- [ ] WebSocket reconnects after disconnect
- [ ] Screen stays awake during monitoring
- [ ] Dark mode renders correctly

**Expo Go Testing:**
```bash
# Start Expo dev server
pnpm mobile

# Scan QR code with Expo Go app on physical device
# OR press 'i' for iOS simulator, 'a' for Android emulator
```

### Phase 3+ (Post-MVP)
**Add automated tests:**

**Swift:**
- XCTest for Swift code
- Unit tests for ProcessMonitor
- Unit tests for TranscriptParser

**React Native:**
- Jest for unit tests
- React Native Testing Library for component tests
- Integration tests for WebSocket

**Example Jest test:**
```typescript
import { render, fireEvent } from '@testing-library/react-native';
import { AgentCard } from '../AgentCard';

describe('AgentCard', () => {
  const mockAgent = {
    id: '1',
    pid: 12345,
    name: 'Claude Code',
    agentType: 'claude-code' as const,
    cwd: '/Users/test/project',
    status: 'running' as const,
    currentTask: 'Implementing feature',
  };

  it('renders agent name', () => {
    const { getByText } = render(
      <AgentCard agent={mockAgent} onPress={() => {}} />
    );

    expect(getByText('Claude Code')).toBeTruthy();
  });

  it('calls onPress when tapped', () => {
    const onPress = jest.fn();
    const { getByText } = render(
      <AgentCard agent={mockAgent} onPress={onPress} />
    );

    fireEvent.press(getByText('Claude Code'));
    expect(onPress).toHaveBeenCalled();
  });
});
```

---

## Common Pitfalls & How to Avoid

### 1. ❌ Don't Use npm or yarn
**Why:** pnpm is required for workspace management
**Instead:** Always use pnpm for all package operations

**Wrong:**
```bash
npm install
yarn add react-native-reanimated
```

**Correct:**
```bash
pnpm install
pnpm --filter mobile add react-native-reanimated
```

### 2. ❌ Don't Import Relative Paths from Shared
**Why:** Breaks TypeScript references and IDE autocomplete
**Instead:** Use workspace protocol in package.json

**Wrong:**
```typescript
import type { AgentInstance } from '../../../packages/shared-types/src/agent';
```

**Correct:**
```json
// apps/mobile/package.json
{
  "dependencies": {
    "@agent-deck/shared-types": "workspace:*"
  }
}
```

```typescript
import type { AgentInstance } from '@agent-deck/shared-types';
```

### 3. ❌ Don't Use Node.js for Backend
**Why:** Forces users to install Node.js + dependencies
**Instead:** Embed server in Swift app (single .app bundle)

### 4. ❌ Don't Try to Parse All Agent Types Initially
**Why:** Each agent (Cursor, Windsurf) has different output formats
**Instead:** Start with Claude Code only (Phase 1-2), add others in Phase 3

### 5. ❌ Don't Build Mobile Interaction in MVP
**Why:** Adds 1-2 weeks of complexity (PTY wrapper, stdin injection)
**Instead:** Monitoring only in MVP, interaction in Phase 5

### 6. ❌ Don't Store Sensitive Data in AsyncStorage
**Why:** AsyncStorage is NOT encrypted on device
**Instead:** Use expo-secure-store for tokens/secrets

**Wrong:**
```typescript
await AsyncStorage.setItem('auth_token', token);
```

**Correct:**
```typescript
import * as SecureStore from 'expo-secure-store';
await SecureStore.setItemAsync('auth_token', token);
```

### 7. ❌ Don't Bind WebSocket to 127.0.0.1
**Why:** Mobile devices can't connect (different IP)
**Instead:** Bind to 0.0.0.0:3000 (all interfaces on local network)

### 8. ❌ Don't Forget Accessibility Permissions
**Why:** AppleScript window switching requires accessibility access
**Instead:** Prompt user on first launch, document in README

### 9. ❌ Don't Forget to Request Camera Permission
**Why:** QR scanner won't work without camera permission
**Instead:** Use expo-barcode-scanner's requestPermissionsAsync

---

## Configuration Management

### YAML Config Files (macOS)

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

### Client (React Native TypeScript)

```typescript
// services/websocket.ts
import type { AgentInstance, WebSocketMessage } from '@agent-deck/shared-types';

export class WebSocketClient {
  private ws: WebSocket | null = null;
  private reconnectDelay = 2000;
  private reconnectTimeout?: NodeJS.Timeout;

  constructor(
    private url: string,
    private onUpdate: (agents: AgentInstance[]) => void,
    private onConnectionChange: (connected: boolean) => void
  ) {}

  connect() {
    try {
      this.ws = new WebSocket(this.url);

      this.ws.onopen = () => {
        console.log('Connected to Agent Deck');
        this.onConnectionChange(true);
      };

      this.ws.onmessage = (event) => {
        const message: WebSocketMessage = JSON.parse(event.data);

        if (message.type === 'update') {
          this.onUpdate(message.agents);
        }
      };

      this.ws.onerror = (error) => {
        console.error('WebSocket error:', error);
      };

      this.ws.onclose = () => {
        console.log('Disconnected, reconnecting...');
        this.onConnectionChange(false);

        // Auto-reconnect
        this.reconnectTimeout = setTimeout(() => {
          this.connect();
        }, this.reconnectDelay);
      };
    } catch (error) {
      console.error('Failed to connect:', error);
    }
  }

  disconnect() {
    if (this.reconnectTimeout) {
      clearTimeout(this.reconnectTimeout);
    }
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }

  sendFocusCommand(agentId: string) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify({
        type: 'focus',
        agentId,
      }));
    }
  }
}
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
let url = "ws://\(localIP):3000"
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

### React Native (TypeScript)

```typescript
// utils/errors.ts
export class ConnectionError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ConnectionError';
  }
}

export function handleWebSocketError(error: any) {
  if (error instanceof ConnectionError) {
    // Show user-friendly message
    Alert.alert(
      'Connection Error',
      'Could not connect to Agent Deck. Make sure the Mac app is running and you are on the same WiFi network.',
      [{ text: 'OK' }]
    );
  } else {
    // Generic error
    Alert.alert('Error', error.message || 'An unexpected error occurred');
  }
}
```

**Error boundaries (React Native):**
```typescript
import React, { Component, ErrorInfo, ReactNode } from 'react';
import { View, Text, StyleSheet } from 'react-native';

interface Props {
  children: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = {
    hasError: false,
  };

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <View style={styles.container}>
          <Text style={styles.title}>Something went wrong</Text>
          <Text style={styles.message}>{this.state.error?.message}</Text>
        </View>
      );
    }

    return this.props.children;
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#1a1a1a',
  },
  title: {
    color: '#fff',
    fontSize: 20,
    fontWeight: 'bold',
  },
  message: {
    color: '#aaa',
    fontSize: 14,
    marginTop: 8,
  },
});
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

### React Native

**Console logging (development):**
```typescript
console.log('Info message');
console.warn('Warning message');
console.error('Error message');
```

**Structured logging (production):**
```typescript
// utils/logger.ts
export const logger = {
  info: (message: string, data?: any) => {
    if (__DEV__) {
      console.log(`[INFO] ${message}`, data);
    }
    // In production, send to logging service
  },

  error: (message: string, error?: any) => {
    if (__DEV__) {
      console.error(`[ERROR] ${message}`, error);
    }
    // In production, send to error tracking service (Sentry, etc.)
  },

  warn: (message: string, data?: any) => {
    if (__DEV__) {
      console.warn(`[WARN] ${message}`, data);
    }
  },
};
```

---

## Resources & References

**Official Documentation:**
- Agent Deck Spec: `agent-deck-spec-final.md` (full specification)
- SpecKit Docs: https://speckit.org
- Swift Documentation: https://swift.org/documentation/
- SwiftUI Tutorials: https://developer.apple.com/tutorials/swiftui
- React Native Docs: https://reactnative.dev/docs/getting-started
- Expo Docs: https://docs.expo.dev/
- pnpm Docs: https://pnpm.io/

**Similar Projects:**
- Touch Portal: https://www.touch-portal.com/
- Stream Deck: https://www.elgato.com/stream-deck
- Omnara: https://omnara.ai/ (competitor analysis)

**Technologies:**
- Swift Package Manager: https://swift.org/package-manager/
- Vapor (if using): https://vapor.codes/
- WebSocket Protocol: https://datatracker.ietf.org/doc/html/rfc6455
- React Navigation: https://reactnavigation.org/
- Expo Keep Awake: https://docs.expo.dev/versions/latest/sdk/keep-awake/
- Expo Barcode Scanner: https://docs.expo.dev/versions/latest/sdk/bar-code-scanner/

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

# 3. Monorepo
pnpm install             # Install all dependencies
pnpm mobile              # Start Expo dev server
pnpm mobile:ios          # Run on iOS simulator
pnpm mobile:android      # Run on Android emulator
pnpm typecheck           # Type check all packages

# 4. Xcode project (Swift)
cd apps/macos && open Agent-Deck.xcodeproj
# (Command+R in Xcode to run)
```

**When testing:**
```bash
# Check running processes
ps aux | grep claude

# Test WebSocket (Terminal 1)
# Run Mac app first

# Test WebSocket (Terminal 2)
wscat -c ws://localhost:3000

# View logs (macOS)
log stream --predicate 'subsystem == "com.agentdeck.app"'

# Test React Native on iPhone (Expo Go)
# 1. Install Expo Go from App Store
# 2. pnpm mobile
# 3. Scan QR code with Expo Go app

# Test on iOS simulator
pnpm mobile:ios

# Test on Android emulator
pnpm mobile:android
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

**File:** `apps/macos/Agent-Deck/Services/TranscriptWatcher.swift:58`

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

**File:** `apps/macos/Agent-Deck/Services/ProcessMonitor.swift:514-520`

### 🔴 Path Matching
**Don't try to convert directory names to paths.** Read `cwd` from transcript JSON.

```swift
// ✅ Read cwd from JSON, don't derive from directory name
func readCwdFromTranscript(path: String) -> String? {
    // Parse JSONL for "cwd" field
}
```

**File:** `apps/macos/Agent-Deck/Services/ProcessMonitor.swift:532`

### Pieces Memories Created
Three comprehensive memories saved covering:
1. FSEvents C pointer handling (crashes and fixes)
2. @Published struct replacement pattern (Combine triggering)
3. Complete real-time monitoring architecture

**Access with:** "Show me FSEvents Swift pattern" or "How did I fix @Published?"

---

## Version

**CLAUDE.md Version:** 2.0
**Last Updated:** 2025-01-08
**Agent Deck Phase:** Phase 0 (Monorepo setup) → Phase 1-2 (React Native MVP)
**SpecKit Template:** spec-kit-template-claude-sh-v0.0.79

---

**Remember:** Speed to market. 2.5-week MVP (0.5 weeks setup + 2 weeks dev). Ship, validate, iterate. 🚀

## Active Technologies
- Swift 5.7+ (Swift 6 compatible targeting macOS 12+) - macOS menubar app
- React Native 0.73+ (Expo SDK 50+) - Mobile app (iOS/Android)
- TypeScript 5.0+ - Mobile app and shared types
- pnpm 8+ - Monorepo package management
- FSEvents (macOS file system monitoring)
- Combine (reactive state management)
- WebSocket (real-time communication)

## Recent Changes
- 2025-01-08: ✅ Updated CLAUDE.md for monorepo + React Native architecture (Constitution v2.0)
- 2025-01-08: Added comprehensive React Native patterns and monorepo development sections
- 2025-01-08: Updated file structure to reflect apps/macos, apps/mobile, packages/shared-types
- 2025-01-05: ✅ Real-time monitoring complete (FSEvents + Combine + WebSocket)
- 2025-01-05: Added LESSONS_LEARNED.md with critical patterns
- 2025-01-05: Created 3 Pieces memories for future reference
