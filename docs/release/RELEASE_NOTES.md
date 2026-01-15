# Agent Deck v0.1.0 - MVP Release Notes

**Release Date:** TBD (Pending final build and testing)

**Version:** 0.1.0 (MVP - Minimum Viable Product)

---

## 🎉 What's New

**Agent Deck v0.1.0** is the first public release - a native macOS menubar app that monitors Claude Code agents and provides mobile control via a React Native app.

### ✨ Key Features

#### 🔍 Real-Time Agent Monitoring
- **Live status updates** - See what your Claude Code agents are doing in real-time
- **Rich data display:**
  - Current task description
  - Todo list with completion checkboxes
  - AI model name (e.g., claude-sonnet-4-5-20250929)
  - Git branch tracking
  - Subagent activity count
- **< 500ms update latency** - Near-instant updates from Mac to mobile

#### 📱 Native Mobile App (React Native)
- **iOS 15+ and Android 8+ support** - Single codebase via Expo
- **Touch-optimized interface** - Dark mode, expandable sections, smooth animations
- **Keep screen awake** - No interruptions while monitoring
- **QR code pairing** - 60-second setup process
- **One-tap window switching** - Tap agent card → Mac switches focus instantly

#### 🔒 Privacy & Security
- **Fully local** - No cloud services, no subscriptions
- **Same WiFi network required** - All traffic stays on your local network
- **Open source** - Audit the code, see exactly what it does
- **No authentication** - Designed for trusted local networks

#### ⚡ Zero-Config Setup
1. Launch macOS app
2. Scan QR code with your phone
3. Start monitoring
4. Done! (Total time: 60 seconds)

---

## 📦 Installation

### Requirements
- **macOS 12+** (Monterey or later)
- **iOS 15+ or Android 8+** for mobile app
- **WiFi network** (Mac and mobile on same network)
- **Claude Code** installed and running
- **Expo Go app** (for mobile - available on App Store/Play Store)

### Step 1: Install macOS App

**Download:**
```bash
# Download from GitHub Releases
https://github.com/tonyofthehills/agent-deck/releases/tag/v0.1.0

# Unzip and install
unzip Agent-Deck-v0.1.0.app.zip
mv Agent-Deck.app /Applications/
```

**First Launch:**
- Right-click Agent-Deck.app → Open (bypass Gatekeeper)
- Click "Open" in the dialog

### Step 2: Grant Permissions

**Accessibility Access** (required for window switching):
1. System Settings → Privacy & Security → Accessibility
2. Click lock icon to unlock
3. Click "+" and select Agent-Deck.app
4. Ensure checkbox is enabled

**Why needed:** Agent Deck uses AppleScript to switch windows on your Mac, which requires accessibility permissions.

### Step 3: Connect Mobile Device

1. **Install Expo Go** on your phone (App Store or Google Play)
2. **Launch Agent Deck** on your Mac
3. **Click menubar icon** → "Show QR Code"
4. **Open Expo Go** → Scan QR code
5. **Agent Deck mobile app loads** in Expo Go
6. **Start monitoring!**

### Step 4: Use Agent Deck

1. Launch Claude Code on your Mac
2. Start a coding task
3. Open Agent Deck mobile app (via Expo Go)
4. Monitor agents from anywhere in your house
5. Tap agent cards to switch windows instantly

---

## 🎯 What's Included

### macOS App Components
- **Native Swift/SwiftUI menubar app** (2,700+ lines of code)
- **FSEvents file system monitoring** - Watches Claude Code transcript files
- **WebSocket server** - Broadcasts updates to mobile devices
- **HTTP server** - Serves QR code and handles pairing
- **AppleScript integration** - Window switching via native macOS APIs
- **Process monitoring** - Detects running Claude Code instances
- **Rich transcript parsing** - Extracts model, branch, todos, subagents

### React Native Mobile App
- **Touch-optimized interface** - Native iOS/Android performance
- **WebSocket client** - Real-time updates from Mac
- **QR code scanner** - Camera-based pairing
- **Agent cards** - Expandable sections (todos, model, branch), status indicators
- **Actions screen** - Stream Deck-style grid of custom action buttons
- **Dark mode theme** - Beautiful dark UI throughout
- **Keep awake feature** - Screen stays on while monitoring

### Documentation
- **README.md** - Comprehensive user guide
- **CLAUDE.md** - Developer documentation
- **QUICK_START.md** - Get started in 5 minutes
- **TEST_CHECKLIST.md** - Manual QA test procedures
- **MCP_INTEGRATION.md** - MCP server usage guide
- **SECURITY.md** - Security scanning guidelines
- **TESTING_GUIDE.md** - Testing procedures
- **LESSONS_LEARNED.md** - Implementation insights
- **WebSocket protocol spec** - Technical reference

---

## ⚠️ Known Limitations

**These are intentional MVP tradeoffs to ship quickly:**

1. **macOS only** - Mac app required (Windows/Linux not supported)
2. **Claude Code only** - Cursor, Windsurf, Aider support coming in Phase 2
3. **Local network only** - Mac and phone must be on same WiFi
4. **No authentication** - Assumes trusted local network environment
5. **Monitoring only** - Cannot approve/reject agent actions (Phase 5 feature)
6. **Expo Go required** - Native app store distribution in Phase 3+
7. **No code signing** - Mac app not notarized (must right-click → Open)

---

## 🐛 Known Issues

### Minor Issues
- **First launch requires Gatekeeper bypass** - Right-click → Open (one-time)
- **Accessibility permissions required** - Must grant manually for window switching
- **WebSocket reconnection delay** - 1-2 second delay after disconnect
- **Transcript path hardcoded** - May break if Claude Code changes file locations

### Workarounds
- **Gatekeeper:** Right-click Agent-Deck.app → Open → Click "Open" button
- **Permissions:** System Settings → Privacy & Security → Accessibility → Add Agent-Deck.app
- **Reconnection:** Automatic retry, just wait 1-2 seconds
- **Transcript path:** Report issue on GitHub if Claude Code changes locations

**Report bugs:** [GitHub Issues](https://github.com/tonyofthehills/agent-deck/issues/new?template=bug_report.md)

---

## 🚀 What's Next (Roadmap)

### Phase 2 (Next 2-4 weeks)
- **Cursor and Windsurf support** - Monitor multiple agent types
- **Custom actions backend** - Wire mobile buttons to Mac scripts
- **Settings UI** - Configuration window for advanced options
- **Drag-to-reorder actions** - Customize button layout

### Phase 3 (Month 2-3)
- **App Store distribution** - Native iOS app (no Expo Go required)
- **Play Store distribution** - Native Android app
- **Code signing** - Notarized Mac app (no Gatekeeper bypass)
- **Authentication layer** - Secure remote access option

### Future (Phase 4+)
- **Mobile interaction** - Approve/reject agent actions from phone
- **Agent control** - Pause, resume, send commands
- **Integrations** - Slack notifications, webhooks, custom triggers
- **Windows support** - If demand exists

**Full Roadmap:** [ROADMAP.md](ROADMAP.md)

---

## 🔧 Technical Details

### Architecture
- **macOS App:** Swift 5.7+, SwiftUI, Combine, FSEvents, Network.framework
- **Mobile App:** React Native 0.73+, Expo SDK 50+, TypeScript 5.0+
- **Monorepo:** pnpm workspaces with shared types package
- **Communication:** WebSocket protocol (custom JSON messages)
- **Monitoring:** FSEvents-based file system watching
- **Window Control:** AppleScript via NSAppleScript

### Performance Targets
- **macOS CPU:** < 2% idle, < 5% active
- **macOS Memory:** < 100MB RAM
- **Mobile Memory:** < 150MB RAM
- **Update Latency:** < 500ms (Mac → mobile)
- **Window Switch:** < 1 second
- **Cold Start:** < 3 seconds (mobile app)

### Compatibility
- **macOS:** 12.0+ (Monterey, Ventura, Sonoma, Sequoia)
- **iOS:** 15.0+ (via Expo Go or native build)
- **Android:** API 21+ (Android 5.0+)
- **Node.js:** 18+ LTS (for development only)
- **Xcode:** 15+ (for macOS app development)

---

## 📚 Getting Started Resources

### User Guides
- **[QUICK_START.md](QUICK_START.md)** - Get started in 5 minutes
- **[README.md](README.md)** - Comprehensive user manual
- **Troubleshooting section** - Common issues and solutions

### Developer Guides
- **[CLAUDE.md](CLAUDE.md)** - Developer documentation (comprehensive)
- **[MCP_INTEGRATION.md](MCP_INTEGRATION.md)** - MCP server usage
- **[SECURITY.md](SECURITY.md)** - Security scanning with Semgrep
- **[REACT_NATIVE_GUIDE.md](REACT_NATIVE_GUIDE.md)** - Mobile development patterns
- **[SWIFT_GUIDE.md](SWIFT_GUIDE.md)** - macOS development patterns
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Testing procedures
- **[LESSONS_LEARNED.md](LESSONS_LEARNED.md)** - Critical implementation insights

### Technical Specs
- **[agent-deck-spec-final.md](agent-deck-spec-final.md)** - Product specification
- **[specs/001-mvp/contracts/websocket-protocol.md](specs/001-mvp/contracts/websocket-protocol.md)** - WebSocket protocol
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

---

## 🤝 Contributing

**Contributions welcome!** Agent Deck is open source and free forever.

### How to Contribute
1. **Report bugs** - Use [bug report template](https://github.com/tonyofthehills/agent-deck/issues/new?template=bug_report.md)
2. **Request features** - Use [feature request template](https://github.com/tonyofthehills/agent-deck/issues/new?template=feature_request.md)
3. **Submit pull requests** - See [CLAUDE.md](CLAUDE.md) for developer setup
4. **Share feedback** - What works? What doesn't? What's missing?

### Development Setup
```bash
# Clone repository
git clone https://github.com/tonyofthehills/agent-deck.git
cd agent-deck

# Install dependencies
pnpm install

# Start mobile app (Expo)
pnpm mobile

# Open macOS app in Xcode
cd apps/macos/Agent-Deck && open AgentDeck.xcodeproj
# Command+R in Xcode to run
```

**Requirements:**
- Xcode 15+
- macOS 12+
- Node.js 18+
- pnpm 8+
- Claude Code (for testing)

---

## 🙏 Acknowledgments

**Built with:**
- [Swift](https://swift.org/) and [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- [React Native](https://reactnative.dev/) and [Expo](https://expo.dev/)
- [TypeScript](https://www.typescriptlang.org/)
- [pnpm](https://pnpm.io/)
- FSEvents, Combine, Network.framework (macOS)
- expo-keep-awake, expo-camera (mobile)

**Inspired by:**
- [Elgato Stream Deck](https://www.elgato.com/stream-deck) - UX paradigm
- [Touch Portal](https://www.touch-portal.com/) - Remote control concept
- Agentic coding tools (Claude Code, Cursor, Windsurf)

**Special thanks:**
- Anthropic (Claude Code)
- SpecKit project (spec-driven development)

---

## 📜 License

**MIT License** - Open source, free forever.

See [LICENSE](LICENSE) file for full text.

---

## 📞 Support & Feedback

**Need help?**
- **GitHub Issues:** [Report bugs](https://github.com/tonyofthehills/agent-deck/issues/new?template=bug_report.md)
- **GitHub Discussions:** [Community Q&A](https://github.com/tonyofthehills/agent-deck/discussions)
- **Documentation:** See [README.md](README.md) for troubleshooting

**Feature requests:**
- [Feature request template](https://github.com/tonyofthehills/agent-deck/issues/new?template=feature_request.md)

**Built by:** [@tonyofthehills](https://github.com/tonyofthehills)

---

## 🎯 Download

**Get Agent Deck v0.1.0:**
- **macOS App:** [Download Agent-Deck-v0.1.0.app.zip](https://github.com/tonyofthehills/agent-deck/releases/tag/v0.1.0)
- **Source Code:** [GitHub Repository](https://github.com/tonyofthehills/agent-deck)
- **Mobile App:** Use Expo Go + QR code (native apps in Phase 3+)

**Requirements:** macOS 12+, iOS 15+/Android 8+, same WiFi network

---

**Built with ❤️ by developers, for developers.**

*Monitor your agents. Stay productive. Work from anywhere.*

---

**Release Notes Version:** 1.0
**Agent Deck Version:** 0.1.0 (MVP)
**Release Date:** TBD
**Platform:** macOS 12+ (menubar app) + iOS 15+/Android 8+ (React Native mobile app)
