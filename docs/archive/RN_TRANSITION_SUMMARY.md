# Agent Deck: React Native Transition Complete Summary

**Date**: 2025-01-08
**Status**: ✅ Constitution Updated, Ready for Spec/Plan/Tasks Updates

---

## What Changed

### Architecture Decision: PWA → React Native

**Old Approach (v1.0)**:
- Progressive Web App (PWA) for mobile in MVP
- Native mobile apps only after 100+ users (Phase 7-8)
- Vanilla JavaScript, no build step
- Browser-based interface

**New Approach (v2.0)**:
- **React Native with Expo for mobile in MVP** (Phase 1-2)
- Native iOS and Android simultaneously
- TypeScript, modern tooling
- Full native app experience
- App store distribution in Phase 3-4 (after validation)

### Why the Change?

**User Requirement**:
> "For an app that is supposed to be minimal friction and total focus, having to navigate to the URL and having the URL UI visible at all times is just not a good implementation. Also, I want to add a few features that will only be possible with a dedicated app to include a 'keep screen awake' ability."

**Key Drivers**:
1. ✅ **Better UX**: Eliminates browser chrome (URL bar, tabs, navigation)
2. ✅ **Native features**: Keep screen awake, proper notifications, full-screen
3. ✅ **Professional feel**: Native app provides credibility for developer tool
4. ✅ **Same timeline**: React Native ≈ PWA development time (no delay)
5. ✅ **Future-proof**: Native app enables Phase 3+ features

---

## Monorepo Structure

### Recommended Layout

```
agent-deck/                          # Root (your current directory)
├── apps/
│   ├── macos/                       # Swift menubar app (moved from Agent-Deck/)
│   │   ├── Agent-Deck.xcodeproj/
│   │   ├── Sources/
│   │   └── Resources/
│   │       └── WebRoot/             # Optional PWA (kept for web access)
│   │
│   └── mobile/                      # NEW: React Native + Expo
│       ├── app.json
│       ├── App.tsx
│       ├── package.json
│       └── src/
│           ├── screens/
│           ├── components/
│           ├── hooks/
│           └── services/
│
├── packages/                        # NEW: Shared JavaScript/TypeScript
│   └── shared-types/                # TypeScript definitions
│       ├── package.json
│       └── src/
│           ├── agent.ts
│           ├── websocket.ts
│           └── config.ts
│
├── .specify/                        # SpecKit (unchanged, root level)
├── pnpm-workspace.yaml              # NEW: pnpm config
├── package.json                     # NEW: Root package.json
├── CLAUDE.md                        # Updated with monorepo patterns
└── README.md                        # Updated with setup instructions
```

### Key Benefits

| Benefit | Impact |
|---------|--------|
| **Code sharing** | TypeScript types shared between Mac + mobile |
| **Single source of truth** | One WebSocket protocol, one data model |
| **Unified CI/CD** | Build both apps from single repo |
| **Faster development** | Shared business logic, consistent patterns |
| **Team onboarding** | Single repo to clone, one setup process |

---

## Documents Updated

### 1. Constitution (✅ COMPLETE)

**File**: `.specify/memory/constitution.md`

**Changes**:
- ✅ Version: 1.0.0 → 2.0.0 (MAJOR)
- ✅ Principle III: "Mobile Validation Strategy" → "Mobile-Native Experience"
- ✅ Updated rationale: Browser chrome unacceptable, native features required
- ✅ Technology Constraints: Added monorepo structure section
- ✅ Timeline: 2 weeks → 2.5 weeks (includes monorepo setup)
- ✅ Phase reorganization: Phase 7-8 (native mobile) → Phase 1-2 (MVP)

**Key Changes**:
```diff
- PWA first, native mobile later (Phase 7+)
+ React Native for mobile in MVP (Phase 1-2)

- Mobile interface MUST be PWA in Phase 1-2
+ Mobile interface MUST be React Native in Phase 1-2

- Native mobile apps MUST NOT be built before 100+ users
+ Mobile app MUST use Expo for zero-config development
+ App store distribution deferred to Phase 3+
```

---

### 2. Migration Plan (✅ COMPLETE)

**File**: `/Users/tonyofthehills/dev/Claude Overseer/AGENT_DECK_RN_MIGRATION_PLAN.md`

**Contents**:
- Executive summary (React Native decision)
- Architecture rationale
- Monorepo structure (apps/, packages/)
- Technology stack (React Native, Expo, pnpm)
- 4-phase implementation timeline (18 days total)
- Build & development workflow
- Risk assessment
- Success criteria

**Timeline Breakdown**:
- Phase 1: Monorepo setup (Day 1-2)
- Phase 2: Extract shared types (Day 3)
- Phase 3: Build React Native app (Day 4-16)
- Phase 4: Documentation & testing (Day 17-18)

---

## Documents Pending Update

### 3. Specification (⚠️ PENDING)

**File**: `specs/001-mvp/spec.md`

**Required Updates**:
- [ ] Update User Story 3 (QR code pairing) for React Native scanner
- [ ] Update mobile requirements (FR-011 through FR-020)
- [ ] Add React Native-specific requirements:
  - [ ] FR-056: Keep screen awake toggle
  - [ ] FR-057: QR code scanner for pairing
  - [ ] FR-058: Expo Go development support
- [ ] Update Key Entities (if mobile-specific models needed)
- [ ] Update Success Criteria (React Native build targets)

**Estimated Time**: 1-2 hours

---

### 4. Implementation Plan (⚠️ PENDING)

**File**: `specs/001-mvp/plan.md`

**Required Updates**:
- [ ] Add Phase 0: Monorepo Setup (4 days)
  - [ ] Reorganize directory structure
  - [ ] Initialize pnpm workspaces
  - [ ] Extract shared types
  - [ ] Update documentation
- [ ] Update Phase 1-2 implementation (mobile development)
  - [ ] Replace PWA tasks with React Native tasks
  - [ ] Add Expo setup steps
  - [ ] Add native feature implementation (keep awake, QR scanner)
- [ ] Update technical approach section
- [ ] Update architecture diagrams

**Estimated Time**: 2-3 hours

---

### 5. Tasks (⚠️ PENDING)

**File**: `specs/001-mvp/tasks.md`

**Required Updates**:
- [ ] Add new tasks for monorepo setup:
  - [ ] Task: Set up pnpm workspaces
  - [ ] Task: Reorganize to apps/ + packages/ structure
  - [ ] Task: Create shared-types package
- [ ] Replace PWA tasks with React Native tasks:
  - [ ] ~~Task: Build PWA with vanilla JavaScript~~
  - [ ] Task: Build React Native app with Expo
  - [ ] Task: Implement AgentListScreen
  - [ ] Task: Implement WebSocket connection hook
  - [ ] Task: Add keep screen awake toggle
  - [ ] Task: Add QR code scanner
- [ ] Update task dependencies

**Estimated Time**: 1 hour

---

### 6. CLAUDE.md (⚠️ PENDING)

**File**: `CLAUDE.md`

**Required Updates**:
- [ ] Update Core Principles section (reflect v2.0 constitution)
- [ ] Update Tech Stack section:
  - [ ] Add React Native 0.73+ (Expo SDK 50+)
  - [ ] Add pnpm for monorepo management
  - [ ] Update mobile section (PWA → React Native)
- [ ] Update File Structure (show monorepo layout)
- [ ] Add React Native development patterns:
  - [ ] Expo setup and configuration
  - [ ] React Native component patterns
  - [ ] WebSocket hook usage
  - [ ] Native module integration (keep awake)
- [ ] Update Common Patterns section
- [ ] Update Testing Strategy (add React Native testing)

**Estimated Time**: 2-3 hours

---

### 7. README.md (⚠️ PENDING)

**File**: `README.md`

**Required Updates**:
- [ ] Update project description (mention React Native)
- [ ] Update Features section (native features)
- [ ] Update Setup instructions:
  - [ ] Add pnpm installation
  - [ ] Add monorepo setup steps
  - [ ] Add Expo Go setup for mobile testing
- [ ] Update Development workflow
- [ ] Update Tech Stack section

**Estimated Time**: 1 hour

---

## Next Steps

### Immediate Actions (Recommended Order)

1. **Review Research Documents** (15 min)
   - Read `/Users/tonyofthehills/dev/Claude Overseer/MONOREPO_RESEARCH_REPORT.md`
   - Review `/Users/tonyofthehills/dev/Claude Overseer/MONOREPO_QUICK_REFERENCE.md`
   - Understand `/Users/tonyofthehills/dev/Claude Overseer/AGENT_DECK_RN_MIGRATION_PLAN.md`

2. **Update Specification** (1-2 hours)
   - Update `specs/001-mvp/spec.md`
   - Add React Native requirements
   - Update user stories for native features

3. **Update Implementation Plan** (2-3 hours)
   - Update `specs/001-mvp/plan.md`
   - Add monorepo setup phase
   - Update mobile development approach

4. **Update Tasks** (1 hour)
   - Update `specs/001-mvp/tasks.md`
   - Add monorepo setup tasks
   - Replace PWA tasks with React Native tasks

5. **Update CLAUDE.md** (2-3 hours)
   - Update `CLAUDE.md`
   - Add monorepo structure
   - Add React Native patterns

6. **Update README** (1 hour)
   - Update `README.md`
   - Add setup instructions for monorepo + Expo

7. **Begin Monorepo Migration** (4 days)
   - Follow migration plan
   - Set up pnpm workspaces
   - Reorganize directories
   - Initialize React Native app

**Total Documentation Time**: ~8-12 hours
**Total Implementation Time**: ~18 days (4 setup + 14 development)

---

## Technical Stack (Updated)

### Before (v1.0)

```yaml
Mac: Swift + SwiftUI
Mobile: PWA (vanilla JavaScript)
Build: None (no build step for PWA)
Shared: None (separate codebases)
```

### After (v2.0)

```yaml
Mac: Swift + SwiftUI
Mobile: React Native 0.73+ (Expo SDK 50+, TypeScript)
Build: pnpm + Expo
Shared: TypeScript types via pnpm packages
Monorepo: pnpm workspaces
```

---

## PWA Status

**Decision**: Keep embedded PWA as optional web interface

**Rationale**:
- Already built (no removal cost)
- Provides web access for desktop browsers
- Useful for tablets (iPad, Android tablets)
- Same WebSocket protocol as React Native
- Low maintenance (static files)

**Priority**: Low (React Native is primary mobile interface)

---

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|-----------|
| **Learning curve (React Native)** | Low | Expo simplifies RN, TypeScript familiar, simple UI |
| **Monorepo setup complexity** | Medium | Follow research guide, use proven patterns (byCedric) |
| **Timeline delay** | Low | RN time ≈ PWA time, monorepo adds 4 days (acceptable) |
| **Build size concerns** | Low | Expo tree-shaking, simple app, minimal dependencies |

**Overall Risk**: LOW

---

## Questions & Decisions

### Confirmed Decisions

✅ Use React Native for mobile (not PWA)
✅ Use Expo for zero-config development
✅ Use pnpm for monorepo management
✅ Keep embedded PWA as optional web interface
✅ Target iOS 15+ and Android 8+
✅ Defer app store distribution to Phase 3-4

### Open Questions

❓ Should we implement QR code scanner natively or use Expo's barcode scanner?
   → **Recommendation**: Use `expo-barcode-scanner` (zero-config, works out of box)

❓ Should we keep existing PWA code or remove it during migration?
   → **Recommendation**: Keep for now, deprecate in Phase 3 if unused

❓ Should we use TypeScript or JavaScript for React Native?
   → **Recommendation**: TypeScript (better type safety, shared types package)

---

## Success Criteria

### Monorepo Migration Complete When:
- ✅ pnpm install works without errors
- ✅ Swift app builds from `apps/macos/`
- ✅ Expo app runs from `apps/mobile/`
- ✅ Shared types package imports successfully
- ✅ SpecKit commands work from root

### React Native MVP Complete When:
- ✅ Mobile app connects to Mac WebSocket
- ✅ Agent instances display with real-time updates (<500ms)
- ✅ Tap to focus window works (<1s latency)
- ✅ Custom actions execute successfully
- ✅ QR code scanner works for pairing
- ✅ Keep screen awake toggle works
- ✅ Works on iOS 15+ and Android 8+

---

## Resources Created

**All documents in**: `/Users/tonyofthehills/dev/Claude Overseer/`

1. **MONOREPO_RESEARCH_REPORT.md** (686 lines)
   - Comprehensive technical analysis
   - Real-world validation
   - Build tool comparisons
   - Directory structure diagrams

2. **MONOREPO_QUICK_REFERENCE.md** (216 lines)
   - One-page decision guide
   - Copyable directory structure
   - Common mistakes to avoid
   - Build commands reference

3. **RESEARCH_SUMMARY.txt** (227 lines)
   - Executive summary
   - Key findings
   - Timeline and ROI

4. **AGENT_DECK_RN_MIGRATION_PLAN.md** (this document's companion)
   - Detailed 18-day implementation plan
   - Phase-by-phase breakdown
   - Risk assessment

5. **AGENT_DECK_RN_TRANSITION_SUMMARY.md** (this document)
   - What changed and why
   - Documents updated
   - Next steps

---

## Timeline

```
Week 1 (Day 1-7):
- Day 1-2: Monorepo setup (pnpm, directory restructure)
- Day 3: Extract shared types
- Day 4-7: Begin React Native app (WebSocket, agent list)

Week 2 (Day 8-14):
- Day 8-11: Core features (tap to focus, real-time updates)
- Day 12-14: Custom actions, QR scanner, keep awake

Week 3 (Day 15-18):
- Day 15-16: Polish, error handling, testing
- Day 17-18: Documentation updates, final QA

Total: 18 days (~2.5 weeks)
```

---

## Approval Required

Before proceeding with monorepo migration and React Native development:

- [ ] Review constitution changes (v1.0 → v2.0)
- [ ] Approve React Native as mobile platform
- [ ] Approve pnpm as monorepo tool
- [ ] Approve 2.5-week timeline (0.5 weeks added for monorepo)
- [ ] Approve keeping embedded PWA as optional
- [ ] Approve Expo for React Native development

**Once approved**, proceed with updating spec, plan, and tasks.

---

**Status**: ✅ Constitution updated, ready for spec/plan/tasks updates
**Created**: 2025-01-08
**Author**: Claude Code (Overseer Agent)
