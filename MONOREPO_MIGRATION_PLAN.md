# Agent Deck: React Native Migration & Monorepo Restructure Plan

**Created**: 2025-01-08
**Status**: Ready for Implementation
**Impact**: Major architectural change - PWA → React Native + Monorepo

---

## Executive Summary

**Decision**: Transition from PWA to React Native for mobile interface, establish monorepo structure for Swift macOS app + React Native mobile app.

**Rationale**:
1. **Better UX**: Native feel eliminates browser URL bar, provides full-screen focus
2. **Native features**: Keep screen awake, proper notifications, better performance
3. **Faster to market**: Build native app directly in MVP instead of waiting for Phase 7
4. **Same timeline**: RN development time ≈ PWA development time (no delay)
5. **Monorepo benefits**: Code sharing, unified CI/CD, single source of truth

**Timeline**:
- Monorepo setup: 4 days
- React Native MVP: 2 weeks (unchanged from PWA estimate)
- **Total to MVP**: ~2.5 weeks

---

## Architecture Decision

### Mobile Platform: React Native (Expo)

**Why React Native instead of PWA:**
- ✅ Eliminates browser chrome (URL bar, tabs)
- ✅ Native features (keep screen awake, proper push notifications)
- ✅ Better performance (native rendering)
- ✅ Professional look and feel
- ✅ Same development speed as PWA for simple UI
- ✅ App store distribution (later phases)

**Why Expo:**
- ✅ Zero native config for MVP
- ✅ Fast iteration (Expo Go for development)
- ✅ WebSocket client built-in
- ✅ Easy to add native modules later
- ✅ TypeScript support out of box

**Keeping PWA?**
- 🤔 **Decision**: Keep embedded PWA for web access (optional)
- Embedded PWA continues serving from `Resources/WebRoot/`
- React Native mobile app is primary interface
- PWA acts as backup/web interface
- Same WebSocket protocol for both

---

## Monorepo Structure

### Recommended Directory Layout

```
agent-deck/                          # Root monorepo
├── apps/
│   ├── macos/                       # Swift menubar app
│   │   ├── Agent-Deck.xcodeproj/
│   │   ├── Sources/
│   │   │   ├── AppDelegate.swift
│   │   │   ├── Models/
│   │   │   ├── Services/
│   │   │   ├── Views/
│   │   │   └── Utilities/
│   │   └── Resources/
│   │       ├── Assets.xcassets/
│   │       ├── default-config.yaml
│   │       └── WebRoot/             # Embedded PWA (optional)
│   │           ├── index.html
│   │           ├── app.js
│   │           └── styles.css
│   │
│   └── mobile/                      # React Native + Expo
│       ├── app.json                 # Expo config
│       ├── package.json
│       ├── App.tsx                  # Root component
│       ├── src/
│       │   ├── screens/
│       │   │   ├── AgentListScreen.tsx
│       │   │   ├── SettingsScreen.tsx
│       │   │   └── CustomActionsScreen.tsx
│       │   ├── components/
│       │   │   ├── AgentCard.tsx
│       │   │   ├── ActionButton.tsx
│       │   │   └── ConnectionStatus.tsx
│       │   ├── hooks/
│       │   │   ├── useWebSocket.ts
│       │   │   └── useKeepAwake.ts
│       │   ├── services/
│       │   │   └── websocket.ts
│       │   └── types/
│       │       └── agent.ts
│       └── assets/
│           └── icons/
│
├── packages/                        # Shared JavaScript/TypeScript
│   ├── shared-types/                # TypeScript definitions
│   │   ├── package.json
│   │   └── src/
│   │       ├── agent.ts
│   │       ├── websocket.ts
│   │       └── config.ts
│   │
│   └── shared-utils/                # Utilities (if needed)
│       ├── package.json
│       └── src/
│           └── formatters.ts
│
├── .specify/                        # SpecKit artifacts (root level)
│   ├── memory/
│   │   ├── constitution.md
│   │   ├── spec.md
│   │   ├── plan.md
│   │   └── tasks.md
│   └── templates/
│
├── pnpm-workspace.yaml             # pnpm workspace config
├── package.json                     # Root package.json
├── .gitignore
├── README.md
├── CLAUDE.md
└── LESSONS_LEARNED.md
```

---

## Migration Steps

### Phase 1: Monorepo Setup (Day 1-2)

**Tasks:**
1. ✅ Back up current project
2. ✅ Create `apps/` and `packages/` directories
3. ✅ Move `Agent-Deck/` → `apps/macos/`
4. ✅ Create `pnpm-workspace.yaml`
5. ✅ Create root `package.json`
6. ✅ Initialize Expo project at `apps/mobile/`
7. ✅ Test: `pnpm install` works, Swift app still builds

**Deliverables:**
- Monorepo structure established
- Swift app builds and runs from `apps/macos/`
- Expo project initialized at `apps/mobile/`
- pnpm workspaces configured

---

### Phase 2: Extract Shared Types (Day 3)

**Tasks:**
1. ✅ Create `packages/shared-types/`
2. ✅ Define TypeScript interfaces for:
   - AgentInstance
   - StatusUpdate
   - CustomAction
   - WebSocketMessage
   - Configuration
3. ✅ Export types from shared-types
4. ✅ Configure mobile app to use `workspace:*` dependencies

**Deliverables:**
- TypeScript definitions in `packages/shared-types/`
- Mobile app imports types from shared package
- Type safety across mobile + PWA (if kept)

---

### Phase 3: Build React Native Mobile App (Day 4-16)

**Tasks:**

**Week 1 (Day 4-9): Core Functionality**
1. ✅ WebSocket connection to Mac app
2. ✅ Display agent instances list
3. ✅ Real-time status updates
4. ✅ Tap to focus window
5. ✅ Connection status indicator
6. ✅ Auto-reconnect logic

**Week 2 (Day 10-16): Polish & Features**
1. ✅ Custom actions grid (4-column layout)
2. ✅ Expandable panel for actions
3. ✅ Keep screen awake toggle
4. ✅ Dark mode UI
5. ✅ Settings screen (server URL, preferences)
6. ✅ QR code scanner for easy setup
7. ✅ Error handling and toast notifications

**Deliverables:**
- Working React Native mobile app
- Feature parity with original PWA spec
- Native features (keep screen awake)
- QR code pairing
- Build succeeds on iOS and Android

---

### Phase 4: Documentation & Testing (Day 17-18)

**Tasks:**
1. ✅ Update constitution (Mobile Validation Strategy principle)
2. ✅ Update spec.md (React Native requirements)
3. ✅ Update plan.md (monorepo + RN implementation)
4. ✅ Update tasks.md (RN tasks)
5. ✅ Update CLAUDE.md (monorepo structure, RN patterns)
6. ✅ Update README (setup instructions for monorepo)
7. ✅ Test on physical iOS device
8. ✅ Test on Android emulator/device
9. ✅ Verify Mac ↔ mobile communication

**Deliverables:**
- All documentation updated
- Tested on iOS and Android
- Ready for MVP launch

---

## Technology Stack (Updated)

### macOS Application (Unchanged)
- **Platform**: macOS 12+
- **Language**: Swift 5.7+ (Swift 6 compatible)
- **UI**: SwiftUI
- **Frameworks**: Combine, Network.framework, NSWorkspace, NSAppleScript
- **Distribution**: Single .app bundle

### Mobile Application (NEW - React Native)
- **Framework**: React Native 0.73+ (via Expo SDK 50+)
- **Language**: TypeScript
- **Platform**: iOS 15+, Android 8+ (API 26+)
- **Build Tool**: Expo
- **Development**: Expo Go for fast iteration
- **Distribution**:
  - Development: Expo Go
  - Production: Expo Build (EAS) → App Store / Play Store

### Monorepo Management (NEW)
- **Tool**: pnpm (v8+)
- **Workspaces**: `pnpm-workspace.yaml`
- **Package Manager**: pnpm (fastest, most efficient for monorepos in 2025)

### Shared Packages (NEW)
- **packages/shared-types**: TypeScript interfaces and types
- **packages/shared-utils**: Utilities (if needed)
- **Language**: TypeScript
- **Import**: `workspace:*` protocol

---

## PWA Coexistence Strategy

**Decision**: Keep embedded PWA as optional web interface

**Implementation**:
1. PWA remains at `apps/macos/Resources/WebRoot/`
2. Swift app continues serving PWA via HTTP server
3. React Native is **primary mobile interface**
4. PWA acts as **backup/web access** for:
   - Desktop browsers (if user prefers)
   - Tablets (iPad, Android tablets)
   - Quick access without app install

**Tradeoffs**:
- ✅ Keeps web access option
- ✅ No additional code (already built)
- ✅ Same WebSocket protocol
- ⚠️ Small maintenance overhead (2 mobile interfaces)

**Recommendation**: Keep PWA for now, deprecate in Phase 3+ if unused

---

## Shared Code Strategy

### What CAN Be Shared (JavaScript/TypeScript)

| Type | Shareable? | How | Example |
|------|-----------|-----|---------|
| **TypeScript types** | ✅ YES | pnpm `packages/shared-types` | AgentInstance, StatusUpdate |
| **Business logic** | ✅ YES | pnpm `packages/shared-utils` | formatTimestamp, parseStatus |
| **WebSocket protocol** | ✅ YES | Shared types | Message schemas |
| **Constants** | ✅ YES | Shared config | API endpoints, defaults |

### What CANNOT Be Shared

| Type | Why Not | Solution |
|------|---------|----------|
| **Swift code** | Cannot run in JavaScript | Keep in `apps/macos/` |
| **React Native UI** | Platform-specific | Keep in `apps/mobile/` |
| **Native modules** | Platform-specific | Keep in respective apps |

---

## Build & Development Workflow

### Installation (First Time)

```bash
# Install pnpm
npm install -g pnpm

# Clone/navigate to project
cd agent-deck/

# Install all dependencies
pnpm install
```

### Development Commands

```bash
# Start mobile app (Expo Go)
cd apps/mobile && pnpm start

# Start on iOS simulator
cd apps/mobile && pnpm ios

# Start on Android emulator
cd apps/mobile && pnpm android

# Build Swift macOS app
cd apps/macos && open Agent-Deck.xcodeproj
# Then Command+R in Xcode

# Install dependency in specific app
pnpm -F @agent-deck/mobile add react-native-keep-awake

# Run type checking across all packages
pnpm -r typecheck
```

### Production Builds

```bash
# Build macOS app (Xcode Archive)
cd apps/macos && xcodebuild -scheme Agent-Deck archive

# Build mobile app (Expo Build Service)
cd apps/mobile && eas build --platform ios
cd apps/mobile && eas build --platform android
```

---

## SpecKit Integration

**SpecKit remains at root level** (`.specify/`)

**No changes needed to SpecKit workflow:**
```bash
/speckit.specify      # Still creates ONE spec
/speckit.plan         # Still ONE plan
/speckit.tasks        # Still ONE task list (references apps/macos + apps/mobile)
```

SpecKit spec, plan, and tasks will reference:
- `apps/macos/` for Swift implementation
- `apps/mobile/` for React Native implementation
- `packages/shared-types/` for shared types

---

## Updated Constitution Principles

### III. Mobile Validation Strategy (UPDATED)

**Before (PWA-first)**:
> PWA first, native mobile later. Works on ALL devices immediately (universal access). No app store delays (iterate daily). Build native iOS/Android only if 100+ users demand it (Phase 7+).

**After (React Native MVP)**:
> React Native for mobile in MVP. Native app provides better UX (no browser chrome), native features (keep screen awake), and professional feel. Build for iOS and Android simultaneously using Expo. Iterate rapidly via Expo Go during development. Optional embedded PWA serves as web backup.

**Rationale**:
- React Native development time ≈ PWA time for simple UI
- Native features (keep screen awake) only possible with native app
- Better user experience justifies upfront native development
- Expo enables rapid iteration (same speed as PWA)
- Native feel critical for productivity app

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| **Monorepo setup takes longer than 4 days** | Medium | Medium | Follow research guide step-by-step, use byCedric template |
| **RN learning curve delays MVP** | Low | High | Expo simplifies RN, TypeScript already known, simple UI |
| **Build size too large** | Low | Low | Expo tree-shaking, remove unused dependencies |
| **pnpm compatibility issues** | Low | Medium | pnpm fully compatible with Expo SDK 50+, well-tested |
| **Native features cause app store rejection** | Low | Medium | Keep screen awake is standard, no privacy concerns |

**Overall Risk**: LOW - Production-proven pattern, clear roadmap

---

## Success Criteria (Updated)

### Monorepo Setup Complete When:
- ✅ pnpm install works without errors
- ✅ Swift app builds from `apps/macos/`
- ✅ Expo app runs on iOS/Android from `apps/mobile/`
- ✅ Shared types imported successfully
- ✅ SpecKit commands work from root

### React Native MVP Complete When:
- ✅ Mobile app connects to Mac WebSocket server
- ✅ Agent instances display with real-time updates (<500ms)
- ✅ Tap to focus window works (<1s latency)
- ✅ Custom actions execute successfully
- ✅ QR code pairing works
- ✅ Keep screen awake toggle works
- ✅ Works on iOS 15+ and Android 8+
- ✅ Build succeeds for both platforms

---

## Next Actions

**Immediate**:
1. ✅ Review this plan with stakeholders
2. ✅ Approve monorepo + React Native approach
3. ✅ Back up current codebase
4. ✅ Schedule 2.5-week sprint

**Implementation**:
1. Day 1-2: Monorepo setup
2. Day 3: Extract shared types
3. Day 4-16: Build React Native app
4. Day 17-18: Documentation and testing

**After MVP**:
- Gather user feedback
- Iterate on mobile UX
- Consider deprecating PWA if unused
- Plan Phase 3 features

---

**Document Version**: 1.0
**Created**: 2025-01-08
**Last Updated**: 2025-01-08
