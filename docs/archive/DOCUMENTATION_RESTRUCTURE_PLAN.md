# Documentation Restructure Plan

**Goal**: Reduce CLAUDE.md from 63KB to ~20KB by extracting content into focused, topic-specific guides.

**Current State**: CLAUDE.md is 1,200+ lines and serves as both a quick reference and comprehensive guide, making it hard to navigate.

---

## Extraction Strategy

### 1. MCP_INTEGRATION.md (Extract ~300 lines)
**Content to extract:**
- Available MCP Servers (Exa, Ref, Context7, Perplexity, Pieces, Semgrep, etc.)
- When to use each MCP server
- Best practices for MCP usage
- Workspace-level MCP guidance
- Quick reference table

**Keep in CLAUDE.md:**
- Brief overview: "This project uses MCP servers - see MCP_INTEGRATION.md"
- Link to full MCP guide
- Critical reminder about using subagents for MCP operations

**Estimated reduction**: 300 lines (~15KB)

---

### 2. SECURITY.md (Extract ~250 lines)
**Content to extract:**
- Security Scanning with Semgrep MCP (full section)
- When to scan (critical scenarios)
- How to scan (Swift, React Native, supply chain)
- Priority vulnerabilities by platform
- Secure AI coding workflow
- Security severity guidelines
- Custom rule development

**Keep in CLAUDE.md:**
- Brief note: "ALWAYS scan AI-generated code - see SECURITY.md"
- Link to security guide

**Estimated reduction**: 250 lines (~12KB)

---

### 3. REACT_NATIVE_GUIDE.md (Extract ~350 lines)
**Content to extract:**
- Expo project structure
- Creating screens and components (with code examples)
- useWebSocket hook pattern
- Keep screen awake implementation
- QR scanner implementation
- AsyncStorage for persistence
- Navigation with @react-navigation
- Theme and dark mode
- All React Native code examples

**Keep in CLAUDE.md:**
- Tech stack overview
- Brief mention: "See REACT_NATIVE_GUIDE.md for patterns and examples"
- Link to guide

**Estimated reduction**: 350 lines (~18KB)

---

### 4. SWIFT_GUIDE.md (Extract ~200 lines)
**Content to extract:**
- SwiftUI patterns (menubar app, state management)
- Process monitoring
- WebSocket server implementation
- AppleScript patterns (window switching, app launching)
- QR code generation
- Bonjour/mDNS service discovery
- Error handling patterns
- Logging patterns

**Keep in CLAUDE.md:**
- Tech stack overview
- Brief mention: "See SWIFT_GUIDE.md for Swift patterns"
- Link to guide

**Estimated reduction**: 200 lines (~10KB)

---

### 5. QUICK_START.md (New file)
**Content to create:**
- First-time setup (pnpm install, open Xcode)
- Running the Mac app
- Running the mobile app
- Testing WebSocket connection
- Common commands (from "Quick Reference Commands" section)
- Troubleshooting common issues

**Keep in CLAUDE.md:**
- Link to quick start at top of file

**Estimated reduction**: 50 lines (~2KB) by consolidating scattered setup instructions

---

### 6. CONFIGURATION.md (Extract ~100 lines)
**Content to extract:**
- Configuration Management section
- YAML config files
- Loading config in Swift
- Environment variables
- Configuration schema

**Keep in CLAUDE.md:**
- Brief mention of configuration approach

**Estimated reduction**: 100 lines (~5KB)

---

### 7. Update Existing Docs

**TESTING_GUIDE.md** (already exists)
- Verify it covers Phase 0-2 testing checklist from CLAUDE.md
- Add Expo Go testing section if missing

**TROUBLESHOOTING.md** (create new)
- Extract "Common Pitfalls & How to Avoid" section
- Extract lessons from LESSONS_LEARNED.md summary
- Add common error messages and solutions

---

## Revised CLAUDE.md Structure (Target: ~20KB)

```markdown
# CLAUDE.md - Agent Deck

## Quick Links
- 🚀 [Quick Start Guide](./QUICK_START.md)
- 🔌 [MCP Integration](./MCP_INTEGRATION.md)
- 🔒 [Security Guide](./SECURITY.md)
- ⚛️ [React Native Guide](./REACT_NATIVE_GUIDE.md)
- 🍎 [Swift Guide](./SWIFT_GUIDE.md)
- ⚙️ [Configuration](./CONFIGURATION.md)
- 🧪 [Testing Guide](./TESTING_GUIDE.md)
- 🐛 [Troubleshooting](./TROUBLESHOOTING.md)

## Project Overview
[Keep: Brief overview, platform strategy, timeline]

## Core Principles (Constitution)
[Keep: All 5 principles - essential for every session]

## YOU ARE ENCOURAGED TO / NEVER / ALWAYS
[Keep: Critical behavioral guidelines]

## MCP Server Integration
**This project uses MCP servers - see [MCP_INTEGRATION.md](./MCP_INTEGRATION.md) for details.**

⚠️ CRITICAL: Always use subagents (Task tool) for MCP research/exploration tasks!
[Brief 3-4 sentence overview, link to full guide]

## Security Scanning
**CRITICAL: Always scan AI-generated code - see [SECURITY.md](./SECURITY.md).**
[Brief 2-3 sentence overview, link to security guide]

## SpecKit Integration
[Keep: Full section - workflow is essential]

## Tech Stack
[Keep: Brief overview of macOS, Mobile, Monorepo tools]
[Link to REACT_NATIVE_GUIDE.md and SWIFT_GUIDE.md for details]

## File Structure (Monorepo)
[Keep: Tree structure - critical for navigation]

## Monorepo Development
[Keep: Package manager basics, workspace commands]
[Move detailed patterns to respective guides]

## Development Constraints
[Keep: Phase focus, performance targets, security constraints]

## Common Patterns & Best Practices
[Keep: Brief overview]
[Link to SWIFT_GUIDE.md and REACT_NATIVE_GUIDE.md for details]

## Testing Strategy
[Keep: Brief overview]
[Link to TESTING_GUIDE.md for full details]

## Configuration Management
[Keep: Brief overview]
[Link to CONFIGURATION.md for full details]

## Lessons Learned
[Keep: Summary only - link to LESSONS_LEARNED.md]

## Quick Reference Commands
[Move to QUICK_START.md]
[Keep: 5-10 most critical commands only]

## Version
[Keep: Version tracking]

## Active Technologies
[Keep: List of technologies]

## Recent Changes
[Keep: Last 5 changes only]
```

---

## Estimated Impact

| Current CLAUDE.md | After Restructure | Reduction |
|-------------------|-------------------|-----------|
| 63KB (1,200+ lines) | ~20KB (~400 lines) | **68% smaller** |

**Benefits:**
1. ✅ Easier to navigate (clear topic separation)
2. ✅ Faster to load in context window
3. ✅ Each guide can be read independently
4. ✅ Easier to maintain (update one guide without touching others)
5. ✅ Better discoverability (Quick Links section at top)

**Risks:**
1. ⚠️ Need to maintain links between documents
2. ⚠️ Must keep CLAUDE.md as "hub" with essential info
3. ⚠️ Risk of forgetting to read linked guides

**Mitigation:**
- Keep "Quick Links" section at top of CLAUDE.md
- Include brief context in CLAUDE.md before each "see X.md" link
- Use consistent naming (all guides in root directory)
- Update README.md to point to guide structure

---

## Implementation Order

1. ✅ Create this plan document
2. Create MCP_INTEGRATION.md (largest extraction)
3. Create SECURITY.md (second largest)
4. Create REACT_NATIVE_GUIDE.md
5. Create SWIFT_GUIDE.md
6. Create CONFIGURATION.md
7. Create TROUBLESHOOTING.md
8. Create QUICK_START.md
9. Update CLAUDE.md with streamlined structure
10. Update README.md to reference new guide structure
11. Test all links
12. Commit changes

---

## Notes

- All extracted guides will live in root directory (not docs/) for easy access
- Keep code examples in guides (they're valuable!)
- CLAUDE.md remains the "entry point" - always read first
- Each guide should be self-contained but reference others where appropriate
- Use consistent formatting across all guides
- Add "Last Updated" date to each guide

---

**Created**: 2025-01-24
**Status**: Ready for implementation
**Estimated Time**: 2-3 hours for full extraction and testing
