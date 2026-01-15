# Agent Deck - Test Checklist

**Version:** 1.0
**Last Updated:** 2025-11-25
**Purpose:** Comprehensive manual test checklist for Agent Deck MVP validation

---

## Automated Tests ✅

**Run these first before manual testing:**

```bash
# 1. TypeScript type checking (mobile app)
cd apps/mobile && npx tsc --noEmit

# 2. Shared types type checking
cd packages/shared-types && pnpm typecheck

# 3. pnpm installation
pnpm install --frozen-lockfile

# 4. Smoke test scripts (automated integration)
./test-cli-detection.sh      # Claude Code detection
./test-first-run.sh           # First launch sequence
./test-latency.sh            # <500ms status update SLA
./test-multi-instance.sh     # Multiple Claude instances
./test-resilience.sh         # Network interruption handling
./test-stability.sh          # 24-hour stability test
./test-window-switch.sh      # <1s window focus SLA
```

**Expected Results:**
- ✅ TypeScript compilation: No errors
- ✅ pnpm install: All dependencies installed
- ✅ Smoke tests: All PASS

---

## Test Environment Setup

### Prerequisites
- **macOS:** 12+ (Monterey or later)
- **Xcode:** 15.0+ for Swift 6 support
- **Claude Code:** Latest version from claude.ai/code
- **Node.js:** 18+ (for React Native mobile app)
- **pnpm:** 8+ installed globally
- **Physical Android Device:** Pixel 7a preferred (ADB serial: `35051JEHN13181`)
  - Or Android Emulator: `Medium_Phone_API_36.1`
- **Network:** Mac and mobile on same WiFi

### Setup Steps
1. Install Agent Deck Mac app (build from Xcode)
2. Install React Native app on Android device:
   ```bash
   cd apps/mobile
   npx expo start --android
   ```
3. Grant Accessibility permissions (System Settings → Privacy & Security → Accessibility)
4. Verify port 3000 is available: `lsof -i :3000`

---

## Manual Test Checklist

### T118: Mac App Launch ⏱️ 2 minutes

**Test ID:** T118
**Priority:** Critical
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify Mac app launches and appears in Dock within target time

**Prerequisites:**
- Xcode build successful
- Clean macOS system (or fresh install)

**Test Steps:**
1. Double-click Agent-Deck.app from Applications folder
2. Start timer when app icon is clicked
3. Watch for Dock icon to appear
4. Verify window opens (since it's a dock app now)

**Expected Results:**
- ✅ App launches without errors
- ✅ Dock icon appears within **2 seconds**
- ✅ Standard window opens and is functional
- ✅ No console errors in Console.app

**Pass Criteria:**
- Launch time < 2 seconds
- No crash or freeze
- Dock icon visible and clickable

**Fail Conditions:**
- ❌ Launch time > 2 seconds
- ❌ App crashes on launch
- ❌ No window appears
- ❌ Console shows errors

**Troubleshooting:**
- Check Console.app for crash logs
- Verify code signing: `codesign -vv Agent-Deck.app`
- Check Info.plist for LSUIElement (should be false for dock app)

---

### T119: Claude Code Process Detection ⏱️ 5 minutes

**Test ID:** T119
**Priority:** Critical
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify Agent Deck detects multiple Claude Code instances with different working directories

**Prerequisites:**
- Agent Deck running
- Multiple terminal windows available

**Test Steps:**
1. Terminal 1: `cd ~/projects/app-001-famrally && claude`
2. Wait 2 seconds
3. Check Agent Deck window - should show 1 instance
4. Terminal 2: `cd ~/projects/app-009-agent-deck && claude`
5. Wait 2 seconds
6. Check Agent Deck window - should show 2 instances
7. Terminal 3: `cd ~/Documents && claude`
8. Wait 2 seconds
9. Check Agent Deck window - should show 3 instances

**Expected Results:**
- ✅ Each Claude instance detected within 2 seconds
- ✅ Correct working directory shown for each
- ✅ Each instance has unique PID
- ✅ Status shows "idle" initially

**Pass Criteria:**
- All 3 instances detected
- Working directories match terminal paths
- PIDs unique and correct

**Fail Conditions:**
- ❌ Instance not detected after 5 seconds
- ❌ Working directory incorrect
- ❌ Duplicate PIDs
- ❌ Missing instances

**Troubleshooting:**
- Check ProcessMonitor.swift logs
- Verify `ps aux | grep claude` shows processes
- Check FSEvents is monitoring ~/.claude/projects/

---

### T120: Status Update Latency ⏱️ 10 minutes

**Test ID:** T120
**Priority:** Critical (SLA: <500ms)
**Phase:** Integration Testing (Phase 9)

**Objective:** Validate status updates propagate from Mac to mobile within 500ms

**Prerequisites:**
- Agent Deck running (Mac + Android mobile connected)
- Claude Code instance active
- Mobile app showing connection status

**Test Steps:**
1. Start timer when Claude Code starts task
2. Ask Claude: "Create a todo list with 3 items and start working"
3. Watch mobile app for status change from "idle" → "working"
4. Stop timer when mobile shows "working"
5. Repeat 10 times with different tasks

**Expected Results:**
- ✅ Status update appears within **500ms** (95th percentile)
- ✅ Status accurate (matches Claude's actual state)
- ✅ No dropped updates

**Pass Criteria:**
- 95% of updates < 500ms
- 100% of updates < 1000ms
- No visual lag or stuttering

**Fail Conditions:**
- ❌ Any update > 1000ms
- ❌ <95% updates within 500ms target
- ❌ Status shows wrong state
- ❌ Mobile app freezes

**Automated Test:**
```bash
./test-latency.sh
# Runs 100 iterations, reports P50/P95/P99 latencies
```

**Troubleshooting:**
- Check WebSocket connection (should be ws://, not polling)
- Verify no network congestion (ping Mac from mobile)
- Check ProcessMonitor polling interval (should be 500ms)

---

### T121: Window Switching Latency ⏱️ 3 minutes

**Test ID:** T121
**Priority:** Critical (SLA: <1s)
**Phase:** Integration Testing (Phase 9)

**Objective:** Validate window focus happens within 1 second of mobile tap

**Prerequisites:**
- Agent Deck running with 2+ Claude instances
- Mobile app connected and showing agents
- Multiple Claude windows open in different Spaces (macOS virtual desktops)

**Test Steps:**
1. Focus on Terminal window (not Claude)
2. On mobile, tap first agent card
3. Start timer at moment of tap
4. Watch Mac screen for Claude window focus
5. Stop timer when Claude window becomes active
6. Repeat with second agent
7. Test cross-Space switching (if Claude in different Space)

**Expected Results:**
- ✅ Window switches within **1 second**
- ✅ Correct Claude window focused (matching tapped agent)
- ✅ Works across macOS Spaces
- ✅ Mobile shows success toast

**Pass Criteria:**
- 100% of switches < 1 second
- Correct window focused every time
- Cross-Space switching works

**Fail Conditions:**
- ❌ Any switch > 1 second
- ❌ Wrong window focused
- ❌ Cross-Space switching fails
- ❌ No visual feedback on mobile

**Automated Test:**
```bash
./test-window-switch.sh
# Measures tap → focus latency
```

**Troubleshooting:**
- Verify Accessibility permissions granted
- Check AppleScript execution time in logs
- Test cross-Space manually: System Settings → Desktop & Dock → Mission Control

---

### T122: Cross-macOS Space Window Switching ⏱️ 5 minutes

**Test ID:** T122
**Priority:** High
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify window switching works across macOS virtual desktops (Spaces)

**Prerequisites:**
- Multiple Spaces enabled (Mission Control)
- Claude instances in different Spaces
- Agent Deck running

**Test Steps:**
1. Enable Mission Control with 3 Spaces
2. Space 1: Claude instance A
3. Space 2: Claude instance B
4. Space 3: Agent Deck window
5. On mobile, tap agent A card (in Space 1)
6. Verify Mac switches to Space 1 and focuses window
7. Tap agent B card (in Space 2)
8. Verify Mac switches to Space 2 and focuses window

**Expected Results:**
- ✅ Mac switches to correct Space
- ✅ Window focused in target Space
- ✅ Transition smooth (no flashing)
- ✅ Works in both directions (Space 1→2, Space 2→1)

**Pass Criteria:**
- Cross-Space switching successful
- Latency still < 1 second
- No UI glitches

**Fail Conditions:**
- ❌ Space switch fails
- ❌ Wrong Space activated
- ❌ Window not focused after Space switch
- ❌ Visual artifacts or flashing

**Troubleshooting:**
- Check WindowManager.swift AppleScript logic
- Verify Mission Control settings (System Settings → Desktop & Dock)
- Test manually with AppleScript: `osascript -e 'tell application...'`

---

### T123: QR Code Scanning and Connection ⏱️ 2 minutes

**Test ID:** T123
**Priority:** Critical
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify mobile app can scan QR code and connect to Mac within 60 seconds

**Prerequisites:**
- Agent Deck Mac app running
- React Native mobile app installed on Android device
- Both devices on same WiFi

**Test Steps:**
1. Open Agent Deck Mac app
2. Click "View Mobile Interface" (or equivalent menu item)
3. QR code appears in window
4. Open mobile app on Android device
5. Tap "Scan QR Code" button
6. Point camera at QR code on Mac screen
7. Wait for scan and connection

**Expected Results:**
- ✅ QR code visible and scannable
- ✅ Mobile app scans within 5 seconds
- ✅ WebSocket connection established within 10 seconds
- ✅ Agent list appears on mobile
- ✅ Total time < 60 seconds

**Pass Criteria:**
- QR scan successful
- Connection established
- Agent data visible on mobile
- Total time < 60 seconds

**Fail Conditions:**
- ❌ QR code not visible or blurry
- ❌ Scan fails after 3 attempts
- ❌ Connection timeout (>10 seconds)
- ❌ Agent data not appearing

**Troubleshooting:**
- Verify same WiFi network: `ifconfig | grep inet` (Mac) and check Android WiFi settings
- Check port 3000 open: `lsof -i :3000`
- Test manual URL entry: http://<mac-ip>:3000
- Check QRGenerator.swift for correct URL format

---

### T124: React Native App on iOS (Real Device) ⏱️ 10 minutes

**Test ID:** T124
**Priority:** High
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify React Native app works on physical iOS device (iPhone 14+)

**Prerequisites:**
- iPhone with iOS 14+ (physical device, not simulator)
- Xcode and iOS dev tools installed
- React Native app built for iOS

**Test Steps:**
1. Connect iPhone via USB
2. Run: `cd apps/mobile && npx expo start --ios --device`
3. Accept trust dialog on iPhone
4. Wait for app to install and launch
5. Test QR code scanning
6. Test agent list display
7. Test window switching via tap
8. Test keep-awake toggle
9. Test pull-to-refresh

**Expected Results:**
- ✅ App installs without errors
- ✅ Camera permissions granted
- ✅ QR scanning works
- ✅ Agent list displays correctly
- ✅ Tap interactions responsive (<100ms)
- ✅ No crashes or freezes

**Pass Criteria:**
- All features functional on iOS
- Performance smooth (60fps)
- No visual glitches

**Fail Conditions:**
- ❌ App crashes on launch
- ❌ Camera doesn't open
- ❌ UI elements misaligned
- ❌ Touch targets too small (<44px)

**Troubleshooting:**
- Check Expo logs: `npx expo start --ios --device`
- Verify iOS version compatibility
- Test on iOS Simulator first: `npx expo start --ios`

---

### T125: React Native App on Android (Real Device) ⏱️ 10 minutes

**Test ID:** T125
**Priority:** Critical
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify React Native app works on physical Android device (API 21+)

**Prerequisites:**
- **Pixel 7a connected via USB** (preferred: ADB serial `35051JEHN13181`)
  - Or Android emulator `Medium_Phone_API_36.1`
- Android SDK and platform-tools installed
- USB debugging enabled on device

**Test Steps:**
1. Connect Pixel 7a via USB
2. Verify device: `adb devices` (should show `35051JEHN13181`)
3. Run: `cd apps/mobile && npx expo start --android --clear`
4. Wait for app to install on device
5. Test all features (QR scan, agent list, window switch, etc.)

**Expected Results:**
- ✅ App installs and launches on Pixel 7a
- ✅ All features work as expected
- ✅ Performance smooth (60fps)
- ✅ No ANR (Application Not Responding) errors

**Pass Criteria:**
- Physical device (Pixel 7a) tests passing
- All features functional
- No crashes

**Fallback (if Pixel 7a unavailable):**
- Use Android emulator: `$ANDROID_HOME/emulator/emulator -avd "Medium_Phone_API_36.1" &`

**Fail Conditions:**
- ❌ App doesn't install
- ❌ Crashes on launch
- ❌ UI rendering issues
- ❌ Touch delays (>100ms)

**Troubleshooting:**
- Check ADB connection: `adb devices`
- If device not detected: `adb kill-server && adb start-server`
- Check Expo logs in terminal
- Verify Android SDK path: `echo $ANDROID_HOME`

---

### T126: Multiple Concurrent Claude Instances ⏱️ 15 minutes

**Test ID:** T126
**Priority:** High
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify Agent Deck handles 3-10 concurrent Claude Code instances

**Prerequisites:**
- Agent Deck running
- 10 terminal windows available

**Test Steps:**
1. Launch 3 Claude Code instances in different directories
2. Verify all 3 appear in Agent Deck
3. Launch 4 more instances (total: 7)
4. Verify all 7 detected and tracked
5. Launch 3 more instances (total: 10)
6. Verify all 10 tracked independently
7. Work in each instance (create todos, trigger subagents)
8. Verify data doesn't mix between instances
9. Kill 5 instances (random)
10. Verify remaining 5 still tracked correctly

**Expected Results:**
- ✅ All 10 instances detected
- ✅ Each instance tracked independently (no data mixing)
- ✅ Mac app responsive (<5% CPU)
- ✅ Mobile app displays all instances
- ✅ Removing instances cleans up correctly

**Pass Criteria:**
- 10 instances handled without performance degradation
- CPU usage < 5% (measured via Activity Monitor)
- Memory usage < 200MB total
- No data corruption

**Fail Conditions:**
- ❌ Instances not detected after 5 seconds
- ❌ Data mixing between instances
- ❌ CPU usage > 10%
- ❌ Memory leak (growing usage over time)

**Automated Test:**
```bash
./test-multi-instance.sh
# Spawns 10 Claude instances, monitors resource usage
```

**Troubleshooting:**
- Check ProcessMonitor.swift for polling overhead
- Verify FSEvents not watching too many directories
- Use Instruments (Xcode) to profile memory usage

---

### T127: Multiple Concurrent React Native Clients ⏱️ 10 minutes

**Test ID:** T127
**Priority:** Medium
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify Mac app handles 1-5 simultaneous mobile connections

**Prerequisites:**
- Agent Deck Mac app running
- 5 mobile devices (or simulators/emulators)

**Test Steps:**
1. Connect mobile device 1 via QR scan
2. Verify connection status "connected"
3. Connect mobile device 2
4. Verify both show same agent list
5. Connect devices 3, 4, 5
6. Verify all 5 receive updates simultaneously
7. Trigger status change (Claude starts task)
8. Verify all 5 devices update within 500ms
9. Disconnect device 3
10. Verify remaining 4 still receive updates

**Expected Results:**
- ✅ All 5 connections accepted
- ✅ All devices receive identical data
- ✅ Status updates broadcast to all clients
- ✅ Disconnection doesn't affect other clients
- ✅ CPU usage < 10% with 5 clients

**Pass Criteria:**
- 5 concurrent connections stable
- No dropped updates
- Latency < 500ms for all clients

**Fail Conditions:**
- ❌ Connection limit < 5
- ❌ Updates delayed or dropped
- ❌ One disconnect affects others
- ❌ CPU usage > 15%

**Troubleshooting:**
- Check WebSocketServer.swift connection management
- Verify no hardcoded client limits
- Use `lsof -i :3000` to see active connections

---

### T128: Network Interruption and Auto-Reconnection ⏱️ 8 minutes

**Test ID:** T128
**Priority:** Critical
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify mobile app auto-reconnects within 5 seconds after network interruption

**Prerequisites:**
- Agent Deck Mac + React Native mobile connected
- Ability to control WiFi (toggle on/off)

**Test Steps:**
1. Establish connection (mobile showing agents)
2. On mobile device, turn WiFi OFF
3. Wait 2 seconds
4. Verify mobile shows "disconnected" status
5. Turn WiFi back ON
6. Start timer
7. Watch for auto-reconnect
8. Stop timer when "connected" status returns
9. Verify agent list re-populated

**Expected Results:**
- ✅ Mobile detects disconnect within 2 seconds
- ✅ Shows "disconnected" status with reconnect indicator
- ✅ Auto-reconnects within **5 seconds** of WiFi restore
- ✅ Agent data re-synced automatically
- ✅ No manual intervention required

**Pass Criteria:**
- Reconnect time < 5 seconds
- No data loss after reconnect
- Exponential backoff visible (1s, 2s, 4s attempts)

**Fail Conditions:**
- ❌ No auto-reconnect (stuck disconnected)
- ❌ Reconnect > 5 seconds
- ❌ Agent data not re-synced
- ❌ App crashes on disconnect

**Automated Test:**
```bash
./test-resilience.sh
# Simulates network interruptions
```

**Troubleshooting:**
- Check useWebSocket.ts reconnection logic
- Verify exponential backoff: 1s → 2s → 4s → 8s → 16s max
- Check WebSocket onClose handler

---

### T129: Mac Sleep/Wake Cycle ⏱️ 5 minutes

**Test ID:** T129
**Priority:** Medium
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify Agent Deck survives Mac sleep/wake without losing connections

**Prerequisites:**
- Agent Deck running with mobile connected
- Claude instances active

**Test Steps:**
1. Verify mobile showing agents and connected status
2. Put Mac to sleep (Apple menu → Sleep, or close laptop lid)
3. Wait 30 seconds
4. Wake Mac (press key or open lid)
5. Wait 5 seconds
6. Check mobile app reconnection
7. Verify agent list still visible
8. Trigger status update (Claude task)
9. Verify mobile receives update

**Expected Results:**
- ✅ Mac wakes up without errors
- ✅ Agent Deck restarts monitoring
- ✅ Mobile auto-reconnects within 5 seconds
- ✅ Agent data still accurate
- ✅ Updates resume flowing

**Pass Criteria:**
- No crashes after wake
- Reconnection < 5 seconds
- Data consistency maintained

**Fail Conditions:**
- ❌ Agent Deck crashes on wake
- ❌ Mobile can't reconnect
- ❌ Agent data stale or corrupted
- ❌ Updates stop flowing

**Troubleshooting:**
- Check AppDelegate sleep/wake notifications
- Verify ProcessMonitor resumes polling
- Check WebSocket server restart logic

---

### T130: Process Termination While Monitored ⏱️ 3 minutes

**Test ID:** T130
**Priority:** High
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify Agent Deck cleanly removes instances when Claude Code terminates

**Prerequisites:**
- Agent Deck running
- 2+ Claude instances active
- Mobile app connected

**Test Steps:**
1. Verify mobile shows 2 instances
2. In Terminal 1, kill Claude: `Ctrl+C` or close Terminal window
3. Start timer
4. Watch mobile app
5. Verify instance 1 disappears from list
6. Stop timer when UI updates
7. Verify instance 2 still visible and functional

**Expected Results:**
- ✅ Instance removed from list within **2-4 seconds**
- ✅ Mobile UI updates (instance disappears)
- ✅ Other instances unaffected
- ✅ No "zombie" processes left

**Pass Criteria:**
- Removal time < 5 seconds
- Clean UI update
- No orphaned data

**Fail Conditions:**
- ❌ Instance persists after process killed
- ❌ Removal time > 10 seconds
- ❌ Other instances affected
- ❌ Crash or error in Agent Deck

**Troubleshooting:**
- Check ProcessMonitor instance removal logic
- Verify FSEvents detects transcript file changes/deletion
- Check for memory leaks: `leaks Agent-Deck`

---

### T131: Port 3000 Already in Use ⏱️ 2 minutes

**Test ID:** T131
**Priority:** Medium
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify Agent Deck handles port conflict gracefully

**Prerequisites:**
- No processes using port 3000
- Agent Deck not running

**Test Steps:**
1. Start a test server on port 3000: `python3 -m http.server 3000`
2. Launch Agent Deck Mac app
3. Watch for error message
4. Verify error message is actionable
5. Kill test server: `Ctrl+C`
6. Restart Agent Deck
7. Verify it works on port 3000

**Expected Results:**
- ✅ Agent Deck detects port conflict
- ✅ Shows error dialog with clear message
- ✅ Suggests solution (kill process or change port)
- ✅ App doesn't crash
- ✅ After port freed, app works normally

**Pass Criteria:**
- Error message clear and actionable
- No silent failure
- Recovery possible

**Fail Conditions:**
- ❌ App crashes without error
- ❌ Error message unclear
- ❌ No suggestion for resolution
- ❌ App can't recover after port freed

**Error Message Should Say:**
```
Port 3000 is already in use by another application.

Solutions:
1. Quit the app using port 3000 (check Activity Monitor)
2. Or change Agent Deck's port in Settings

To find the process: lsof -i :3000
```

**Troubleshooting:**
- Check WebSocketServer.swift error handling
- Verify NWListener error callbacks
- Test with Settings → change port functionality

---

### T132: Different WiFi Networks Error Handling ⏱️ 3 minutes

**Test ID:** T132
**Priority:** Medium
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify clear error when Mac and mobile on different networks

**Prerequisites:**
- Mac on WiFi network A
- Mobile on WiFi network B (or cellular)
- Agent Deck running

**Test Steps:**
1. Mac connected to "Home WiFi"
2. Mobile connected to "Guest WiFi" (different network)
3. Scan QR code on mobile
4. Attempt connection
5. Watch for error message
6. Verify error message explains issue
7. Switch mobile to "Home WiFi"
8. Re-scan QR code
9. Verify connection succeeds

**Expected Results:**
- ✅ Connection fails with timeout
- ✅ Error message explains "different networks"
- ✅ Suggests connecting to same WiFi
- ✅ After network switch, connection works

**Pass Criteria:**
- Error message clear
- Troubleshooting steps provided
- Connection works after fix

**Fail Conditions:**
- ❌ Silent failure (infinite loading)
- ❌ Generic "connection failed" error
- ❌ No guidance on resolution

**Error Message Should Say:**
```
Unable to connect to Agent Deck.

Possible causes:
- Mac and mobile on different WiFi networks
- Mac firewall blocking port 3000
- Agent Deck not running on Mac

Troubleshooting:
1. Verify both devices on same WiFi network
2. Check Mac firewall settings
3. Restart Agent Deck Mac app
```

**Troubleshooting:**
- Check useWebSocket.ts timeout and error handling
- Add network diagnostics in mobile app
- Verify WebSocket connection error messages

---

### T133: Accessibility Permissions Missing ⏱️ 2 minutes

**Test ID:** T133
**Priority:** High
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify clear error when Accessibility permissions not granted

**Prerequisites:**
- Fresh Agent Deck install (Accessibility not granted)
- Claude instance running
- Mobile app connected

**Test Steps:**
1. On mobile, tap agent card to switch windows
2. Watch Mac for permission dialog
3. If no dialog, check mobile for error
4. Click "Deny" or "Later" (don't grant yet)
5. Verify error message on mobile
6. Grant Accessibility in System Settings
7. Retry window switch
8. Verify success

**Expected Results:**
- ✅ Permission dialog appears first time
- ✅ If denied, clear error message shown
- ✅ Error explains how to grant permission
- ✅ After granting, window switch works

**Pass Criteria:**
- Permission request at appropriate time
- Error message actionable
- Recovery after granting permission

**Fail Conditions:**
- ❌ No permission request
- ❌ Generic "failed" error
- ❌ No instructions for granting permission

**Error Message Should Say:**
```
Window switching requires Accessibility permission.

To enable:
1. Open System Settings
2. Go to Privacy & Security → Accessibility
3. Enable "Agent Deck"
4. Try switching again
```

**Troubleshooting:**
- Check WindowManager.swift permission check
- Verify AppleScript error codes
- Test permission request timing (first window switch)

---

### T134: Mac App Resource Usage ⏱️ 30 minutes

**Test ID:** T134
**Priority:** High
**Phase:** Integration Testing (Phase 9)

**Objective:** Validate resource usage within targets (<100MB RAM, <2% CPU idle, <5% CPU active)

**Prerequisites:**
- Agent Deck running
- 3 Claude instances active
- Activity Monitor open

**Test Steps:**
1. Launch Agent Deck with 3 Claude instances
2. Open Activity Monitor
3. Find "Agent-Deck" process
4. Record baseline memory (idle)
5. Trigger multiple status updates (Claude tasks)
6. Record peak memory (active)
7. Let idle for 10 minutes
8. Record CPU usage (idle)
9. Trigger rapid updates
10. Record CPU usage (active)

**Expected Results:**
- ✅ Memory usage < **100MB** (idle and active)
- ✅ CPU usage < **2%** (idle)
- ✅ CPU usage < **5%** (active)
- ✅ No memory leaks (usage stable over time)

**Pass Criteria:**
- All metrics within targets
- No growth in memory over 30 minutes
- CPU returns to <2% when idle

**Fail Conditions:**
- ❌ Memory > 100MB
- ❌ CPU > 2% idle or > 5% active
- ❌ Memory grows continuously
- ❌ CPU stays high when idle

**Automated Test:**
```bash
./test-stability.sh
# Monitors resource usage over 24 hours
```

**Troubleshooting:**
- Use Xcode Instruments for detailed profiling
- Check for retain cycles in Swift code
- Verify polling interval not too aggressive
- Profile WebSocket message overhead

---

### T135: 24-Hour Stability Test ⏱️ 24 hours

**Test ID:** T135
**Priority:** Critical
**Phase:** Integration Testing (Phase 9)

**Objective:** Verify no crashes, memory leaks, or degradation over 24 hours

**Prerequisites:**
- Agent Deck running
- 2-3 Claude instances active
- Mobile app connected
- Mac stays awake (pmset displaysleepnow disabled)

**Test Steps:**
1. Start Agent Deck at 9am Monday
2. Leave running with 2-3 active Claude sessions
3. Periodically check (every 4 hours):
   - Memory usage (Activity Monitor)
   - CPU usage
   - Connection status (mobile)
   - Agent list accuracy
4. Log any errors or anomalies
5. Check again at 9am Tuesday (24 hours later)

**Expected Results:**
- ✅ No crashes over 24 hours
- ✅ Memory usage stable (no leaks)
- ✅ CPU usage stable
- ✅ Mobile connection maintained (or auto-reconnects)
- ✅ Agent data accurate

**Pass Criteria:**
- Zero crashes
- Memory growth < 10MB over 24 hours
- Mobile auto-reconnects after any interruptions
- Data accuracy maintained

**Fail Conditions:**
- ❌ Any crash or hang
- ❌ Memory leak (>50MB growth)
- ❌ CPU usage creep (>10%)
- ❌ Connection lost and not recovered

**Automated Test:**
```bash
./test-stability.sh --duration 24h
# Runs for 24 hours, logs metrics every 15 minutes
```

**Troubleshooting:**
- Check Console.app for crash logs
- Use leaks tool: `leaks Agent-Deck`
- Profile with Instruments (Leaks, Allocations)
- Review FSEvents file descriptor usage

---

### T136: Fix Critical Bugs ⏱️ Variable

**Test ID:** T136
**Priority:** Critical
**Phase:** Integration Testing (Phase 9)

**Objective:** Address any critical bugs discovered during T118-T135

**Prerequisites:**
- Tests T118-T135 completed
- Bugs documented with repro steps

**Test Steps:**
1. Review all test failures from T118-T135
2. Prioritize critical bugs (P0):
   - Crashes
   - Data loss
   - Security issues
   - SLA violations (>500ms, >1s)
3. For each critical bug:
   - Reproduce reliably
   - Identify root cause
   - Implement fix
   - Test fix with original test case
   - Re-run affected tests (T118-T135)

**Expected Results:**
- ✅ All critical bugs fixed
- ✅ Affected tests now passing
- ✅ No regressions introduced

**Pass Criteria:**
- 100% of critical bugs resolved
- No new bugs introduced by fixes

**Fail Conditions:**
- ❌ Critical bug still reproduces
- ❌ Fix introduces regression
- ❌ Tests still failing

**Troubleshooting:**
- Use debugger (lldb) for crashes
- Add logging for hard-to-reproduce issues
- Consult LESSONS_LEARNED.md for known patterns

---

### T137: Optimize Performance Bottlenecks ⏱️ Variable

**Test ID:** T137
**Priority:** High
**Phase:** Integration Testing (Phase 9)

**Objective:** Optimize any performance issues found in T118-T135

**Prerequisites:**
- Tests T118-T135 completed
- Performance metrics documented (latency, CPU, memory)

**Test Steps:**
1. Identify performance failures:
   - Status update > 500ms
   - Window switch > 1s
   - CPU > 5% active
   - Memory > 100MB
2. Profile with Xcode Instruments
3. Identify bottlenecks (hot paths)
4. Optimize:
   - Reduce polling frequency if appropriate
   - Batch WebSocket messages
   - Optimize JSON parsing
   - Cache expensive operations
5. Re-run affected tests
6. Verify improvements

**Expected Results:**
- ✅ All SLA targets met (500ms, 1s, 2% CPU, 100MB RAM)
- ✅ Performance improvements measurable
- ✅ No functional regressions

**Pass Criteria:**
- 95th percentile latency < 500ms
- 99th percentile latency < 1s
- CPU/memory within targets

**Fail Conditions:**
- ❌ SLA still violated after optimization
- ❌ Optimization breaks functionality

**Tools:**
- Xcode Instruments (Time Profiler, Allocations)
- `./test-latency.sh` for before/after comparison
- Network Link Conditioner for simulating slow networks

---

## Test Summary Report Template

After completing all tests, fill out this summary:

```markdown
# Agent Deck Test Run Summary

**Date:** YYYY-MM-DD
**Tester:** [Your Name]
**Build Version:** [Git commit hash or version]
**Platform:** macOS [version], iOS [version], Android [version]

## Automated Tests
- TypeScript compilation: ✅ PASS / ❌ FAIL
- pnpm install: ✅ PASS / ❌ FAIL
- test-cli-detection.sh: ✅ PASS / ❌ FAIL
- test-first-run.sh: ✅ PASS / ❌ FAIL
- test-latency.sh: ✅ PASS / ❌ FAIL (P95: Xms)
- test-multi-instance.sh: ✅ PASS / ❌ FAIL
- test-resilience.sh: ✅ PASS / ❌ FAIL
- test-stability.sh: ✅ PASS / ❌ FAIL
- test-window-switch.sh: ✅ PASS / ❌ FAIL (P95: Xms)

## Manual Tests (T118-T137)
| Test ID | Name | Result | Notes |
|---------|------|--------|-------|
| T118 | Mac App Launch | ✅ PASS | Launch time: 1.2s |
| T119 | Claude Detection | ✅ PASS | All 3 instances detected |
| T120 | Status Latency | ✅ PASS | P95: 320ms |
| T121 | Window Switch | ✅ PASS | P95: 780ms |
| T122 | Cross-Space Switch | ✅ PASS | Works in both directions |
| T123 | QR Code Scan | ✅ PASS | Total time: 45s |
| T124 | iOS Real Device | ⚠️ SKIP | No iOS device available |
| T125 | Android Device | ✅ PASS | Pixel 7a working |
| T126 | Multi-Instance | ✅ PASS | 10 instances handled |
| T127 | Multi-Client | ✅ PASS | 5 clients connected |
| T128 | Auto-Reconnect | ✅ PASS | Reconnect in 3s |
| T129 | Sleep/Wake | ✅ PASS | No issues after wake |
| T130 | Process Term | ✅ PASS | Cleanup in 2.1s |
| T131 | Port Conflict | ✅ PASS | Clear error message |
| T132 | Network Error | ✅ PASS | Helpful troubleshooting |
| T133 | Accessibility | ✅ PASS | Permission flow works |
| T134 | Resource Usage | ✅ PASS | 78MB RAM, 1.8% CPU idle |
| T135 | 24h Stability | ✅ PASS | No crashes, stable memory |
| T136 | Critical Bugs | ✅ PASS | 0 critical bugs found |
| T137 | Optimization | ✅ PASS | All SLAs met |

## Overall Result
- **Tests Run:** 20 / 20
- **Tests Passed:** 19 / 20
- **Tests Failed:** 0 / 20
- **Tests Skipped:** 1 / 20 (iOS device unavailable)

## Critical Issues
1. [None found]

## Recommendations
1. [Any suggestions for improvements]

## Sign-Off
✅ **MVP READY FOR DEPLOYMENT**

Tested by: _______________  Date: __________
```

---

## Quick Test (Smoke Test) - 10 Minutes

**For rapid validation before deployment:**

```bash
# 1. Automated tests (3 min)
pnpm install && cd apps/mobile && npx tsc --noEmit
./test-latency.sh --quick

# 2. Manual smoke test (7 min)
# - Launch Mac app (T118)
# - Start Claude Code (T119)
# - Scan QR code on Android (T123)
# - Tap agent card (T121)
# - Check resource usage (T134)

# If all pass → Deploy
# If any fail → Run full test suite
```

---

## Notes

- **Automated tests first:** Always run automated tests before manual tests
- **Priority order:** Critical tests (T118-T121, T125, T134-T136) must pass before deployment
- **Android device priority:** Always test on Pixel 7a (physical device) before falling back to emulator
- **SLA validation:** Use automated scripts (test-latency.sh, test-window-switch.sh) for precise measurements
- **Documentation:** Record all test results, especially failures, for future reference
- **Continuous testing:** Re-run critical tests (T118-T121) after any code changes

---

**Document Version:** 1.0
**Maintainer:** Agent Deck Team
**Last Review:** 2025-11-25
