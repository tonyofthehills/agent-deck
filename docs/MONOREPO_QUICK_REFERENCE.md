# Monorepo Quick Reference - Agent Deck
## One-page decision guide

### RECOMMENDATION: YES, use monorepo with pnpm

| Aspect | Decision | Why |
|--------|----------|-----|
| **Use monorepo?** | YES | Code sharing, single source of truth, easier CI/CD |
| **Package manager** | pnpm | Fastest, most efficient, best monorepo support in 2025 |
| **Architecture** | Embedded PWA | Same files in mobile app AND Mac app |
| **Swift code** | Swift Packages | Use Modules/ directory with local SPM packages |
| **Shared JS** | pnpm workspaces | business logic, types, utilities |

---

## Directory Structure (Copy This)

```
agent-deck/
├── apps/
│   ├── macos/                    # Swift menubar app
│   │   ├── Agent-Deck.xcodeproj/
│   │   ├── Sources/
│   │   └── Resources/WebRoot/    # ← Embedded PWA (same as mobile)
│   └── mobile/                   # React Native + Expo
│       └── package.json
├── packages/                     # Shared JS/TS only
│   ├── shared-types/
│   ├── shared-utils/
│   └── shared-config/
├── pnpm-workspace.yaml          # ← Add this
├── package.json                 # Root config
└── .specify/                    # SpecKit (root level OK)
```

---

## Setup Timeline

| Phase | Task | Time | Pre-req |
|-------|------|------|---------|
| 1 | Reorganize files to structure above | 1-2d | None |
| 2 | Initialize pnpm, create package.json files | 1d | Phase 1 |
| 3 | Extract shared packages | 1d | Phase 2 |
| 4 | Update CI/CD for monorepo | 1d | Phase 3 |
| **Total** | **Ready to implement Phase 2** | **4 days** | |

---

## pnpm vs Alternatives (2025)

| Metric | pnpm | Yarn | npm |
|--------|------|------|-----|
| Speed | ⭐⭐⭐ Fastest | ⭐⭐ Fast | ⭐ Moderate |
| Disk usage | ⭐⭐⭐ Minimal | ⭐⭐ Good | ⭐ Wasteful |
| Monorepo support | ⭐⭐⭐ Best | ⭐⭐ Good | ⭐ New |
| Expo compatibility | ⭐⭐⭐ Full (SDK 52+) | ⭐⭐⭐ Full | ⭐⭐⭐ Full |

**Why pnpm?**
- Native monorepo support (no extra config needed)
- ~80% less disk space via hard linking
- Faster installs and better caching
- Strict dependency checking (prevents bugs)

---

## Key Code Patterns

### pnpm Workspace Config

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
  "devDependencies": {
    "typescript": "^5.3.0"
  }
}
```

### Cross-Package Dependency

```json
// apps/mobile/package.json
{
  "name": "@agent-deck/mobile",
  "dependencies": {
    "@agent-deck/shared-types": "workspace:*",
    "react-native": "0.73.0"
  }
}
```

### Swift Package Reference

```swift
// apps/macos/Package.swift
.package(path: "../../Modules/AgentMonitoring")
```

---

## What CAN Share vs CANNOT Share

| Type | Shareable? | How |
|------|-----------|-----|
| **TypeScript types** | ✓ YES | pnpm packages |
| **Business logic (JS)** | ✓ YES | pnpm packages |
| **UI components (RN)** | ✓ MAYBE | react-native-web (Phase 5+) |
| **Swift code** | ✗ NO | Each app writes separately |
| **Icons/colors** | ✓ YES | JSON + import in JS |

---

## Common Mistakes to Avoid

1. ❌ Using `nohoist` → Breaks monorepo benefits
   - ✓ Solution: Don't use it (pnpm default is fine)

2. ❌ Swift code in packages/ → Won't work in JavaScript
   - ✓ Solution: Keep Swift local, use pnpm packages for JS

3. ❌ Circular dependencies (mac → mobile) → Build fails
   - ✓ Solution: Only packages/ shared between apps

4. ❌ Forgetting `workspace:*` protocol → Version mismatches
   - ✓ Solution: Use `workspace:*` for all local package refs

5. ❌ Not hoisting → Duplicate node_modules
   - ✓ Solution: pnpm hoists by default ✓

---

## Build Commands (Once Monorepo Ready)

```bash
# Install all dependencies
pnpm install

# Install in specific package
pnpm -F @agent-deck/mobile install

# Run tests for all
pnpm -r test

# Build only mobile
pnpm -F @agent-deck/mobile build

# Watch mode for development
pnpm -F @agent-deck/mobile --watch

# Clean rebuild
pnpm -r --recursive clean && pnpm install
```

---

## PWA + React Native Strategy

**Single PWA served 3 ways:**

1. **Browser** → Visit `http://localhost:3000` (dev)
2. **Mobile** → Expo run (development) or built app
3. **Mac** → Embedded in Swift app (`Resources/WebRoot/`)

**Advantage**: No code duplication, all three get same updates

---

## SpecKit Compatibility

✓ Fully compatible. No changes needed:

```bash
/speckit.specify      # Still creates ONE spec
/speckit.plan         # Still ONE plan
/speckit.tasks        # Still ONE task list (references both apps/)
```

---

## Next Action Checklist

- [ ] Review this doc with team
- [ ] Decide: pnpm or Yarn? (recommend pnpm)
- [ ] Schedule 4-day restructuring sprint
- [ ] Back up current repo before changes
- [ ] Set up test environment for monorepo config
- [ ] Update CI/CD workflows
- [ ] Update CLAUDE.md with monorepo instructions
- [ ] Update README with setup guide

---

## Real-World Validation

✓ Mercari Global App (Oct 2025) - Multi-product iOS monorepo  
✓ byCedric/expo-monorepo-example (900+ GitHub stars) - Expo monorepo  
✓ Matera PropTech (Feb 2025) - React + React Native monorepo  
✓ Twitter (2020s) - Created react-native-web in monorepo  

**Conclusion**: This pattern is production-proven across teams of all sizes.

---

**Recommendation**: PROCEED with monorepo architecture.  
**Timeline**: Start after Phase 1 approval, before Phase 2 implementation.  
**Expected ROI**: 3-4 days setup saves 1-2 weeks of development time.
