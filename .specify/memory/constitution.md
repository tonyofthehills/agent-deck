<!--
Sync Impact Report:
- Version change: none → 1.0.0
- Modified principles: N/A (initial creation)
- Added sections: All (initial creation from CLAUDE.md principles)
- Removed sections: None
- Templates requiring updates:
  ✅ spec-template.md - reviewed, no changes needed (constitution-agnostic template)
  ✅ plan-template.md - reviewed, constitution check section already present
  ✅ tasks-template.md - reviewed, no changes needed (constitution-agnostic template)
  ✅ All command files - reviewed, generic agent references verified
- Follow-up TODOs: None
-->

# Agent Deck Constitution

## Core Principles

### I. Speed to Market

**2-week MVP over perfection.** Ship Phase 1-2 in 2 weeks, no scope creep. Iterate based on user feedback. "Done is better than perfect" for MVP.

**Rationale**: Market timing is critical. The agentic coding wave (Cursor 2.0, Claude Code expansion) creates a narrow launch window. Early validation prevents wasted effort on features users don't want.

**Non-negotiable rules**:
- Phase 1-2 MUST ship within 2 weeks
- No scope additions to MVP without removing equal scope
- Working features over UI perfection in MVP
- User feedback drives post-MVP roadmap

---

### II. Mac-First Architecture

**Native Swift menubar app is the core product.** Professional macOS integration (menubar, AppleScript, NSWorkspace). No Electron, no web wrappers for Mac app. Single .app bundle (no Node.js dependency for users).

**Rationale**: Developer tools demand professional native feel. Mac users expect menubar apps, system integration, and lightweight background operation. Electron apps carry stigma in dev tools market.

**Non-negotiable rules**:
- Mac app MUST be native Swift/SwiftUI
- Mac app MUST integrate with macOS (menubar, AppleScript, NSWorkspace)
- Mac app MUST be single .app bundle (no runtime dependencies)
- No web wrappers or cross-platform frameworks for Mac app

---

### III. Mobile Validation Strategy

**PWA first, native mobile later.** Works on ALL devices immediately (universal access). No app store delays (iterate daily). Build native iOS/Android only if 100+ users demand it (Phase 7+).

**Rationale**: Native mobile apps require 3-4 weeks before validation. PWA ships in 3 days, works everywhere, enables rapid iteration. Build what users validate, not what we assume they need.

**Non-negotiable rules**:
- Mobile interface MUST be PWA in Phase 1-2
- PWA MUST work on iOS Safari, Chrome, Android browsers
- PWA MUST be installable ("Add to Home Screen")
- Native mobile apps MUST NOT be built before 100+ active users
- Native mobile MUST NOT be built before user survey validates PWA limitations
- Decision to build native MUST be data-driven, not assumption-driven

---

### IV. Local-First

**No cloud dependencies in Phase 1-6.** Local network only (same WiFi). No authentication initially. No external APIs (except monitoring agents).

**Rationale**: Cloud infrastructure adds complexity, cost, and privacy concerns. Local-first enables zero-config setup, offline operation, and complete user control.

**Non-negotiable rules**:
- Phase 1-6 MUST operate on local network only
- No cloud services required for core functionality
- No authentication layer in Phase 1-2
- No external API dependencies (except agent monitoring)
- Configuration MUST be local files (YAML)

---

### V. Developer Audience

**Functionality over polish.** Prioritize working features over UI perfection. Developers understand technical limitations. Document clearly, don't over-abstract.

**Rationale**: Developer users value utility over aesthetics. They can work around rough edges if functionality is solid. Clear documentation beats abstraction layers.

**Non-negotiable rules**:
- Working features MUST ship before UI polish
- Technical limitations MUST be documented, not hidden
- Error messages MUST be actionable and clear
- Configuration MUST be text-based (YAML), not hidden in UI
- Manual testing acceptable in Phase 1-2 (automated tests in Phase 3+)

---

## Development Workflow

### SpecKit Integration (Mandatory)

This project uses SpecKit for spec-driven development. All feature work MUST follow the SpecKit workflow:

1. `/speckit.constitution` - Define/update principles (this file)
2. `/speckit.specify` - Create feature specification
3. `/speckit.plan` - Generate implementation plan
4. `/speckit.tasks` - Break into executable tasks
5. `/speckit.implement` - Execute implementation

**Rationale**: Prevents AI drift during rapid development, maintains consistency across Mac/PWA codebases, documents architecture for future phases.

---

### MCP Server Usage

Developers MUST utilize MCP servers strategically:

- **Exa Search**: Current information, troubleshooting, best practices
- **Ref**: Exploratory documentation, API discovery
- **Context7**: Deep library documentation dives
- **Pieces**: Historical context, breakthrough documentation

See CLAUDE.md MCP Server Integration section for detailed guidance.

---

### Session Protocols

Every development session MUST:

1. Check documentation at session start (understand current sprint, tasks, dependencies)
2. Update task checkboxes when completing work (mark [ ] as [x])
3. Report progress at session end
4. Add lessons learned to LESSONS_LEARNED.md after unexpected issues
5. Use subagents for implementation following Claude Code best practices

**Rationale**: Maintains continuity across sessions, prevents rework, builds institutional knowledge.

---

## Technology Constraints

### Phase 1-2 (MVP - 2 Weeks)

**Mac Application**:
- Platform: macOS 12+ (Monterey or later)
- Language: Swift 5.7+ (Swift 6 compatible)
- UI: SwiftUI (native macOS look and feel)
- Frameworks: Combine, Network.framework (or Vapor), NSWorkspace, NSAppleScript
- Distribution: Single .app bundle
- Permissions: Accessibility access for window switching
- Performance: <100MB RAM, <2% CPU idle, <5% CPU active

**Mobile Interface (PWA)**:
- Type: Progressive Web App (vanilla JavaScript, NO build step)
- Browsers: iOS Safari 14+, Chrome 90+, Firefox 90+
- Network: Same WiFi/local network as Mac
- Offline: Service Worker for basic offline functionality
- Performance: <100ms tap response, <500ms WebSocket latency

**Backend**:
- Embedded in Mac app (no separate server process)
- WebSocket server: Swift Network.framework or Vapor
- HTTP server: Serves PWA files from Resources/WebRoot/

### Phase 7+ (Native Mobile - After Validation)

**Triggers for building native mobile apps**:
- 100+ active users on PWA
- User feedback explicitly requests native features
- User survey validates PWA limitations blocking adoption
- Validated product-market fit
- Revenue to support native development costs

**iOS Native App (Phase 7)**:
- Platform: iOS 15+
- Language: Swift (shared with Mac app)
- Framework: SwiftUI
- Distribution: App Store only

**Android Native App (Phase 8)**:
- Platform: Android 8+ (API 26+)
- Language: Kotlin or JavaScript (React Native)
- Distribution: Google Play Store

---

## Governance

### Constitution Authority

This constitution supersedes all other development practices, patterns, or preferences. When conflicts arise, constitution principles win.

---

### Amendment Process

1. Proposed changes MUST be discussed with project stakeholders
2. Changes MUST include rationale and impact analysis
3. Version MUST increment according to semantic versioning:
   - **MAJOR**: Backward incompatible governance/principle removals or redefinitions
   - **MINOR**: New principle/section added or materially expanded guidance
   - **PATCH**: Clarifications, wording, typo fixes, non-semantic refinements
4. All dependent templates MUST be updated for consistency
5. Sync Impact Report MUST be prepended to constitution file

---

### Compliance Review

All code reviews, design reviews, and implementation reviews MUST verify compliance with this constitution.

Violations MUST be justified in writing with:
- Why the violation is necessary
- What simpler constitutional approach was rejected
- Why the rejected approach is insufficient

Unjustified violations MUST be rejected.

---

### Runtime Development Guidance

For day-to-day development practices, coding patterns, and operational guidance not covered by this constitution, refer to `CLAUDE.md` in the project root.

The constitution defines **what** we build and **why**. CLAUDE.md defines **how** we build it.

---

**Version**: 1.0.0
**Ratified**: 2025-01-02
**Last Amended**: 2025-01-02
