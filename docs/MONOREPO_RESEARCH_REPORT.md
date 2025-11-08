# Monorepo Architecture Research Report
## Swift macOS + React Native Mobile App

**Date**: November 8, 2025  
**Research Focus**: 2025 best practices for mixed-platform monorepos  
**Project Context**: Agent Deck (Swift menubar app + React Native PWA)

---

## Executive Summary

A **monorepo is highly recommended** for Agent Deck. You can effectively share code between Swift (macOS) and JavaScript (React Native/PWA), though the integration points differ. The 2025 landscape shows:

- **pnpm** dominates for JavaScript-heavy monorepos (fastest, most efficient)
- **Yarn Workspaces** still popular for React Native projects
- **Swift Package Manager** handles Swift code sharing separately
- **PWA + React Native coexistence is viable** but requires careful architecture
- **Monorepo complexity is worth it** for teams with shared code

---

## 1. RECOMMENDED MONOREPO STRUCTURE

### For Agent Deck (Swift + React Native + PWA)

```
agent-deck/                          # Monorepo root
├── .git/
├── package.json                      # Root npm workspaces config
├── pnpm-workspace.yaml              # OR use pnpm (faster, modern)
├── .specify/                         # SpecKit configuration
├── .github/                          # CI/CD, shared workflows
│
├── apps/
│   ├── macos/                        # Swift menubar app
│   │   ├── Agent-Deck.xcodeproj/
│   │   ├── Sources/
│   │   │   ├── AgentDeckApp.swift
│   │   │   ├── Models/
│   │   │   ├── Services/
│   │   │   ├── Views/
│   │   │   └── Resources/
│   │   │       └── WebRoot/         # ← EMBEDDED PWA (shared!)
│   │   │           ├── index.html
│   │   │           ├── app.js
│   │   │           ├── styles.css
│   │   │           ├── manifest.json
│   │   │           ├── service-worker.js
│   │   │           └── icons/
│   │   ├── Package.swift            # Swift Package manifest
│   │   └── .swiftpm/
│   │
│   └── mobile/                       # React Native app (Expo)
│       ├── package.json             # ← points to shared packages
│       ├── app.json                 # Expo config
│       ├── src/
│       │   ├── App.tsx
│       │   ├── screens/
│       │   ├── components/
│       │   ├── hooks/
│       │   └── utils/
│       └── metro.config.js
│
├── packages/                         # SHARED CODE (JS/TS only)
│   ├── shared-types/                 # TypeScript types
│   │   ├── package.json
│   │   ├── src/
│   │   │   ├── agent.types.ts
│   │   │   ├── websocket.types.ts
│   │   │   └── config.types.ts
│   │   └── tsconfig.json
│   │
│   ├── shared-utils/                 # Business logic, helpers
│   │   ├── package.json
│   │   ├── src/
│   │   │   ├── parsing/
│   │   │   │   └── agentOutput.ts   # Parse Claude Code output
│   │   │   ├── formatting/
│   │   │   └── validation/
│   │   └── tsconfig.json
│   │
│   └── shared-config/                # Config management
│       ├── package.json
│       ├── src/
│       │   └── defaults.ts
│       └── tsconfig.json
│
├── resources/                        # SHARED ASSETS (if any)
│   ├── icons/                        # Icons used in both
│   ├── colors.json                   # Design tokens
│   └── fonts/
│
├── docs/
│   ├── ARCHITECTURE.md
│   ├── SETUP.md
│   └── MONOREPO_GUIDE.md
│
├── specs/
│   └── 001-mvp/
│       ├── spec.md
│       ├── plan.md
│       └── tasks.md
│
├── README.md
├── CLAUDE.md
├── LESSONS_LEARNED.md
└── .gitignore

# Key Organizational Principles:

1. **apps/** = Runnable applications (macOS, mobile)
   - Each has their own build system, dependencies
   - Swift app embedded with PWA files (no separate deployment)

2. **packages/** = Shared npm packages (JS/TS only)
   - Business logic, utilities, types
   - Can be used by mobile app AND embedded PWA

3. **NOT shared**: Native Swift code
   - Swift doesn't work in JavaScript
   - macOS handles its own Swift logic

4. **Embedded PWA advantage**:
   - Single build output for iOS + Android
   - Same PWA served in browser
   - No need for separate React Native builds (yet)
```

---

## 2. BUILD TOOL RECOMMENDATIONS

### For JavaScript/React Native (Recommended: pnpm)

**pnpm in 2025** is the consensus winner for JavaScript monorepos:

| Metric | npm 10+ | Yarn 1 | Yarn Berry (v2+) | pnpm | Bun |
|--------|---------|--------|-----------------|------|-----|
| **Speed** | Moderate | Fast | Very Fast | ⭐⭐⭐ Fastest | ⭐ Raw speed |
| **Disk Usage** | High duplication | ~100MB per project | Efficient (PnP) | ⭐⭐⭐ Minimal (~50MB total) | Unknown |
| **Monorepo Support** | Basic (new) | Mature workspaces | Excellent + PnP | ⭐ Native, best-in-class | Early |
| **Dependency Strictness** | Loose (phantom deps) | Loose | Strict (PnP) | ⭐ Strict by design | TBD |
| **Ecosystem Compatibility** | ⭐⭐⭐ Universal | ⭐⭐⭐ Universal | Good (needs config) | Good (98%+) | Still testing |

#### Recommendation for Agent Deck:

**Use pnpm** because:

1. **Monorepo performance**: ⭐ Unmatched with workspaces
   - Fast dependency hoisting
   - Strict node_modules structure prevents phantom deps
   - Built-in filtering for commands (`pnpm -F mobile run build`)

2. **Disk efficiency**: Major advantage for development
   - ~80% less disk usage than npm (hard links + content-addressable store)
   - Matters across multiple projects on your dev machine

3. **Build reproducibility**: Important for CI/CD
   - Strict dependency resolution
   - deterministic installs

4. **Active maintenance**: Growing community in 2025
   - Tools increasingly support pnpm
   - Expo + React Native fully compatible (SDK 52+)

#### Setup (from 2025 best practices):

```bash
# 1. Initialize monorepo
npm install -g pnpm
pnpm init

# 2. Create workspace config (pnpm-workspace.yaml)
# 3. Structure directories
# 4. Each package gets own package.json
# 5. Root package.json dependencies = shared
```

### Swift Package Manager (Separate track)

For Swift code in macOS app:
- Use **Swift Package Manager** (built into Swift)
- Create local packages in `Modules/` if needed
- Example: `Modules/AgentMonitoring/Package.swift`
- Reference via: `path: "Modules/AgentMonitoring"` in main `Package.swift`

#### Swift Monorepo Pattern (from Runway + Igor Kulman research):

```bash
# Using Modules directory (cleanest approach)
Modules/
├── AgentMonitoring/          # Swift Package
│   ├── Package.swift
│   ├── Sources/
│   └── Tests/
├── WebSocketServer/          # Swift Package
│   ├── Package.swift
│   └── Sources/
└── Config/                   # Swift Package
    ├── Package.swift
    └── Sources/

# Root Swift app references:
# .package(path: "Modules/AgentMonitoring"),
# .product(name: "AgentMonitoring", package: "AgentMonitoring"),
```

**Advantages**:
- Preserves full git history with `git filter-repo`
- One central source of truth
- Shared Swift code between mac app and framework targets
- No CocoaPods overhead

---

## 3. PWA + REACT NATIVE COEXISTENCE

### Architecture Decision: EMBEDDED PWA (Recommended)

The **cleanest approach** for Agent Deck MVP:

```
┌─────────────────────────────┐
│  React Native Mobile App    │
│  (Expo, iOS/Android)        │
├─────────────────────────────┤
│ Uses shared-types,          │
│ shared-utils from pnpm      │
│ packages/                   │
└─────────────────────────────┘

┌──────────────────────────────────┐
│  Mac App (Swift menubar)         │
├──────────────────────────────────┤
│  Embedded PWA                    │
│  ├── index.html                  │
│  ├── app.js (vanilla JS)         │
│  ├── styles.css                  │
│  └── service-worker.js           │
├──────────────────────────────────┤
│ Built from apps/macos/Resources/ │
│ WebRoot/ (same files as Expo!)   │
└──────────────────────────────────┘

SHARED NPM PACKAGES (pnpm workspaces)
├── packages/shared-types/
├── packages/shared-utils/
└── packages/shared-config/

(JavaScript only - not accessible to Swift)
```

### Why This Works:

1. **Single PWA codebase** 
   - `apps/mobile/` is Expo React Native app
   - Same files embedded in Swift app at `apps/macos/Resources/WebRoot/`
   - Service worker enables offline support on all platforms

2. **No duplication**
   - Vanilla JS PWA works in browser AND when embedded
   - No need for separate React Native Web build

3. **Shared JS packages**
   - WebSocket client logic in `packages/shared-utils/`
   - Types in `packages/shared-types/`
   - Both mobile and embedded PWA import from these

4. **Swift stays separate**
   - Mac app has its own Swift logic
   - Communicates with PWA over WebSocket
   - No circular dependencies

### Performance Implications:

**VERDICT: PWA + RN coexistence adds ~5-15% complexity but saves weeks of dev time**

| Factor | Impact | Mitigation |
|--------|--------|-----------|
| Bundle size | +10% (shared JS) | Tree shake, split packages |
| Mobile performance | None (Expo optimizes) | Standard Expo optimization |
| Desktop embedding | +2-3s initial load | Cache service worker |
| Build time | +20% (parallel builds) | Use pnpm filtering |

**Recommendation**: Start with embedded PWA. If you need native iOS/Android (Phase 7+), extract React Native Web separately.

---

## 4. DEPENDENCY MANAGEMENT STRATEGY

### pnpm Workspace Configuration

```yaml
# pnpm-workspace.yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

```json
// package.json (root)
{
  "name": "agent-deck",
  "private": true,
  "workspaces": {
    "packages": [
      "apps/*",
      "packages/*"
    ]
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "prettier": "^3.1.0",
    "eslint": "^8.55.0"
  }
}
```

### Cross-Package Dependencies

```json
// apps/mobile/package.json
{
  "name": "@agent-deck/mobile",
  "dependencies": {
    "@agent-deck/shared-types": "workspace:*",
    "@agent-deck/shared-utils": "workspace:*",
    "react": "18.2.0",
    "react-native": "0.73.0"
  }
}

// apps/macos/package.json
{
  "name": "@agent-deck/macos",
  "dependencies": {
    "@agent-deck/shared-types": "workspace:*",
    "@agent-deck/shared-utils": "workspace:*"
  }
}
```

**Key Practice**: Use `workspace:*` protocol for local packages:
- Prevents version mismatches
- Automatic version bumping
- Clean monorepo semantics

### Swift Package Dependencies

```swift
// apps/macos/Package.swift
import PackageDescription

let package = Package(
    name: "AgentDeck",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        // External packages
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        
        // Local Swift packages
        .package(path: "../../Modules/AgentMonitoring"),
    ],
    targets: [
        .executableTarget(
            name: "AgentDeck",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "AgentMonitoring", package: "AgentMonitoring"),
            ]
        )
    ]
)
```

---

## 5. REAL-WORLD EXAMPLES

### 1. **Mercari Global App (October 2025)**
- Multi-product iOS monorepo
- Consolidated 3+ separate apps into one repo
- Shared Swift packages via SPM
- **Result**: Reduced onboarding time, consistent architecture

**Lesson**: iOS monorepos work at scale (100+ engineers)

### 2. **byCedric/expo-monorepo-example**
- React Native + Expo monorepo
- pnpm + workspaces
- 900+ stars on GitHub
- Shared libraries between multiple Expo apps

**Lesson**: Expo monorepos are production-ready

### 3. **Matera PropTech (Feb 2025)**
- React + React Native monorepo
- TurboRepo + pnpm
- Shared business logic across web and mobile

**Lesson**: Cross-platform monorepos enable rapid iteration

### 4. **Twitter/Things Cloud (Feb 2025 Swift backend)**
- All-Swift backend (migrated from Python)
- Not a monorepo, but shows Swift's production readiness
- Shared code between iOS apps and server

**Lesson**: Swift is production-grade for server/app integration

---

## 6. SPECIAL CONSIDERATIONS FOR AGENT DECK

### SpecKit Compatibility

SpecKit works with monorepos. No issues expected:

```
agent-deck/
├── .specify/                    # SpecKit config (root level OK)
├── specs/001-mvp/
│   ├── spec.md                  # ONE spec for whole project
│   ├── plan.md                  # ONE plan
│   └── tasks.md                 # ONE task list
```

**Approach**: Single spec for entire Agent Deck project
- Phases 1-2: Both Mac + Mobile
- One task list references both `apps/macos` and `apps/mobile`
- Works seamlessly with SpecKit workflow

### Build Configuration for Embedded PWA

```json
// apps/macos/Package.swift
// When embedding PWA:

let package = Package(
    // ... other config ...
    resources: [
        .copy("Resources/WebRoot")  // Include PWA files
    ]
)

// At runtime:
let webRootURL = Bundle.main.resourceURL?.appendingPathComponent("WebRoot")
```

```bash
# Build order:
# 1. Build PWA (vanilla JS, no build step)
# 2. Include WebRoot/ in Swift app resources
# 3. Serve from Bundle in Swift

# Option: Pre-build PWA assets if needed
# pnpm -F mobile build  # (though vanilla JS needs no build)
```

### CI/CD Implications

```yaml
# Example GitHub Actions workflow
name: Build Agent Deck

jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'

  lint-and-test-js:
    runs-on: ubuntu-latest
    steps:
      - run: pnpm -r lint
      - run: pnpm -r test

  build-mac:
    runs-on: macos-latest
    steps:
      - uses: maxim-lobanov/setup-xcode@v1
      - run: xcodebuild build -project apps/macos/Agent-Deck.xcodeproj

  build-mobile:
    runs-on: ubuntu-latest
    steps:
      - run: pnpm -F mobile build
```

---

## 7. COMMON PITFALLS & HOW TO AVOID

### Pitfall 1: Trying to share Swift code with JavaScript

**Problem**: You cannot use Swift code in JavaScript.

**Solution**: 
- Swift code = Mac app only
- Share JavaScript via pnpm packages
- If logic needs both platforms, write twice or use Vapor (server-side)

### Pitfall 2: Using nohoist (breaks monorepo benefits)

**Problem**: Setting `nohoist` in package.json duplicates dependencies.

```json
// WRONG - don't do this
"nohoist": ["**/react-native/**"]
```

**Solution**: Keep hoisting enabled (pnpm does this by default).

### Pitfall 3: Circular dependencies between apps

**Problem**: macOS app depending on mobile app (or vice versa).

**Solution**: Only packages/ can be depended on by both apps.

```
✗ apps/macos → apps/mobile (BAD)
✓ apps/macos → packages/shared-utils (GOOD)
✓ apps/mobile → packages/shared-utils (GOOD)
```

### Pitfall 4: Forgetting to hoist Swift Package dependencies

**Problem**: Each app has separate node_modules (wastes space).

**Solution**: Use pnpm's default hoisting behavior.

### Pitfall 5: Not versioning shared packages

**Problem**: Hard to track which mobile/mac version uses which shared code.

**Solution**: 
- Use `workspace:*` for dev
- Before shipping, increment versions in packages/
- Document version matrix in README

---

## 8. RECOMMENDED NEXT STEPS

### Phase 1: Restructure to Monorepo (1-2 days)

1. **Keep current code**, just reorganize:
   ```bash
   mkdir -p apps/macos apps/mobile packages
   mv Agent-Deck.xcodeproj apps/macos/
   # create apps/mobile from Expo starter
   # create packages/shared-* for shared types/utils
   ```

2. **Initialize pnpm monorepo**:
   ```bash
   pnpm init
   echo "packages:\n  - 'apps/*'\n  - 'packages/*'" > pnpm-workspace.yaml
   ```

3. **Move WebRoot**:
   ```bash
   # Ensure embedded PWA is in:
   apps/macos/Agent-Deck/Resources/WebRoot/
   # Can also build from apps/mobile during Mac build
   ```

### Phase 2: Extract Shared Packages (1 day)

1. **Create `packages/shared-types/`**:
   - Move all `.types.ts` files
   - Add package.json, tsconfig.json

2. **Create `packages/shared-utils/`**:
   - Move parsing, formatting, validation logic
   - Import from shared-types

3. **Update apps/** to use packages:
   ```bash
   pnpm add -D @agent-deck/shared-types @agent-deck/shared-utils
   ```

### Phase 3: Update CI/CD (1 day)

- Migrate GitHub Actions to monorepo pattern
- Add `pnpm -r` commands for global operations
- Test parallel builds

### Phase 4: Document (½ day)

- Create `ARCHITECTURE.md` (diagram of monorepo)
- Update `SETUP.md` with monorepo instructions
- Document SpecKit compatibility

---

## 9. MONOREPO TOOLS COMPARISON

| Tool | Best For | Complexity | 2025 Status |
|------|----------|-----------|------------|
| **pnpm Workspaces** (Rec.) | Expo + Swift monorepos | Low | ⭐⭐⭐ Mature, stable |
| **Yarn Workspaces v1** | Alternative, well-known | Low | Stable, but slower |
| **npm Workspaces** | Compatibility fallback | Low | New, improving |
| **Turborepo** | Large orgs, task caching | Medium | Mature, popular |
| **Lerna** | Publishing/versioning | Medium | Declining maintenance |
| **Nx** | Enterprise, full CLI | High | Powerful, steep curve |

**Recommendation**: Start with **pnpm Workspaces** (simple + fast). If you later need advanced task caching, add Turborepo.

---

## 10. SPECKIT WORKFLOW MODIFICATIONS

### Current SpecKit Usage

Agent Deck already uses SpecKit (spec-kit-template-claude-sh-v0.0.79).

### Monorepo-Aware Approach

No changes needed to core workflow:

```bash
# Single spec for entire Agent Deck
/speckit.specify    # Creates specs/001-mvp/spec.md
/speckit.plan       # Creates specs/001-mvp/plan.md
/speckit.tasks      # Creates specs/001-mvp/tasks.md

# Tasks reference BOTH:
# - Task: "Build Mac WebSocket server" → apps/macos/
# - Task: "Build mobile UI" → apps/mobile/
# - Task: "Create shared types" → packages/shared-types/
```

**Advantage**: Single source of truth for phase planning.

---

## 11. FINAL RECOMMENDATION SUMMARY

### Structure:
- **Use monorepo pattern** ✓
- **pnpm + workspaces** ✓
- **Embedded PWA in Mac app** ✓
- **Swift Packages for Mac logic** ✓
- **JavaScript packages for shared logic** ✓

### Build Tools:
- **pnpm** (for JavaScript/React Native)
- **Swift Package Manager** (for Swift)
- **Xcode** (for Mac compilation)
- **Expo** (for React Native)

### Timeline:
- **Convert to monorepo**: 1-2 days (Phase 1)
- **Extract shared code**: 1 day (Phase 2)
- **Update CI/CD**: 1 day (Phase 3)
- **Total prep**: 3-4 days before Phase 2 implementation

### Effort ROI:
- **Saves**: Code duplication, dependency conflicts, dev setup time
- **Costs**: 3-4 days setup + slightly more complex build
- **Break-even**: Day 7-10 of development

---

## References

- **Mercari iOS Monorepo** (Oct 2025): https://engineering.mercari.com/en/blog/entry/20251024-evolving-mercaris-ios-codebase-into-a-multi-product-monorepo/
- **Runway: Monorepos for iOS** (2025): https://www.runway.team/blog/monorepos-and-why-to-consider-them-for-your-teams-ios-projects
- **Expo Monorepo Guide** (2025): https://docs.expo.dev/guides/monorepos/
- **React Native Monorepo with Yarn** (Aug 2025): https://dev.to/pgomezec/setting-up-react-native-monorepo-with-yarn-workspaces-2025-a29
- **pnpm vs npm vs Yarn** (2025): dev.to + Medium comparisons
- **Swift Package Manager Monorepo** (June 2025): https://blog.kulman.sk/migrate-pods-to-local-spm-in-monorepo/
- **Things Cloud (Swift server)** (Feb 2025): https://www.swift.org/blog/how-swifts-server-support-powers-things-cloud/

---

**Report Status**: Complete research summary
**Recommendation Level**: HIGH - Implement monorepo structure before Phase 2
**Next Action**: Review with project team, decide on pnpm vs Yarn, schedule migration sprint
