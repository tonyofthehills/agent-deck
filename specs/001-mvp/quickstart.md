# Quick start: Agent Deck MVP Development

**Feature**: Agent Deck MVP (Phases 1-2)
**Date**: 2025-01-05
**Audience**: Developers implementing Agent Deck

## Prerequisites

### Required Software

- **macOS 12+** (Monterey or later)
- **Xcode 14.0+** with Command Line Tools
- **Swift 5.7+** (included with Xcode)
- **Git** (for version control)

### Optional Tools

- **wscat**: WebSocket CLI testing (`npm install -g wscat`)
- **iOS Simulator**: Built into Xcode (for PWA testing)
- **Physical iOS/Android device**: For real mobile testing

### Knowledge Requirements

- Swift and SwiftUI fundamentals
- Basic Combine framework (reactive programming)
- Vanilla JavaScript (ES6+)
- WebSocket protocol basics
- macOS app development (menubar apps, permissions)

---

## Project Setup (Week 1 Day 1)

### Step 1: Create Xcode Project

```bash
# Navigate to workspace
cd /Users/tonyofthehills/dev/apps/app-009-agent-deck

# Create new macOS app project
# File > New > Project > macOS > App
# Product Name: AgentDeck-Mac
# Interface: SwiftUI
# Language: Swift
# Include Tests: No (manual testing in Phase 1-2)
```

**Project Settings**:
- **Bundle Identifier**: `com.agentdeck.mac`
- **Deployment Target**: macOS 12.0
- **Team**: None (or your developer account)
- **App Category**: Developer Tools

### Step 2: Configure Menubar App

Edit `Info.plist`:

```xml
<key>LSUIElement</key>
<true/>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

- `LSUIElement`: Hides dock icon (menubar-only app)
- `NSAllowsLocalNetworking`: Allows local network WebSocket connections

### Step 3: Add Swift Package Dependencies

**File > Add Package Dependencies**:

1. **Yams** (YAML parsing)
   - URL: `https://github.com/jpsim/Yams.git`
   - Version: 5.0.0 or later
   - Target: AgentDeck-Mac

2. **Vapor** (Optional - if Network.framework insufficient)
   - URL: `https://github.com/vapor/vapor.git`
   - Version: 4.0.0 or later
   - Add only if Day 3 decision point triggers migration

### Step 4: Create Project Structure

```bash
# In Xcode, create these groups (folders)
AgentDeck-Mac/
├── Sources/
│   ├── Models/
│   ├── Services/
│   ├── Views/
│   └── Utilities/
├── Resources/
│   ├── Assets.xcassets
│   └── WebRoot/
└── Info.plist
```

**Right-click AgentDeck-Mac → New Group → Name accordingly**

### Step 5: Create PWA Directory

```bash
# Create WebRoot directory for PWA files
mkdir -p AgentDeck-Mac/Resources/WebRoot/icons

# Create placeholder files
touch AgentDeck-Mac/Resources/WebRoot/{index.html,app.js,styles.css,manifest.json,service-worker.js}
```

**Add to Xcode**:
- Right-click Resources → Add Files to "AgentDeck-Mac"
- Select WebRoot folder
- ✅ Create folder references (blue folder, not yellow)
- ✅ Copy items if needed

---

## Development Workflow

### Week 1: Mac Application Core

**Daily Schedule**:

**Days 1-2: Process Monitoring**
```bash
# Create files in Xcode:
# Models/AgentInstance.swift
# Models/AgentStatus.swift
# Services/ProcessMonitor.swift
# Views/MenuBarView.swift

# Run app: Command+R
# Test: Launch Claude Code, check menubar dropdown shows instance
```

**Days 3-4: WebSocket Server**
```bash
# Create files:
# Services/WebSocketServer.swift
# Models/StatusUpdate.swift
# Services/ConfigManager.swift

# Test: wscat -c ws://localhost:3000
# Verify: Connection accepted, initial_state message received
```

**Days 5-7: QR Code + HTTP Server**
```bash
# Create files:
# Services/HTTPServer.swift
# Utilities/QRGenerator.swift
# Views/QRCodeView.swift
# Views/SettingsView.swift

# Test: Scan QR code with phone, open URL in Safari
# Verify: PWA loads (even if minimal HTML)
```

### Week 2: PWA + Window Switching

**Days 8-9: PWA Mobile Interface**
```bash
# Edit files:
# Resources/WebRoot/index.html
# Resources/WebRoot/app.js
# Resources/WebRoot/styles.css

# Test: Open http://192.168.1.100:3000 on phone
# Verify: Agent list displays, real-time updates work
```

**Days 10-11: Window Switching + Custom Actions**
```bash
# Create files:
# Services/WindowManager.swift
# Models/CustomAction.swift
# Services/CustomActionManager.swift

# Test: Tap instance card on mobile
# Verify: Mac window switches within 1 second

# Add custom actions to config.yaml
# Test: Tap action button on mobile
# Verify: AppleScript/Bash/URL executes correctly
```

**Days 12-13: PWA Polish + Custom Actions UI**
```bash
# Edit files:
# Resources/WebRoot/index.html (add 4-column grid + expandable panel)
# Resources/WebRoot/app.js (add action handlers, drag interaction)
# Resources/WebRoot/styles.css (grid layout, panel animation)
# Resources/WebRoot/manifest.json
# Resources/WebRoot/service-worker.js
# Resources/WebRoot/icons/ (add PNG files)

# Test: "Add to Home Screen" on iOS Safari
# Verify: Icon appears, launches fullscreen
# Verify: Custom actions grid displays with drag panel
```

**Day 14: Integration Testing**
```bash
# Run full test suite (manual checklist)
# Validate all 18 success criteria from spec.md
# Fix critical bugs
# Prepare Show HN post
```

---

## Running the App

### Launch Mac App

```bash
# In Xcode
Command+R

# Or build and run from command line
xcodebuild -scheme AgentDeck-Mac -configuration Debug
open ~/Library/Developer/Xcode/DerivedData/AgentDeck-Mac-*/Build/Products/Debug/AgentDeck-Mac.app
```

**Expected Behavior**:
1. Menubar icon appears (top-right)
2. Click icon → dropdown shows agent list
3. Console logs: "WebSocket server started on port 3000"

### Access PWA from Mobile

**Step 1: Get Mac's Local IP**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
# Look for line like: inet 192.168.1.100 netmask 0xffffff00 broadcast 192.168.1.255
# Your IP: 192.168.1.100
```

**Step 2: Open on Mobile**
- iPhone/iPad: Open Safari → `http://192.168.1.100:3000`
- Android: Open Chrome → `http://192.168.1.100:3000`

**Step 3: Add to Home Screen**
- iOS Safari: Tap Share button → "Add to Home Screen" → Name: "Agent Deck"
- Android Chrome: Tap Menu (⋮) → "Add to Home Screen"

### Test Claude Code Monitoring

```bash
# Terminal 1: Launch Claude Code in test project
cd ~/dev/test-project
claude-code  # or however you launch Claude Code

# Terminal 2: Watch Mac app console logs
# Check for: "Detected new Claude Code instance, PID: 12345"
```

---

## Configuration

### Default Configuration

Created at `~/.agent-deck/config.yaml` on first launch:

```yaml
server:
  port: 3000
  host: "0.0.0.0"

agents:
  - name: "Claude Code"
    process_pattern: "claude.*code"
    enabled: true
```

### Customization

**Change Server Port**:
```yaml
server:
  port: 8080  # Use different port if 3000 in use
```

**Add Custom Actions** (User Story 6):
```yaml
customActions:
  - id: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890"
    label: "Open Figma"
    icon: "🎨"
    actionType: "applescript"
    params:
      script: 'tell application "Figma" to activate'
    enabled: true

  - id: "B2C3D4E5-F6A7-8901-BCDE-F12345678901"
    label: "Git Status"
    icon: "📊"
    actionType: "bash"
    params:
      command: "/usr/bin/git"
      args: ["status", "--short"]
    enabled: true

  - id: "C3D4E5F6-A7B8-9012-CDEF-123456789012"
    label: "GitHub"
    icon: "🐙"
    actionType: "url"
    params:
      urlString: "https://github.com"
    enabled: true
```

**Action Types**:
- `applescript`: Execute AppleScript code (open apps, run system commands)
- `bash`: Execute shell commands with arguments
- `url`: Open URLs in default browser/app (http, https, file, mailto, tel)
- `shortcuts`: Run macOS Shortcuts (Phase 5+, not in MVP)

**Add Custom Agent Pattern** (Phase 3+):
```yaml
agents:
  - name: "Cursor"
    process_pattern: "Cursor"
    enabled: true
```

---

## Debugging

### Common Issues

**1. "WebSocket connection failed"**
- **Cause**: Firewall blocking port 3000
- **Solution**: System Preferences → Security & Privacy → Firewall → Firewall Options → Allow AgentDeck-Mac

**2. "Window switching not working"**
- **Cause**: Accessibility permissions not granted
- **Solution**: System Preferences → Privacy & Security → Accessibility → ✅ AgentDeck-Mac

**3. "PWA not loading"**
- **Cause**: WebRoot files not included in app bundle
- **Solution**: In Xcode, select WebRoot → Target Membership → ✅ AgentDeck-Mac

**4. "Claude Code not detected"**
- **Cause**: Process name pattern mismatch
- **Solution**: Check actual process name with `ps aux | grep claude`, adjust pattern in config.yaml

### Debugging Tools

**View WebSocket Messages**:
```bash
# Terminal
wscat -c ws://localhost:3000
# Watch JSON messages in real-time
```

**View PWA Console**:
- Safari: Develop → iPhone Simulator → localhost:3000
- Chrome DevTools: Network tab → WS filter → inspect frames

**View Mac App Logs**:
```bash
# Console.app or:
log stream --predicate 'subsystem == "com.agentdeck.mac"'
```

---

## Testing Checklist

### Mac App Tests

- [ ] App launches and menubar icon appears
- [ ] Detects running Claude Code instance(s)
- [ ] Displays instances in menubar dropdown
- [ ] WebSocket server accepts connections on port 3000
- [ ] HTTP server serves PWA files
- [ ] QR code displays correct local network URL
- [ ] Settings window opens and saves preferences
- [ ] App quits cleanly without background processes

### PWA Tests

- [ ] PWA loads on iOS Safari 14+
- [ ] PWA loads on Chrome 90+ (desktop and Android)
- [ ] Agent list displays with correct status colors
- [ ] Status updates appear within 500ms
- [ ] Tapping instance switches window within 1s
- [ ] Custom actions grid displays below agent instances
- [ ] Custom action buttons in 4-column grid layout
- [ ] Tapping custom action executes within 2s
- [ ] AppleScript action opens specified app
- [ ] Bash action displays output in toast
- [ ] URL action opens browser/app
- [ ] Success/failure toasts appear correctly
- [ ] Expandable panel drag interaction works
- [ ] Panel state persists to localStorage
- [ ] "Add to Home Screen" creates icon
- [ ] Fullscreen launch works (no browser chrome)
- [ ] Offline mode shows cached UI shell

### Integration Tests

- [ ] Multiple instances display correctly
- [ ] Window switching works across macOS Spaces
- [ ] Reconnection works after network interruption
- [ ] Process termination removes instance
- [ ] Mac sleep/wake triggers reconnection
- [ ] Multiple mobile clients receive updates

---

## Performance Validation

Run these tests on Day 14:

**Latency Tests**:
```bash
# Terminal: Monitor status update latency
# Change agent status, measure time until mobile UI updates
# Target: <500ms

# Window switch latency
# Tap instance on mobile, measure time until window frontmost
# Target: <1s
```

**Resource Usage**:
```bash
# Terminal: Monitor Mac app resources
top -pid $(pgrep -f AgentDeck-Mac)
# Target: <100MB RAM, <2% CPU idle, <5% CPU active
```

**Stability**:
```bash
# Leave app running for 24 hours
# Check for memory leaks, crashes
# Target: No crashes, stable RAM usage
```

---

## Deployment Preparation (Day 14)

### Archive for Distribution

```bash
# Xcode: Product > Archive
# Organizer > Distribute App > Copy App
# Result: AgentDeck-Mac.app in ~/Desktop
```

### Test on Clean macOS

1. Copy .app to different Mac (or clean VM)
2. Double-click to install
3. Grant accessibility permissions
4. Verify detection and window switching work

### Create Show HN Post

**Title**: "Agent Deck – Monitor Claude Code and AI agents from your phone"

**Body**:
- Link to .app download (GitHub release)
- GIF demo of QR setup + window switching
- Link to specs/001-mvp/spec.md (feature overview)
- Request for feedback on Show HN

---

## Next Steps After MVP

**Post-Launch** (Week 3+):
1. Gather user feedback from Show HN
2. Fix critical bugs reported
3. Prioritize Phase 3 features based on feedback
4. Run `/speckit.specify` for next feature increment

**Potential Phase 3 Features** (based on user validation):
- Parsed output display (User Story 4)
- Cursor/Windsurf support
- Advanced custom actions (Shortcuts integration, action chaining)
- Task history and logs
- Native iOS app (if 100+ users request)

---

## Resources

**Documentation**:
- [spec.md](./spec.md) - Feature specification
- [plan.md](./plan.md) - Implementation plan
- [data-model.md](./data-model.md) - Entity definitions
- [contracts/websocket-protocol.md](./contracts/websocket-protocol.md) - API protocol
- [research.md](./research.md) - Technology decisions

**External References**:
- Swift Documentation: https://swift.org/documentation/
- SwiftUI Tutorials: https://developer.apple.com/tutorials/swiftui
- Network.framework: https://developer.apple.com/documentation/network
- PWA Guide: https://web.dev/progressive-web-apps/

**Project Resources**:
- Constitution: `.specify/memory/constitution.md`
- CLAUDE.md: Project-specific patterns and examples

---

## Support

**Issues**: Create GitHub issue in app-009-agent-deck repository
**Questions**: Check CLAUDE.md MCP Server Integration section for AI assistance
**Feedback**: Post-MVP feedback via Show HN comments or GitHub Discussions
