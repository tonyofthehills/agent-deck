# Agent Deck Roadmap

**Last updated:** 2025-01-06

This roadmap outlines the planned features and timeline for Agent Deck. Priorities may shift based on user feedback.

---

## 🎉 Shipped

### Phase 0-1: MVP (✅ Complete - January 2025)

**Core functionality:**
- ✅ Real-time monitoring of Claude Code instances via FSEvents
- ✅ Rich data parsing (model name, git branch, current task, todos, subagents)
- ✅ One-tap window switching from mobile (AppleScript integration)
- ✅ Progressive Web App mobile interface (iOS/Android/iPad)
- ✅ QR code pairing for mobile setup
- ✅ WebSocket real-time updates (< 500ms latency)
- ✅ Native macOS menubar app (Swift/SwiftUI)
- ✅ Zero-config setup (60 seconds)

**Technical achievements:**
- ✅ FSEvents-based transcript monitoring
- ✅ Combine reactive state management
- ✅ Thread-safe data handling (@MainActor)
- ✅ Embedded HTTP server for PWA
- ✅ Embedded WebSocket server (port 3000)

---

## 🚧 In Progress

### Phase 2: Multi-Agent Support (Weeks 3-4)

**Priorities based on user feedback:**
- [ ] **Cursor support** (highest demand)
- [ ] **Windsurf support** (second highest)
- [ ] **Multiple Claude Code instances** (track multiple projects)
- [ ] **Agent type detection** (auto-detect Cursor vs Claude Code)

**Custom actions:**
- [ ] **Bash script execution** (run tests, build, deploy)
- [ ] **App launching** (open Figma, VS Code, Terminal)
- [ ] **Custom action configuration** (YAML file in `~/.agent-deck/actions.yaml`)

**Configuration UI:**
- [ ] **Settings window** (menubar → Settings)
- [ ] **Port configuration** (change from default 3000)
- [ ] **Agent monitoring toggles** (enable/disable specific agents)
- [ ] **Transcript path configuration** (if Claude Code changes location)

**Estimated completion:** End of January 2025

---

## 📋 Planned

### Phase 3: Enhanced Monitoring (Month 2)

**Rich data parsing:**
- [ ] **Approval prompts** (parse when agent asks for user input)
- [ ] **File diffs** (show files being modified)
- [ ] **Error messages** (highlight when agent encounters errors)
- [ ] **Performance metrics** (tokens used, time elapsed)

**Mobile experience:**
- [ ] **Native iOS app** (if 100+ users request it)
  - Share 30-40% code with Mac app (SwiftUI)
  - Native animations and gestures
  - Push notifications (when agent needs approval)
- [ ] **Decide on Android** (React Native or Kotlin, based on iOS demand)

**Security:**
- [ ] **Authentication layer** (password or API key for non-local access)
- [ ] **HTTPS/WSS support** (secure WebSocket over TLS)
- [ ] **Code signing and notarization** (remove Gatekeeper warning)

**Estimated completion:** End of February 2025

---

### Phase 4: Mobile Interaction (Month 3)

**Agent control from mobile:**
- [ ] **Approval/rejection** (approve agent actions from phone)
- [ ] **Pause/resume** (pause agent, resume later)
- [ ] **Send input** (respond to agent prompts from mobile)
- [ ] **Cancel tasks** (stop agent execution)

**Technical requirements:**
- PTY wrapper for stdin injection
- Bidirectional command protocol
- Session management

**Estimated completion:** End of March 2025

---

### Phase 5: Integrations (Month 4)

**Third-party integrations:**
- [ ] **Slack notifications** (agent finished, needs approval)
- [ ] **Webhooks** (trigger external services)
- [ ] **IFTTT/Zapier** (connect to automation platforms)
- [ ] **GitHub Actions** (trigger workflows from Agent Deck)

**Custom triggers:**
- [ ] **On agent finish** (run script, send notification)
- [ ] **On error** (alert user, open logs)
- [ ] **On specific task** (detect "running tests", show results)

**Estimated completion:** End of April 2025

---

## 💡 Exploring

**Ideas that may or may not happen, depending on feedback:**

### Additional Agent Support
- [ ] **Aider** (AI pair programming tool)
- [ ] **Continue** (VS Code extension)
- [ ] **Cody** (Sourcegraph's AI assistant)
- [ ] **GitHub Copilot Workspace**
- [ ] **Generic support** (plugin system for any CLI tool)

### Advanced Features
- [ ] **Multi-Mac support** (monitor agents on multiple Macs from one phone)
- [ ] **Agent history** (timeline view of past agent sessions)
- [ ] **Agent analytics** (track productivity, token usage, time saved)
- [ ] **Agent presets** (save common agent configurations)
- [ ] **Voice commands** (Siri integration - "Switch to Claude Code")

### Collaboration
- [ ] **Team mode** (multiple users monitoring same agents)
- [ ] **Screen sharing** (watch agent output in real-time, not just status)
- [ ] **Replay mode** (replay agent sessions for debugging)

### Platform Expansion
- [ ] **Windows support** (if significant demand)
- [ ] **Linux support** (via Electron or native GTK)
- [ ] **Web dashboard** (desktop browser interface, no mobile required)

---

## ❌ Won't Do

**Features we've decided NOT to build:**

- **Cloud-hosted version** - Local-first is a core principle (privacy, speed, no subscription)
- **Desktop app for viewing** - Phone is the whole point (mobile monitoring)
- **Agent creation** - Agent Deck monitors agents, doesn't create them
- **Code editor** - Use VS Code, Cursor, etc. for editing
- **AI features in Agent Deck itself** - Focus on monitoring existing agents, not adding AI to the tool

---

## 🗳️ Community Input

**Help shape the roadmap!**

### How to Influence Priorities

1. **Upvote features** - Add 👍 reaction to feature requests on GitHub
2. **Comment on issues** - Share your use case, why you need it
3. **Create feature requests** - [New feature request](https://github.com/tonyofthehills/agent-deck/issues/new?template=feature_request.md)
4. **Participate in discussions** - [GitHub Discussions](https://github.com/tonyofthehills/agent-deck/discussions)

### Current Top Requests

**Updated as feedback comes in:**

1. Cursor support (10+ requests)
2. Native iOS app (5+ requests)
3. Custom bash actions (3+ requests)
4. Multiple agent instances (3+ requests)

*(These are placeholder numbers - will update after launch)*

---

## 📊 Metrics We Track

**To prioritize features, we're monitoring:**

- **GitHub Stars** - Overall interest level
- **Issue creation rate** - User engagement
- **Feature request votes** - What users want most
- **Active users** - WebSocket connections (anonymous count)
- **PWA installs** - Mobile adoption rate

**Privacy:** We collect NO personal data. Only anonymous usage metrics (connection counts, feature usage).

---

## 🚀 Release Schedule

**Estimated timeline:**

- **v0.1.0** (MVP) - ✅ January 6, 2025
- **v0.2.0** (Cursor/Windsurf) - End of January 2025
- **v0.3.0** (Enhanced monitoring) - End of February 2025
- **v0.4.0** (Mobile interaction) - End of March 2025
- **v0.5.0** (Integrations) - End of April 2025

**Subject to change** based on complexity and user feedback.

---

## 🛠️ Developer Opportunities

**Want to contribute? These areas need help:**

### High Priority
- [ ] **Cursor parser** (parse Cursor agent output)
- [ ] **Windsurf parser** (parse Windsurf agent output)
- [ ] **Custom action system** (plugin architecture)
- [ ] **Testing** (unit tests, integration tests)

### Medium Priority
- [ ] **Android app** (React Native or Kotlin)
- [ ] **Linux support** (GTK or Electron)
- [ ] **Documentation** (tutorials, videos, guides)

### Low Priority (Nice to Have)
- [ ] **Themes** (light mode, custom colors)
- [ ] **Internationalization** (translations)
- [ ] **Accessibility** (VoiceOver, screen reader support)

**See:** [CLAUDE.md](CLAUDE.md) for developer setup

---

## 📝 Version Naming

**Semantic versioning:**

- **0.x.x** - Pre-1.0 (MVP and early iterations)
- **1.0.0** - First stable release (all Phase 1-3 features complete)
- **1.x.0** - Minor updates (new features, non-breaking)
- **1.x.x** - Patch updates (bug fixes, performance)

**When will 1.0 ship?**
- After Phase 3 complete
- All critical bugs fixed
- Mobile experience polished (native or PWA, depending on feedback)
- At least 100 active users validating stability

**Estimated 1.0 release:** Q2 2025 (April-June)

---

## 💬 Feedback

**This roadmap is a living document.** Your feedback shapes it.

**Questions?**
- Open a [Discussion](https://github.com/tonyofthehills/agent-deck/discussions)
- Comment on existing [Issues](https://github.com/tonyofthehills/agent-deck/issues)
- Reach out via [@tonyofthehills](https://github.com/tonyofthehills)

**Have a feature idea not listed here?**
- [Create a feature request](https://github.com/tonyofthehills/agent-deck/issues/new?template=feature_request.md)

---

**Last updated:** 2025-01-06
**Next review:** After v0.2.0 release (end of January 2025)
