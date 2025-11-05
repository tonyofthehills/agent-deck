# Implementation Plan Corrections

**Date**: 2025-01-02
**Status**: Critical fixes to align spec, plan, and tasks

## Overview

This document addresses four critical inconsistencies identified in the planning artifacts that could cause implementation thrash. All corrections align with the constitution and maintain the 2-week MVP timeline.

---

## Correction 1: Toolchain Clarification (Swift-Only, No Node.js)

### Problem

**Conflict between documents**:
- `agent-deck-spec-final.md:100-103` suggests "Use Node.js `ps-list` or `ps-node` for process enumeration"
- `agent-deck-spec-final.md:1590` states "**No Node.js** - everything in Swift (cleaner for users)"
- Constitution requires "Single .app bundle (no Node.js runtime required)"
- `tasks.md` already uses Swift NSWorkspace (correct)

### Resolution

**Definitive Answer: Swift-Only, No Node.js**

**Rationale**:
- Constitution Principle II (Mac-First Architecture): "Single .app bundle (no runtime dependencies)"
- Constitution Principle II: "No web wrappers or cross-platform frameworks for Mac app"
- agent-deck-spec-final.md:1590 is the correct guidance (later in doc, more specific)
- Requiring users to install Node.js violates "zero setup" success criterion

**Implementation Stack (FINAL)**:
- Process monitoring: `NSWorkspace.shared.runningApplications` (Swift AppKit)
- WebSocket server: Swift `Network.framework` or Vapor framework (Swift)
- HTTP server: Swift `Network.framework` or Vapor framework (Swift)
- Configuration: Yams library (Swift, YAML parsing)
- All services: Pure Swift, no Node.js dependencies

**Action Items**:
- ✅ tasks.md already correct (uses Swift NSWorkspace)
- ✅ plan.md already correct (Swift-only stack)
- ✅ research.md already correct (NSWorkspace decision)
- ⚠️ agent-deck-spec-final.md needs update (remove Node.js references in lines 100-103)

**Note**: agent-deck-spec-final.md is the original brainstorming document. The derived artifacts (spec.md, plan.md, tasks.md) have the correct Swift-only approach and should be considered authoritative.

---

## Correction 2: Latency Requirement vs Polling Interval

### Problem

**Mathematical impossibility**:
- Requirement: Status updates must appear within <500ms (SC-001, agent-deck-spec-final.md:891)
- Proposed polling: Every 1-2 seconds (agent-deck-spec-final.md:101, research.md:62)
- **Conflict**: Polling every 2 seconds cannot deliver <500ms latency

**Latency Breakdown**:
```
Poll interval: 2 seconds
Processing time: ~50ms
Broadcast time: ~50ms
Network latency: ~50ms
------------------------
Worst-case total: 2150ms (fails <500ms requirement by 4.3x)
```

### Resolution

**Tighten polling interval to 500ms**

**Revised Latency Calculation**:
```
Poll interval: 500ms
Processing time: ~50ms
Broadcast time: ~50ms
Network latency: ~50ms
------------------------
Worst-case total: 650ms

Best-case: ~100-200ms (status change happens just after poll)
Average-case: ~350-400ms (meets <500ms requirement)
Worst-case: ~650ms (slightly over, but acceptable for MVP)
```

**CPU Impact Analysis**:
- Polling frequency: 2 polls/second (500ms interval)
- NSWorkspace enumeration time: ~1-2ms per poll
- Total CPU overhead: ~4ms/second = 0.4% CPU
- Well under <2% idle / <5% active targets (SC-004)

**Rationale**:
- Meets <500ms latency requirement in average case
- Acceptable worst-case overage (~150ms) for MVP
- Minimal CPU impact (0.4%)
- Simple polling approach (no complex event handling)
- Aligns with "Functionality over polish" (developer audience)

**Alternative Considered (Rejected for MVP)**:
- Event-driven monitoring (FSEvents, Launch Services): Too complex for 2-week timeline

**Updates Required**:
- ✅ Update research.md Decision 2: "polling every 500ms" (not 1-2s)
- ✅ Update plan.md: "poll for process changes every 500ms" (not 1-2s)
- ✅ Update tasks.md T019: "Implement polling timer (every 500ms)" (not 1-2s)
- ✅ Update spec.md FR-024 if it mentions specific interval

---

## Correction 3: Output Parsing in MVP Scope

### Problem

**Inconsistent requirements**:
- agent-deck-spec-final.md:899 (Success Criteria Phase 1-2): "✅ Basic output parsing (current task) works"
- agent-deck-spec-final.md:90-103: Detailed parsing requirements in Core Requirements
- spec.md User Story 4: "View Parsed Agent Output (Priority: P2)"
- tasks.md: Parsing deferred to Phase 6 (User Story 4, P2)

**What is "basic parsing"?**
- Full parsing (3 sections): current task + todo list + status line → P2 (Phase 6)
- Basic parsing (1 section): current task only → Should be P1 (MVP)

### Resolution

**Basic parsing (current task only) is part of MVP (User Story 1)**

**Rationale**:
- Success criteria explicitly require it for Phase 1-2 (agent-deck-spec-final.md:899)
- FR-021 to FR-023 are in core functional requirements (not marked optional)
- "Current task" provides critical context for monitoring (aligns with User Story 1 goal)
- Simple regex parsing: low complexity, fits 2-week timeline
- Advanced parsing (todo list, status line) remains P2

**Scope Clarification**:

**Phase 1-2 MVP (P1)** - User Story 1 includes basic parsing:
- ✅ Parse "Currently:" line from Claude Code stdout
- ✅ Display current task in PWA UI
- ✅ Handle unparseable output gracefully ("Unknown")
- ❌ Todo list parsing (deferred to P2)
- ❌ Status line parsing (deferred to P2)

**Phase 3+ (P2)** - User Story 4 adds advanced parsing:
- ✅ Todo list extraction (markdown checkboxes)
- ✅ Status line extraction
- ✅ Multi-line todo items
- ✅ Completion status tracking
- ✅ Independent toggling of sections

**Updates Required**:
- ✅ Reorganize tasks.md: Move T064-T067 (basic parsing) from Phase 6 (US4) to Phase 3 (US1)
- ✅ Update User Story 1 description in tasks.md to include "with basic task parsing"
- ✅ Update User Story 4 description to "Advanced Parsed Output" (todo + status)
- ✅ Keep spec.md User Story 4 as P2 (advanced features), but note basic parsing in US1

**Task Reorg Summary**:
- T064-T067: OutputParser with "Currently:" regex → Move to User Story 1 (Phase 3)
- T068-T073: Advanced features (toggle, truncate, localStorage) → Keep in User Story 4 (Phase 6)

---

## Correction 4: Testing Strategy for Quality Guarantees

### Problem

**Insufficient testing for ambitious guarantees**:
- tasks.md Phase 9: "Manual testing only" (explicit per constitution)
- Success criteria promise:
  - <500ms latency (SC-001)
  - <1s window switching (SC-002)
  - Multi-device compatibility (iOS Safari 14+, Chrome 90+, Android)
  - 24-hour stability (SC-012)
- Constitution allows "Manual testing acceptable in Phase 1-2"
- Risk: Manual testing alone may miss regressions, fail to validate latency claims

### Resolution

**Add lightweight repeatable smoke tests (not full automation)**

**Test Strategy**:
1. **Manual exploratory testing** (primary) - Constitution-compliant
2. **Lightweight smoke test scripts** (secondary) - Validate claims
3. **No unit test framework** (deferred to Phase 3+) - Per constitution

**Smoke Test Scripts (Bash/Python, not XCTest)**:

**Script 1: Latency Validation** (`test-latency.sh`)
```bash
# Simulates status changes, measures time to PWA update
# Logs timestamps: status change → mobile UI update
# Outputs: min/max/avg latency, pass/fail vs 500ms threshold
```

**Script 2: Multi-Device Check** (`test-devices.sh`)
```bash
# Opens PWA URLs on multiple browsers via Browserstack or manual testing
# Checklist: iOS Safari 14+, Chrome 90+, Android Chrome
# Validates: connection, status display, tap response
```

**Script 3: Stability Test** (`test-stability.sh`)
```bash
# Runs Mac app for 24 hours, monitors memory/CPU
# Logs resource usage every 5 minutes
# Outputs: memory growth, CPU spikes, crashes
```

**Script 4: Window Switching Performance** (`test-window-switch.sh`)
```bash
# Sends focus commands via wscat, measures Mac window response time
# Logs: command sent → window frontmost
# Outputs: min/max/avg latency, pass/fail vs 1s threshold
```

**Why This Approach**:
- Scripts are repeatable (can run before each demo/release)
- Validates latency and compatibility claims
- Doesn't require XCTest framework (constitution allows manual testing)
- Fits "Functionality over polish" (simple bash scripts, not formal test suite)
- Takes ~1-2 hours to write (fits Day 14 timeline)

**Updates Required**:
- ✅ Add T118.1-T118.4 to tasks.md Phase 9: Create smoke test scripts
- ✅ Update Phase 9 description: "Manual testing + smoke test scripts for validation"
- ✅ Add scripts/ directory to project structure in plan.md

---

## Summary of Changes

### Documents Updated

1. **research.md**:
   - Decision 2: Update polling interval to 500ms
   - Add Node.js alternative (rejected) to Decision 2 table
   - Add latency calculation justifying 500ms polling

2. **plan.md**:
   - Update polling interval references (1-2s → 500ms)
   - Clarify "basic parsing" in User Story 1 scope
   - Add smoke test scripts to Risk Mitigation table

3. **tasks.md** (MAJOR REORG):
   - Move T064-T067 (OutputParser) from Phase 6 to Phase 3 (User Story 1)
   - Update T019: "polling timer (every 500ms)" not "1-2 seconds"
   - Renumber tasks after reorganization
   - Add T118.1-T118.4: Smoke test scripts
   - Update User Story 1 goal to include "with basic task parsing"
   - Update User Story 4 to "Advanced Parsed Output (Todo + Status)"

4. **spec.md**:
   - Update FR-024 if it specifies polling interval
   - Add note to User Story 1 that basic parsing is included
   - Clarify User Story 4 is "advanced parsing" only

### Constitutional Compliance

All corrections maintain constitutional compliance:
- ✅ **Speed to Market**: 2-week timeline preserved, no scope creep
- ✅ **Mac-First**: Swift-only approach (no Node.js)
- ✅ **Developer Audience**: Manual testing acceptable, smoke scripts added for validation
- ✅ **Functionality over Polish**: Simple polling approach, basic parsing sufficient

### Impact on Timeline

**No timeline impact**:
- Moving basic parsing to US1: ~2 hours work (already budgeted in Phase 3)
- 500ms polling: No change (same implementation, different Timer interval)
- Smoke test scripts: 1-2 hours on Day 14 (already in integration testing budget)
- Total: 2-week timeline maintained

---

## Action Items

**High Priority** (before implementation starts):
- [ ] Update tasks.md with reorganized parsing tasks (T064-T067 → Phase 3)
- [ ] Update tasks.md T019 polling interval (500ms)
- [ ] Add smoke test tasks (T118.1-T118.4)
- [ ] Update plan.md polling references

**Medium Priority** (before Week 2):
- [ ] Update research.md Decision 2 with 500ms polling + latency math
- [ ] Add Node.js rejection rationale to research.md

**Low Priority** (nice to have):
- [ ] Update agent-deck-spec-final.md to remove Node.js references (lines 100-103)
- [ ] Add CORRECTIONS.md reference to plan.md

**Not Required** (original spec is reference only):
- agent-deck-spec-final.md corrections (derived artifacts are authoritative)

---

## Validation Checklist

Before starting implementation, confirm:
- [ ] All team members aware of Swift-only toolchain (no Node.js)
- [ ] Polling interval set to 500ms in code (Timer.publish(every: 0.5))
- [ ] Basic parsing (current task) included in User Story 1 scope
- [ ] Smoke test scripts planned for Day 14
- [ ] Latency expectations realistic (<500ms average, not guaranteed)

---

**Corrections Version**: 1.0
**Date**: 2025-01-02
**Approved By**: Implementation planning team
