# GitHub Release Checklist

This checklist ensures Agent Deck MVP is ready for public release with all necessary assets, documentation, and testing complete.

---

## Pre-Release Checklist

### Code Quality

- [ ] **All tests passing**
  ```bash
  cd /Users/tonyofthehills/dev/apps/app-009-agent-deck/Agent-Deck
  ./run-all-tests.sh --quick
  ```

- [ ] **No compiler warnings in Xcode**
  - Product → Clean Build Folder
  - Product → Build (Cmd+B)
  - Check warnings panel (0 warnings expected)

- [ ] **Swift 6 concurrency compliance**
  - No data races
  - All `@MainActor` annotations correct
  - FSEvents thread-safe

- [ ] **Code review complete**
  - Check ProcessMonitor.swift for edge cases
  - Review WebSocketServer.swift for connection handling
  - Verify HTTPServer.swift serves PWA correctly
  - Inspect PWA app.js for WebSocket reconnection logic

### Version Information

- [ ] **Update version number**
  - File: `Agent-Deck.xcodeproj/project.pbxproj`
  - Set `MARKETING_VERSION` to `0.1.0`
  - Set `CURRENT_PROJECT_VERSION` to `1`

- [ ] **Update bundle identifier**
  - Verify: `com.agentdeck.Agent-Deck`

- [ ] **Update copyright year**
  - Info.plist: `NSHumanReadableCopyright` → 2025

### Documentation

- [ ] **README.md up to date**
  - Installation instructions clear
  - Screenshots/GIFs added
  - Requirements section accurate
  - Troubleshooting section complete

- [ ] **CHANGELOG.md created**
  - Document all features in v0.1.0
  - Note known limitations
  - Link to GitHub issues

- [ ] **CLAUDE.md updated**
  - Reflect current MVP status
  - Update phase completion
  - Document recent changes

- [ ] **LICENSE file present**
  - MIT License (or chosen license)
  - Copyright holder correct

### Build Assets

- [ ] **Demo GIF created**
  - Follow DEMO_GIF_INSTRUCTIONS.md
  - Size: < 10MB
  - Duration: 20-30 seconds
  - Shows key features (monitoring, window switching, mobile)

- [ ] **Screenshots captured**
  - `screenshot-menubar.png` - Agent Deck in menubar
  - `screenshot-qr-code.png` - QR code display
  - `screenshot-mobile.png` - PWA on iPhone
  - `screenshot-mobile-expanded.png` - Expanded agent details
  - All at 2x resolution (Retina)

- [ ] **App icon present**
  - Assets.xcassets includes all icon sizes
  - Menubar icon (monochrome, 16x16 and 32x32)
  - App icon (if using Dock - not applicable for LSUIElement)

### Testing

- [ ] **Manual testing complete** (see TEST_PROCEDURE_*.md)
  - Fresh install on clean macOS system
  - First-run experience (permissions flow)
  - QR code scanning from iPhone
  - PWA installation ("Add to Home Screen")
  - Window switching works reliably
  - Real-time updates appear on mobile
  - Menubar dropdown displays correctly

- [ ] **Cross-device testing**
  - iPhone Safari (iOS 15+)
  - Android Chrome (Android 10+)
  - iPad Safari (iPadOS 15+)

- [ ] **macOS version testing**
  - macOS 12 Monterey (minimum supported)
  - macOS 13 Ventura
  - macOS 14 Sonoma (primary dev target)
  - macOS 15 Sequoia (if available)

- [ ] **Network scenarios**
  - Same WiFi network (primary use case)
  - Multiple network interfaces (Ethernet + WiFi)
  - Router firewall rules (if applicable)

### Security

- [ ] **No hardcoded secrets**
  - No API keys in source code
  - No development credentials

- [ ] **Permissions documented**
  - Accessibility permissions required (for window switching)
  - User prompted on first launch

- [ ] **Local network security**
  - WebSocket bound to 0.0.0.0:3000 (local network only)
  - No authentication (documented limitation)
  - Plain WebSocket (not WSS) - acceptable for MVP

### Performance

- [ ] **Resource usage acceptable**
  - CPU: < 2% idle, < 5% active
  - Memory: < 100MB RAM
  - Disk: < 50MB app size

- [ ] **Latency targets met**
  - Status update: < 500ms
  - Window switch: < 1s
  - WebSocket message: < 100ms

---

## Build and Archive

### Build for Distribution

1. **Clean Xcode environment**
   ```bash
   cd /Users/tonyofthehills/dev/apps/app-009-agent-deck/Agent-Deck
   # In Xcode:
   # Product → Clean Build Folder (Shift+Cmd+K)
   ```

2. **Set build configuration**
   - Xcode → Product → Scheme → Edit Scheme
   - Run → Build Configuration: **Release**
   - Archive → Build Configuration: **Release**

3. **Archive the app**
   - Product → Archive (Cmd+Shift+B)
   - Wait for archive to complete
   - Organizer window opens automatically

4. **Export archive**
   - Select archive in Organizer
   - Click "Distribute App"
   - Select: **Copy App**
   - Click "Next"
   - Save to: `~/Desktop/Agent-Deck-Export/`

5. **Locate .app bundle**
   ```bash
   ls ~/Desktop/Agent-Deck-Export/
   # Should see: Agent-Deck.app
   ```

### Create Distribution Archive

```bash
# Navigate to exported .app
cd ~/Desktop/Agent-Deck-Export/

# Create zip archive
zip -r Agent-Deck-v0.1.0.app.zip Agent-Deck.app

# Verify archive
unzip -l Agent-Deck-v0.1.0.app.zip

# Check file size (should be < 50MB)
ls -lh Agent-Deck-v0.1.0.app.zip
```

### Test Archive on Clean System

**Important:** Test the .app.zip on a Mac that has never run Agent Deck before.

1. Copy `Agent-Deck-v0.1.0.app.zip` to test Mac
2. Unzip
3. Move to Applications folder
4. Double-click to launch
5. Verify first-run flow:
   - Permissions prompt appears
   - Menubar icon appears
   - QR code displays
   - Mobile connection works

---

## Notarization (Optional for MVP)

**Note:** Notarization is NOT required for MVP release. Users can bypass Gatekeeper with right-click → Open. Consider notarizing in Phase 3+ for wider distribution.

### Requirements for Notarization

- [ ] Apple Developer account ($99/year)
- [ ] Code signing certificate
- [ ] App-specific password for notarization

### Notarization Steps (Future)

```bash
# Sign the app
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name" \
  Agent-Deck.app

# Create zip for notarization
ditto -c -k --keepParent Agent-Deck.app Agent-Deck.zip

# Submit for notarization
xcrun notarytool submit Agent-Deck.zip \
  --apple-id your@email.com \
  --password app-specific-password \
  --team-id TEAM_ID \
  --wait

# Staple notarization ticket
xcrun stapler staple Agent-Deck.app

# Verify
spctl -a -vv Agent-Deck.app
```

**For MVP:** Skip notarization, document workaround in README.

---

## GitHub Release Creation

### Prerequisites

- [ ] GitHub repository created: `github.com/tonyofthehills/agent-deck`
- [ ] Repository is public
- [ ] README.md pushed to main branch
- [ ] All code committed and pushed
- [ ] Working directory clean (`git status`)

### Create Git Tag

```bash
cd /Users/tonyofthehills/dev/apps/app-009-agent-deck

# Ensure on correct branch
git checkout main
git pull origin main

# Create annotated tag
git tag -a v0.1.0 -m "Agent Deck MVP - v0.1.0

Features:
- Real-time Claude Code monitoring
- Window switching from mobile
- Progressive Web App interface
- QR code pairing
- Rich data parsing (model, branch, todos, subagents)

First public release."

# Push tag to GitHub
git push origin v0.1.0
```

### Create GitHub Release

1. **Navigate to GitHub**
   - Go to: https://github.com/tonyofthehills/agent-deck/releases

2. **Click "Draft a new release"**

3. **Fill in release details:**
   - **Tag version:** v0.1.0 (select existing tag)
   - **Release title:** Agent Deck v0.1.0 - MVP Release
   - **Description:** (See template below)

4. **Upload assets:**
   - `Agent-Deck-v0.1.0.app.zip` (Mac app)
   - `demo.gif` (Demo GIF)
   - `screenshots/` folder (zipped)

5. **Release settings:**
   - [ ] Set as latest release: YES
   - [ ] Set as pre-release: NO (it's MVP, but it's production-ready)

6. **Click "Publish release"**

---

## Release Notes Template

```markdown
# Agent Deck v0.1.0 - MVP Release

**Stream Deck for AI agents.** Monitor Claude Code from your phone, switch windows with one tap, all over your local WiFi network.

![Demo](https://github.com/tonyofthehills/agent-deck/releases/download/v0.1.0/demo.gif)

---

## 🎉 What's New

**First public release!**

### Features
- ✅ **Real-time monitoring** of Claude Code instances
- ✅ **Rich data parsing** (model name, git branch, current task, todos, subagents)
- ✅ **One-tap window switching** from mobile device
- ✅ **Progressive Web App** interface (works on iOS/Android/iPad)
- ✅ **QR code pairing** (60-second setup)
- ✅ **Zero configuration** required
- ✅ **Fully local** (no cloud, no subscription)

### Technical Highlights
- Native Swift/SwiftUI menubar app
- FSEvents-based real-time transcript monitoring
- WebSocket protocol for low-latency updates
- Vanilla JavaScript PWA (no build step, fast loading)

---

## 📦 Installation

### Requirements
- **macOS 12+** (Monterey or later)
- **WiFi network** (Mac and phone on same network)
- **Claude Code** installed and running

### Steps

1. **Download Agent-Deck.app**
   - Download `Agent-Deck-v0.1.0.app.zip` from Assets below
   - Unzip the file

2. **Move to Applications**
   ```bash
   # Option 1: Drag and drop to /Applications folder
   # Option 2: Command line
   unzip Agent-Deck-v0.1.0.app.zip
   mv Agent-Deck.app /Applications/
   ```

3. **Launch Agent Deck**
   - Open `/Applications/Agent-Deck.app`
   - **First launch:** Right-click → Open (to bypass Gatekeeper)
   - Grant accessibility permissions when prompted:
     - System Preferences → Privacy & Security → Accessibility
     - Add Agent-Deck.app to allowed apps

4. **Connect Mobile Device**
   - Click Agent Deck icon in menubar (top right)
   - Scan QR code with your phone's camera
   - Safari/Chrome will open the PWA
   - Tap "Add to Home Screen" (iOS) or "Install app" (Android)

5. **Done!**
   - Agent Deck is now monitoring Claude Code
   - Open the PWA from your home screen to see live updates

---

## 🚀 Quick Start

### First-Time Setup (60 seconds)

1. Launch Agent-Deck.app (grant permissions)
2. Click menubar icon → Scan QR code with phone
3. Add PWA to home screen
4. Tap an agent card on phone → Mac switches to that window

### Daily Use

1. Launch Claude Code on your Mac (run your coding tasks)
2. Open Agent Deck PWA on your phone (from home screen)
3. Monitor agent status from anywhere in your house
4. Tap agent cards to instantly switch windows on your Mac

---

## ⚠️ Known Limitations

**MVP Release - These are intentional tradeoffs to ship fast:**

1. **macOS only** - Mac app required (cannot run on Windows/Linux)
2. **Claude Code only** - Cursor, Windsurf, Aider support coming in Phase 2
3. **Local network only** - Mac and phone must be on same WiFi
4. **No authentication** - Assumes trusted local network (add auth in Phase 3)
5. **Single Claude Code instance** - Multiple instances coming in Phase 2
6. **No mobile interaction** - Monitoring only (no approval/rejection of agent actions yet)

---

## 🐛 Known Issues

**Minor issues to be aware of:**

- **Gatekeeper warning on first launch** - Right-click → Open to bypass (app is not notarized yet)
- **Accessibility permissions** - Required for window switching (macOS security prompt)
- **WebSocket reconnection delay** - Mobile may take 1-2 seconds to reconnect if connection drops
- **Transcript file detection** - If Claude Code transcript location changes, monitoring may fail (report as issue)

**Report bugs:** https://github.com/tonyofthehills/agent-deck/issues

---

## 📖 Documentation

- **README.md** - Installation, usage, troubleshooting
- **CLAUDE.md** - Developer guide (for contributors)
- **DEMO_GIF_INSTRUCTIONS.md** - How demo was created
- **WebSocket Protocol** - `specs/001-mvp/contracts/websocket-protocol.md`

---

## 🛣️ Roadmap

### Phase 2 (Next 2-4 weeks)
- Support for Cursor and Windsurf agents
- Multiple Claude Code instances
- Custom actions (run bash scripts, open apps)
- Configuration UI (settings window)

### Phase 3 (Month 2-3)
- Native iOS app (if 100+ users request it)
- Enhanced parsing (approval prompts, file diffs, error messages)
- Authentication layer (secure non-local access)
- Bonjour/mDNS auto-discovery

### Future Ideas (Phase 4+)
- Mobile approval/rejection of agent actions
- Agent interaction (pause, resume, send input)
- Integrations (Slack notifications, webhooks, custom triggers)
- Windows support (if demand exists)

**See full roadmap:** `agent-deck-spec-final.md`

---

## 💬 Feedback

**This is an MVP built in 2 weeks.** Your feedback shapes the product.

**Questions I'm curious about:**
- Would you use this? What's missing?
- What agents do you want to monitor? (Cursor, Windsurf, Aider, others?)
- What actions would you want on your "Stream Deck"?
- Should I prioritize native iOS app or focus on more features?

**Feature requests:** https://github.com/tonyofthehills/agent-deck/issues/new?template=feature_request.md
**Bug reports:** https://github.com/tonyofthehills/agent-deck/issues/new?template=bug_report.md

---

## 🙏 Acknowledgments

**Built with:**
- Swift 5.7+ / SwiftUI
- FSEvents (file system monitoring)
- Combine (reactive state management)
- Network.framework (WebSocket server)
- Vanilla JavaScript (PWA - no framework bloat)

**Inspired by:**
- Elgato Stream Deck (UX paradigm)
- Touch Portal (remote control concept)
- Agentic coding tools (Claude Code, Cursor, Windsurf)

---

## 📜 License

MIT License - See LICENSE file

**Open Source, Free Forever**

---

## 📊 Assets

**Included in this release:**
- `Agent-Deck-v0.1.0.app.zip` - macOS application (50MB)
- `demo.gif` - Demo video (8MB)
- `screenshots.zip` - All screenshots (5MB)

**SHA256 Checksums:**
```
<generate after creating zip files>
```

---

**Built by:** [@tonyofthehills](https://github.com/tonyofthehills)
**Website:** Coming soon (agent-deck.dev)
**Support:** GitHub Issues
```

---

## Post-Release Checklist

### GitHub Configuration

- [ ] **Create issue templates**
  - `.github/ISSUE_TEMPLATE/bug_report.md`
  - `.github/ISSUE_TEMPLATE/feature_request.md`

- [ ] **Add repository description**
  - Settings → General → Description: "Stream Deck for AI agents - Monitor Claude Code from your phone"
  - Website: https://agent-deck.dev (or GitHub Pages URL)
  - Topics: `swift`, `swiftui`, `macos`, `pwa`, `claude-code`, `cursor`, `stream-deck`

- [ ] **Set up GitHub Pages** (optional)
  - Settings → Pages → Source: Deploy from branch
  - Branch: `main` / `docs/` folder
  - Use for demo video hosting and documentation

- [ ] **Enable Discussions** (optional)
  - Settings → Features → Discussions: ON
  - Good for community feedback and feature discussions

### Distribution

- [ ] **Show HN post ready**
  - Copy SHOW_HN_POST.md content
  - Upload demo.gif to Imgur
  - Submit to news.ycombinator.com/submit

- [ ] **Tweet announcement** (optional)
  - Include demo GIF
  - Tag @anthropic, @cursor_ai (if relevant)
  - Link to GitHub release

- [ ] **Product Hunt preparation** (Month 3)
  - Collect user testimonials first
  - Create Product Hunt assets (logo, tagline, images)
  - Schedule launch day

- [ ] **Update README badge** (optional)
  - Add GitHub release badge
  - Add license badge
  - Add platform badge (macOS 12+)

### Monitoring

- [ ] **Set up analytics** (optional)
  - GitHub Insights (Stars, Forks, Traffic)
  - WebSocket connection logs (how many users connecting?)
  - Crash reports (if applicable)

- [ ] **Monitor issues**
  - Respond to bug reports within 24 hours
  - Triage feature requests
  - Update roadmap based on feedback

---

## Timeline Estimate

**Assuming all code is complete and tested:**

- Pre-release checklist: **2 hours**
- Build and archive: **30 minutes**
- Test on clean system: **30 minutes**
- Create GitHub release: **1 hour**
- Post-release tasks: **1 hour**

**Total:** ~5 hours from checklist start to public release

**Add extra time for:**
- Demo GIF creation: **1-2 hours** (see DEMO_GIF_INSTRUCTIONS.md)
- Screenshot capture: **30 minutes**
- Show HN post refinement: **30 minutes**

**Grand total:** ~7-8 hours to go from "code complete" to "live on GitHub + Show HN"

---

## Emergency Rollback

**If critical bug discovered post-release:**

1. **Delete release** (if < 1 hour old)
   - GitHub → Releases → Edit → Delete release

2. **Or create hotfix:**
   ```bash
   git checkout v0.1.0
   git checkout -b hotfix/v0.1.1
   # Fix bug
   git commit -m "Hotfix: critical bug description"
   git tag -a v0.1.1 -m "Hotfix release"
   git push origin v0.1.1
   # Create new GitHub release with v0.1.1
   ```

3. **Update Show HN post:**
   - Edit to link to v0.1.1 instead
   - Acknowledge issue and fix

---

**Good luck with the launch! 🚀**
