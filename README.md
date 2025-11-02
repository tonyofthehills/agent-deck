# Agent Deck

**Stream Deck for AI agents** - Monitor Claude Code, Cursor, and other agentic coding tools from your phone. Switch windows with one tap, run custom macros, all from your pocket.

## 📱 Platform Strategy

**Phase 1 (MVP - 2 weeks):**
- 🖥️ **Mac**: Native Swift/SwiftUI menubar app
- 📱 **Mobile**: Progressive Web App (works on iOS/Android/iPad)

**Phase 2+ (After Validation):**
- Native iOS app (if users demand it)
- Native Android app (if iOS succeeds)

## 🚀 Quick Start with SpecKit

This project uses **SpecKit** for spec-driven development with AI assistants.

### Setup (< 10 minutes)

```bash
# Install uv package manager
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install SpecKit
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# Initialize in project
cd /Users/tonyofthehills/dev/apps/app-009-agent-deck
specify init --agent claude-code
```

### Day 1 Workflow (with Claude Code)

```bash
# 1. Define project principles
/speckit.constitution

# 2. Create specification
/speckit.specify

# 3. Generate implementation plan
/speckit.plan

# 4. Break into tasks
/speckit.tasks

# 5. Start implementing
/speckit.implement [task-name]
```

## 📄 Documentation

**Full Specification:** [`agent-deck-spec-final.md`](./agent-deck-spec-final.md)

Includes:
- Platform strategy (Mac + PWA)
- Phase 1-9 implementation roadmap
- Technical architecture
- Mobile interaction strategy (Phase 5+)
- Success criteria and KPIs

## 🎯 MVP Goals (Week 1-2)

**Week 1: Mac App Core**
- [x] SwiftUI menubar app
- [ ] Process monitoring (Claude Code instances)
- [ ] Embedded WebSocket server
- [ ] Settings window
- [ ] QR code for mobile pairing

**Week 2: PWA Mobile + Window Switching**
- [ ] PWA mobile interface
- [ ] Real-time status updates
- [ ] AppleScript window switching
- [ ] Tap-to-focus functionality
- [ ] "Add to Home Screen" verified

**🎯 Ship to first users at end of Week 2**

## 🏗️ Tech Stack

**macOS Application:**
- Swift 5.7+ / SwiftUI
- Network.framework (WebSocket server)
- NSWorkspace (process monitoring)
- NSAppleScript (window management)

**Mobile Interface:**
- Progressive Web App (vanilla JS)
- Works on iOS Safari, Chrome, Android browsers
- Installable on home screen
- Service Worker for offline support

**Future (Phase 7+):**
- Native iOS app (SwiftUI)
- Native Android app (React Native or Kotlin)

## 🎨 Product Vision

**Elevator Pitch:** "Stream Deck for AI agents. Monitor Claude Code and Cursor from your phone, trigger macros, switch windows - all in your pocket."

**Key Differentiators:**
1. Stream Deck familiarity (proven category)
2. Fully local (no cloud, no subscription)
3. Window switching (mobile → Mac control)
4. Agent-aware actions (macros that understand agent state)
5. Universal mobile access (PWA works everywhere)

## 📅 Timeline

- **Week 2**: Soft launch (Show HN, early adopters)
- **Month 3**: Product Hunt launch
- **Month 3+**: Native mobile apps (only if validated)

## 🔗 Resources

- **SpecKit Docs**: https://speckit.org
- **SpecKit GitHub**: https://github.com/github/spec-kit
- **Product Spec**: [`agent-deck-spec-final.md`](./agent-deck-spec-final.md)

---

**Status:** 🚧 In development - Phase 1 (MVP)
