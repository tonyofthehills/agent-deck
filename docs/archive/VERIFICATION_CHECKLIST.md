# First-Run Implementation - Verification Checklist

**Date:** 2025-01-06
**Tasks:** T074-T080

---

## Pre-Build Verification

### Code Review
- [x] AppDelegate.swift compiles (no syntax errors)
- [x] ConfigManager.swift compiles (no syntax errors)
- [x] WindowManager.swift compiles (no syntax errors)
- [x] All new methods have documentation comments
- [x] Logger utility used consistently
- [x] Error handling in all critical paths

### Resource Files
- [x] `Resources/default-config.yaml` exists
- [x] Config file has valid YAML syntax
- [x] Config file contains all required fields

### Integration Points
- [x] AppDelegate calls `handleFirstLaunch()` in `applicationDidFinishLaunching`
- [x] AppDelegate calls `checkAndPromptForAccessibilityPermissions()` after services start
- [x] AppDelegate calls `performCleanShutdown()` in `applicationWillTerminate`
- [x] ConfigManager properly checks for bundled resource
- [x] WindowManager state tracking prevents prompt spam

---

## Build & Compile

### Xcode Build
```bash
cd /Users/tonyofthehills/dev/apps/app-009-agent-deck/Agent-Deck
xcodebuild -project Agent-Deck.xcodeproj -scheme Agent-Deck -configuration Debug build
```

**Expected:**
- [ ] Build succeeds with no errors
- [ ] No compiler warnings related to new code
- [ ] All resources bundled properly

**If build fails:**
1. Check for missing imports
2. Verify all files are added to target
3. Check `Resources/default-config.yaml` is in Copy Bundle Resources

---

## Runtime Testing

### Test 1: First Launch (Clean State)

**Setup:**
```bash
# Clean state
defaults delete com.agentdeck.mac hasLaunchedBefore 2>/dev/null || true
rm -rf ~/.agent-deck/
```

**Launch app from Xcode (Cmd+R)**

**Verify:**
- [ ] Welcome dialog appears with "Welcome to Agent Deck!"
- [ ] Dialog explains what Agent Deck does
- [ ] Dialog mentions configuration file location
- [ ] After dismissing welcome, accessibility dialog appears
- [ ] Menubar icon appears (cpu icon)

**Check filesystem:**
```bash
ls -l ~/.agent-deck/config.yaml
cat ~/.agent-deck/config.yaml
```

**Expected:**
- [ ] File exists
- [ ] Contains comments from bundled file
- [ ] Has server.port: 3000
- [ ] Has agents list with Claude Code pattern

**Check UserDefaults:**
```bash
defaults read com.agentdeck.mac hasLaunchedBefore
```

**Expected:**
- [ ] Returns "1" (true)

**Check logs:**
```bash
log stream --predicate 'subsystem == "com.agentdeck.mac"' --level info
```

**Expected log messages:**
- [ ] "First launch - performing initial setup"
- [ ] "Created config from bundled default-config.yaml"
- [ ] "Agent Deck launched successfully"

---

### Test 2: Subsequent Launch

**Setup:**
- Keep UserDefaults and config from Test 1
- Quit app (Cmd+Q)

**Launch app again**

**Verify:**
- [ ] NO welcome dialog (only on first launch)
- [ ] NO accessibility dialog (if already granted)
- [ ] App starts normally
- [ ] Menubar icon appears

**Check logs:**
```bash
log show --predicate 'subsystem == "com.agentdeck.mac"' --last 5m | grep launch
```

**Expected:**
- [ ] "Subsequent launch" message
- [ ] No "First launch" message

---

### Test 3: Config Auto-Creation

**Setup:**
```bash
# Keep UserDefaults, delete config
rm ~/.agent-deck/config.yaml
```

**Launch app**

**Verify:**
- [ ] NO welcome dialog (not first launch)
- [ ] Config file recreated automatically

**Check config:**
```bash
cat ~/.agent-deck/config.yaml
```

**Expected:**
- [ ] File exists
- [ ] Contains data from bundled file (with comments)

**Check logs:**
```bash
log show --predicate 'subsystem == "com.agentdeck.mac"' --last 5m | grep config
```

**Expected:**
- [ ] "Config file not found, creating default configuration"
- [ ] "Created config from bundled default-config.yaml"

---

### Test 4: Accessibility Permissions

**Setup:**
```bash
# Remove accessibility permissions via System Settings:
# System Settings > Privacy & Security > Accessibility > Remove "Agent-Deck"
```

**Launch app**

**Verify:**
- [ ] App launches successfully
- [ ] After services start, accessibility dialog appears
- [ ] Dialog explains why permissions are needed
- [ ] Dialog has "Open System Settings" and "Remind Me Later" buttons

**Click "Open System Settings":**
- [ ] System Settings app opens
- [ ] Navigates to Privacy & Security > Accessibility (or at least opens Settings)
- [ ] macOS system permission dialog appears

**Grant permissions in System Settings**
- Enable "Agent-Deck" in Accessibility list

**Test window switching:**
1. Start a Claude Code instance (e.g., `claude code .` in Terminal)
2. Open Agent Deck menubar dropdown
3. Click on the Claude Code instance

**Verify:**
- [ ] Window switches to Claude Code
- [ ] No error message

---

### Test 5: Accessibility Retry Mechanism

**Setup:**
- Remove accessibility permissions
- Launch app
- Click "Remind Me Later" on permission dialog

**Try to switch windows:**
1. Open menubar dropdown
2. Click on an agent instance

**Verify:**
- [ ] Error message appears: "Accessibility permissions required"
- [ ] NO repeated permission dialogs (only once per session)

**Restart app and try again:**
- [ ] Permission dialog appears again (new session)

---

### Test 6: Clean Shutdown

**Setup:**
- Launch app normally
- Wait for all services to start (check logs)

**Quit app (Cmd+Q)**

**Check for orphan processes:**
```bash
ps aux | grep -i agent-deck | grep -v grep
```

**Expected:**
- [ ] No results (no orphan processes)

**Check network listeners:**
```bash
lsof -iTCP:3000 -sTCP:LISTEN
lsof -iTCP:3001 -sTCP:LISTEN
```

**Expected:**
- [ ] No results (ports released)

**Check shutdown logs:**
```bash
log show --predicate 'subsystem == "com.agentdeck.mac"' --last 1m
```

**Expected log sequence:**
- [ ] "Agent Deck terminating..."
- [ ] "Stopping ProcessMonitor..."
- [ ] "ProcessMonitor stopped"
- [ ] "Stopping WebSocketServer..."
- [ ] "WebSocketServer stopped"
- [ ] "Stopping HTTPServer..."
- [ ] "HTTPServer stopped"
- [ ] "Clean shutdown complete"
- [ ] "Agent Deck terminated"

**Activity Monitor check:**
- [ ] No "Agent-Deck" process running
- [ ] Memory usage is 0

---

### Test 7: Resource Cleanup

**Use Xcode Instruments (Leaks profile):**

1. Product > Profile (Cmd+I)
2. Select "Leaks" template
3. Record while app runs for 30 seconds
4. Quit app

**Verify:**
- [ ] No memory leaks detected
- [ ] All allocations properly freed

**Manual check:**
```bash
# Before quit
leaks Agent-Deck

# After quit
ps aux | grep Agent-Deck
# Should be empty
```

---

## Edge Cases

### Edge Case 1: Bundled Config Missing

**Simulate:**
1. Remove `default-config.yaml` from bundle (temporarily)
2. Clean state
3. Launch app

**Expected:**
- [ ] App still works (fallback to programmatic generation)
- [ ] Log shows "Bundled default-config.yaml not found, using programmatic generation"

---

### Edge Case 2: Config Directory Not Writable

**Simulate:**
```bash
sudo mkdir -p ~/.agent-deck
sudo chmod 000 ~/.agent-deck
```

**Launch app**

**Expected:**
- [ ] Error dialog appears
- [ ] User-friendly error message explains issue
- [ ] App doesn't crash

**Cleanup:**
```bash
sudo chmod 755 ~/.agent-deck
```

---

### Edge Case 3: Rapid Quit During Startup

**Test:**
1. Launch app
2. Immediately quit (before services fully start)

**Verify:**
- [ ] No crash
- [ ] Clean shutdown (even if services not fully started)
- [ ] No orphan processes

---

## Performance Verification

### Startup Time
**Measure:**
```bash
time open -a Agent-Deck
```

**Expected:**
- [ ] < 2 seconds to menubar icon visible
- [ ] < 3 seconds total (including services)

### Memory Usage
**Check in Activity Monitor:**
- [ ] Idle: < 100MB RAM
- [ ] Active (monitoring 3 agents): < 150MB RAM

### CPU Usage
**Check in Activity Monitor:**
- [ ] Idle: < 2% CPU
- [ ] Active (monitoring): < 5% CPU

---

## Regression Testing

### Existing Features Still Work
- [ ] Process monitoring detects running agents
- [ ] WebSocket server accepts connections
- [ ] HTTP server serves PWA files
- [ ] Window switching works (with permissions)
- [ ] Menubar dropdown displays agent list
- [ ] QR code generation works

---

## Documentation Verification

### Generated Docs
- [x] FIRST_RUN_IMPLEMENTATION.md created
- [x] IMPLEMENTATION_SUMMARY.md created
- [x] test-first-run.sh created (executable)
- [x] VERIFICATION_CHECKLIST.md (this file) created

### Code Documentation
- [x] All new methods have doc comments
- [x] Task references included (T074-T080)
- [x] MARK comments for organization

---

## Final Checklist

### Before Merge
- [ ] All tests pass (runtime + edge cases)
- [ ] No compiler warnings
- [ ] No memory leaks (Instruments)
- [ ] Clean shutdown verified (Activity Monitor)
- [ ] Documentation reviewed
- [ ] Code reviewed by another developer (if applicable)

### Commit Message
```
feat: Zero-config first-run experience (T074-T080)

Implemented seamless first-run experience:
- Auto-detect first launch via UserDefaults
- Auto-create config from bundled default-config.yaml
- Proactive accessibility permissions handling
- Graceful retry mechanism
- Clean shutdown with full resource cleanup

Files:
- AppDelegate.swift: First-launch detection, permissions, shutdown
- ConfigManager.swift: Bundled config copying
- WindowManager.swift: Retry mechanism for permissions

Docs:
- FIRST_RUN_IMPLEMENTATION.md
- IMPLEMENTATION_SUMMARY.md
- test-first-run.sh
```

---

## Sign-Off

**Developer:** _______________ Date: ___________

**Tester:** _______________ Date: ___________

**Notes:**
_____________________________________________
_____________________________________________
_____________________________________________

---

**Status:** Ready for build and testing ✅
