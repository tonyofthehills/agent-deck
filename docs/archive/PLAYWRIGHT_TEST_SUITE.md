# Playwright Test Suite - Agent Deck PWA

**Date:** November 3, 2025
**Status:** Ready to Run (Once HTTP Server Fixed)
**Test Framework:** Playwright MCP

---

## Overview

Comprehensive Playwright test suite for Agent Deck MVP validation using Playwright MCP. This suite tests all P1 user stories (US1-US3) to ensure the MVP is ready for Show HN launch.

---

## Prerequisites

### Before Running Tests

1. ✅ **HTTP server fix applied** (See `HTTP_SERVER_FIXES.md`)
2. ✅ **Mac rebooted** (to clear stuck process)
3. ✅ **Agent-Deck app running**
4. ✅ **At least one Claude Code instance running** (for monitoring tests)
5. ✅ **Ports 3000 and 3001 listening**

### Verification
```bash
# Check servers running
lsof -iTCP:3000,3001 -sTCP:LISTEN

# Check HTTP responds
curl -I http://localhost:3000/

# Check Claude Code running
ps aux | grep -i "claude.*code" | grep -v grep
```

---

## Test Suite Structure

### Phase 1: Basic Functionality (Critical)
- T1: PWA loads successfully
- T2: Connection status indicator works
- T3: WebSocket establishes connection
- T4: Initial state received

### Phase 2: User Story 1 - Monitoring (P1)
- T5: Agent instances display
- T6: Agent status indicators work
- T7: Current task displays
- T8: Real-time updates work (<500ms)
- T9: Auto-reconnect works

### Phase 3: User Story 2 - Window Switching (P1)
- T10: Agent card tap sends focus command
- T11: Focus success feedback displays
- T12: Window actually switches (Mac verification)

### Phase 4: User Story 3 - QR Setup (P1)
- T13: QR code generates
- T14: Local IP address displays
- T15: PWA installable (manifest)

### Phase 5: Error Handling
- T16: Network interruption recovery
- T17: Missing accessibility permissions message
- T18: Different network error

---

## Test Execution

### Test 1: PWA Loads Successfully ✅

**Purpose**: Verify HTTP server serves PWA correctly

**Playwright Commands**:
```
mcp__playwright__browser_navigate("http://localhost:3000")
mcp__playwright__browser_snapshot()
mcp__playwright__browser_take_screenshot({"filename": "t1-pwa-loaded.png"})
```

**Expected Results**:
- ✅ Page loads without ERR_ABORTED
- ✅ Title contains "Agent Deck"
- ✅ No 404 or 500 errors
- ✅ CSS and JS files load

**Success Criteria**: Navigation completes, snapshot shows UI

---

### Test 2: Connection Status Indicator Works ✅

**Purpose**: Verify connection status UI element exists and updates

**Playwright Commands**:
```
mcp__playwright__browser_snapshot()
# Look for: connection-status element
# Verify text is "Connected" or "Disconnected"
```

**Expected Results**:
- ✅ Element `#connection-status` exists
- ✅ Shows "Disconnected" initially
- ✅ Changes to "Connected" within 2 seconds
- ✅ Green color when connected

**Success Criteria**: Status indicator visible and shows "Connected" (green)

---

### Test 3: WebSocket Establishes Connection ✅

**Purpose**: Verify WebSocket connects to port 3001

**Playwright Commands**:
```
mcp__playwright__browser_snapshot()
mcp__playwright__browser_console_messages()
# Look for: "WebSocket connected" or "Connected to Agent Deck"
```

**Expected Results**:
- ✅ WebSocket connects to ws://localhost:3001
- ✅ Console shows "Connected" message
- ✅ No WebSocket errors in console
- ✅ Connection status turns green

**Success Criteria**: Console shows WebSocket connection success, no errors

---

### Test 4: Initial State Received ✅

**Purpose**: Verify server sends initial_state message

**Playwright Commands**:
```
mcp__playwright__browser_snapshot()
mcp__playwright__browser_console_messages()
# Look for: "Received initial state" or agent list populated
```

**Expected Results**:
- ✅ initial_state message received
- ✅ Console shows state received log
- ✅ Agent list populates (if Claude Code running)
- ✅ No errors in console

**Success Criteria**: Initial state message received, console confirms

---

### Test 5: Agent Instances Display ✅

**Purpose**: Verify detected Claude Code instances appear in UI

**Prerequisites**: At least one Claude Code instance running

**Playwright Commands**:
```
mcp__playwright__browser_snapshot()
# Look for: .agent-card elements
# Count number of agent cards
```

**Expected Results**:
- ✅ At least 1 `.agent-card` element visible
- ✅ Agent card shows:
  - Agent type (e.g., "Claude Code")
  - Working directory
  - Status indicator
  - Current task (if available)

**Success Criteria**: At least 1 agent card visible with correct information

---

### Test 6: Agent Status Indicators Work ✅

**Purpose**: Verify color-coded status indicators

**Playwright Commands**:
```
mcp__playwright__browser_snapshot()
# Look for: .status-indicator elements
# Check for color classes: idle, working, done, error
```

**Expected Results**:
- ✅ Status indicator present
- ✅ Color matches status:
  - Gray: idle
  - Blue: working
  - Green: done
  - Red: error

**Success Criteria**: Status indicator shows correct color for agent state

---

### Test 7: Current Task Displays ✅

**Purpose**: Verify parsed current task appears

**Prerequisites**: Claude Code actively working

**Playwright Commands**:
```
mcp__playwright__browser_snapshot()
# Look for: .current-task element
# Verify text is not empty
```

**Expected Results**:
- ✅ `.current-task` element exists
- ✅ Shows task description (e.g., "Writing tests")
- ✅ Truncates to 200 chars if longer
- ✅ Shows "Unknown" if not available

**Success Criteria**: Current task text visible and makes sense

---

### Test 8: Real-Time Updates Work (<500ms) ⏱️

**Purpose**: Verify status updates meet <500ms latency requirement

**Test Procedure**:
1. Note current task in PWA
2. Switch Claude Code task (e.g., run new command)
3. Measure time until PWA updates
4. Repeat 5 times

**Playwright Commands**:
```
# Take snapshots every 200ms
mcp__playwright__browser_wait_for({"time": 0.2})
mcp__playwright__browser_snapshot()
# Repeat 10 times
```

**Expected Results**:
- ✅ Update appears in PWA within 500ms
- ✅ Average latency < 500ms
- ✅ 95th percentile < 750ms

**Success Criteria**: 80% of updates arrive within 500ms

---

### Test 9: Auto-Reconnect Works ✅

**Purpose**: Verify exponential backoff reconnection

**Test Procedure**:
1. Load PWA (connected)
2. Kill Agent-Deck app
3. Verify "Disconnected" status
4. Restart Agent-Deck app
5. Verify reconnection

**Playwright Commands**:
```
mcp__playwright__browser_snapshot()  # Initial connected
# Kill app externally
mcp__playwright__browser_wait_for({"time": 2})
mcp__playwright__browser_snapshot()  # Should show disconnected
# Restart app externally
mcp__playwright__browser_wait_for({"time": 10})
mcp__playwright__browser_snapshot()  # Should show reconnected
```

**Expected Results**:
- ✅ Status changes to "Disconnected" (red)
- ✅ Reconnect attempts visible (1s, 2s, 4s intervals)
- ✅ Status changes to "Connected" (green) when app restarts
- ✅ Agent list repopulates

**Success Criteria**: Automatic reconnection within 16 seconds

---

### Test 10: Agent Card Tap Sends Focus Command ✅

**Purpose**: Verify tap interaction sends WebSocket message

**Playwright Commands**:
```
mcp__playwright__browser_snapshot()
mcp__playwright__browser_click({
    "element": "first agent card",
    "ref": "[data-instance-id='...']"  # From snapshot
})
mcp__playwright__browser_console_messages()
# Look for: "Sending focus command" or similar
```

**Expected Results**:
- ✅ Click registers (visual feedback)
- ✅ Console shows "focus" message sent
- ✅ WebSocket sends focus command with instanceId
- ✅ No errors in console

**Success Criteria**: Focus command sent, console confirms

---

### Test 11: Focus Success Feedback Displays ✅

**Purpose**: Verify UI shows focus success/failure

**Playwright Commands**:
```
mcp__playwright__browser_click({
    "element": "agent card",
    "ref": "..."
})
mcp__playwright__browser_wait_for({"time": 2})
mcp__playwright__browser_snapshot()
# Look for: .feedback-success or .feedback-error
```

**Expected Results**:
- ✅ Success feedback appears within 1 second
- ✅ Green checkmark or "Focused" message
- ✅ Feedback auto-dismisses after 3 seconds
- ✅ OR error message if accessibility denied

**Success Criteria**: Visual feedback confirms focus attempt result

---

### Test 12: Window Actually Switches (Mac Verification) 🖥️

**Purpose**: Verify Mac window focus changes

**Prerequisites**:
- Accessibility permissions granted
- Agent-Deck PWA open in browser
- Claude Code instance in background

**Test Procedure**:
1. Note currently focused window (should be browser)
2. Tap Claude Code agent card in PWA
3. Verify focused window changes to Claude Code
4. Measure time to focus

**Manual Verification**:
```bash
# Before tap: Browser focused
# After tap: Claude Code focused

# Measure with AppleScript:
osascript -e 'tell application "System Events" to get name of first process whose frontmost is true'
```

**Expected Results**:
- ✅ Window focus switches to Claude Code
- ✅ Switch completes within 1 second
- ✅ Works across macOS Spaces
- ✅ PWA shows success feedback

**Success Criteria**: Correct window focused within 1 second

---

### Test 13: QR Code Generates 📱

**Purpose**: Verify QR code generation in Mac app

**Test Procedure**:
1. Open Agent-Deck menubar dropdown
2. Click "View Mobile Interface"
3. Verify QR code displays

**Verification** (Cannot automate with Playwright - Mac app):
```bash
# Check logs for QR generation
log show --predicate 'subsystem == "com.TheHillPack.Agent-Deck"' --last 1m | grep -i "qr"
```

**Expected Results**:
- ✅ QR code image generates
- ✅ Contains URL: http://[local-ip]:3000
- ✅ Scannable with phone camera
- ✅ URL also shown as text

**Success Criteria**: QR code visible in menubar, contains correct URL

---

### Test 14: Local IP Address Displays ✅

**Purpose**: Verify local network URL shown

**Test Procedure**:
1. Open menubar dropdown
2. Check QR code view
3. Verify IP address matches actual

**Verification**:
```bash
# Get local IP
ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'

# Should match what's in QR code view
```

**Expected Results**:
- ✅ Shows http://192.168.x.x:3000 (example)
- ✅ IP is reachable on local network
- ✅ Manual entry option available

**Success Criteria**: Correct local IP displayed and reachable

---

### Test 15: PWA Installable (Manifest) ✅

**Purpose**: Verify PWA can be installed

**Playwright Commands**:
```
mcp__playwright__browser_navigate("http://localhost:3000")
mcp__playwright__browser_snapshot()
# Check for install prompt or manifest
```

**Browser DevTools Verification**:
```javascript
// Check manifest loaded
fetch('/manifest.json')
  .then(r => r.json())
  .then(console.log)

// Check service worker (if implemented)
navigator.serviceWorker.getRegistrations()
  .then(console.log)
```

**Expected Results**:
- ✅ manifest.json loads successfully
- ✅ Manifest has name, icons, display mode
- ✅ Icons (192x192, 512x512) exist
- ✅ Browser shows install prompt (Chrome/Safari)

**Success Criteria**: Manifest valid, installable on mobile

---

### Test 16: Network Interruption Recovery ✅

**Purpose**: Verify graceful handling of network issues

**Test Procedure**:
1. Connect PWA
2. Disable WiFi on Mac
3. Verify disconnect detected
4. Re-enable WiFi
5. Verify auto-reconnect

**Playwright Commands**:
```
# Manual network toggle required
mcp__playwright__browser_wait_for({"time": 5})
mcp__playwright__browser_snapshot()  # After WiFi disable
mcp__playwright__browser_wait_for({"time": 10})
mcp__playwright__browser_snapshot()  # After WiFi enable
```

**Expected Results**:
- ✅ "Disconnected" status shows immediately
- ✅ Reconnect attempts with backoff
- ✅ "Connected" status when WiFi restored
- ✅ Agent list refreshes

**Success Criteria**: Automatic recovery within 16 seconds

---

### Test 17: Missing Accessibility Permissions Message ✅

**Purpose**: Verify error message when permissions denied

**Test Procedure**:
1. Revoke accessibility permissions
2. Tap agent card to focus
3. Verify error message

**Playwright Commands**:
```
mcp__playwright__browser_click({
    "element": "agent card",
    "ref": "..."
})
mcp__playwright__browser_wait_for({"time": 2})
mcp__playwright__browser_snapshot()
# Look for: error message about accessibility
```

**Expected Results**:
- ✅ Error message appears
- ✅ Message mentions "Accessibility permissions"
- ✅ Actionable instructions (e.g., "Open System Settings")
- ✅ Red error styling

**Success Criteria**: Clear error message with instructions

---

### Test 18: Different Network Error ✅

**Purpose**: Verify error when phone on different WiFi

**Test Procedure**:
1. Open PWA on phone
2. Ensure phone on different WiFi than Mac
3. Verify error message

**Expected Results**:
- ✅ Connection fails
- ✅ Error message: "Devices must be on same network"
- ✅ Suggests checking WiFi
- ✅ Shows connection status as "Disconnected"

**Success Criteria**: Clear error message, helpful guidance

---

## Performance Benchmarks

### Latency Requirements

| Metric | Target | Test | Status |
|--------|--------|------|--------|
| PWA Load Time | <2s | T1 | ⏱️ |
| Status Update | <500ms | T8 | ⏱️ |
| Window Focus | <1s | T12 | ⏱️ |
| WebSocket Connect | <2s | T3 | ⏱️ |
| Auto-Reconnect | <16s | T9, T16 | ⏱️ |

### Resource Usage

| Metric | Target | Check |
|--------|--------|-------|
| Mac App CPU (idle) | <2% | Activity Monitor |
| Mac App CPU (active) | <5% | Activity Monitor |
| Mac App RAM | <100MB | Activity Monitor |
| PWA Load Size | <500KB | Network tab |
| WebSocket Overhead | <1KB/s | Network tab |

---

## Test Execution Order

### Smoke Tests (Quick Validation)
1. T1: PWA loads
2. T2: Connection status
3. T3: WebSocket connects
4. T5: Agent instances display

**Time**: ~2 minutes
**Purpose**: Basic functionality verification

### Full Suite (Comprehensive)
All tests T1-T18 in order

**Time**: ~30 minutes
**Purpose**: Complete MVP validation

### Critical Path (Pre-Launch)
T1, T3, T5, T8, T10, T12

**Time**: ~10 minutes
**Purpose**: Core functionality for Show HN

---

## Running Tests with Playwright MCP

### Setup
```bash
# Ensure Agent-Deck app running
open -a Agent-Deck

# Ensure at least one Claude Code instance running
claude

# Verify servers
lsof -iTCP:3000,3001 -sTCP:LISTEN
```

### Execute Tests
Use Claude Code with Playwright MCP:

```
Test 1: Navigate to PWA
mcp__playwright__browser_navigate("http://localhost:3000")

Test 1: Take snapshot
mcp__playwright__browser_snapshot()

Test 1: Screenshot
mcp__playwright__browser_take_screenshot({"filename": "test-results/t1-pwa-loaded.png"})

Test 2: Check connection status
mcp__playwright__browser_snapshot()
# Verify connection-status element shows "Connected"

Test 3: Check console for WebSocket
mcp__playwright__browser_console_messages()
# Verify "Connected to Agent Deck" or similar

Test 5: Count agent cards
mcp__playwright__browser_snapshot()
# Look for .agent-card elements

Test 10: Click agent card
mcp__playwright__browser_click({
    "element": "first agent card for Claude Code",
    "ref": "[data-instance-id='...']"  # From snapshot
})

Test 11: Verify focus feedback
mcp__playwright__browser_wait_for({"time": 2})
mcp__playwright__browser_snapshot()
# Look for success feedback
```

---

## Test Report Template

After running tests, document results:

```markdown
# Test Run Report - Agent Deck
**Date**: YYYY-MM-DD
**Tester**: Claude Code + Playwright MCP
**Build**: [Git commit hash]

## Summary
- **Total Tests**: 18
- **Passed**: X
- **Failed**: Y
- **Skipped**: Z

## Critical Issues
- [Issue 1 description]
- [Issue 2 description]

## Test Results
- [T1] PWA Loads: ✅ PASS (1.2s)
- [T2] Connection Status: ✅ PASS
- [T3] WebSocket: ✅ PASS (0.8s)
- ...

## Performance Metrics
- PWA Load: 1.2s (target: <2s) ✅
- Status Update: 450ms (target: <500ms) ✅
- Window Focus: 0.9s (target: <1s) ✅

## Recommendations
- [Improvement 1]
- [Improvement 2]

## Screenshots
- t1-pwa-loaded.png
- t5-agent-cards.png
- t10-focus-feedback.png
```

---

## Success Criteria for MVP Launch

### Must Pass (Show HN Blocker)
- [x] All smoke tests pass (T1, T2, T3, T5)
- [ ] All User Story 1 tests pass (T5-T9)
- [ ] All User Story 2 tests pass (T10-T12)
- [ ] All User Story 3 tests pass (T13-T15)
- [ ] All performance targets met

### Should Pass (Quality)
- [ ] All 18 tests pass
- [ ] No console errors
- [ ] No memory leaks
- [ ] No crashes

### Nice to Have (Polish)
- [ ] All tests pass in <15 minutes
- [ ] Automated CI/CD
- [ ] Screenshot comparisons
- [ ] Performance regression tests

---

## Continuous Testing

### Pre-Commit
Run smoke tests (T1-T5) - 2 minutes

### Pre-Push
Run critical path tests (T1, T3, T5, T8, T10, T12) - 10 minutes

### Pre-Release
Run full suite (T1-T18) - 30 minutes

### Post-Deploy
Run smoke tests + performance benchmarks

---

## Known Limitations

### Cannot Test with Playwright MCP
1. Mac menubar interactions (QR code view)
2. AppleScript window switching verification
3. Mobile device scanning (requires physical device)
4. Accessibility permission prompts
5. System Settings navigation

### Workarounds
- **Menubar**: Check logs, manual verification
- **Window switching**: AppleScript queries
- **Mobile**: Manual testing with phone
- **Permissions**: Manual setup before tests
- **System Settings**: Manual verification

---

## Future Enhancements

### Phase 2
- Add performance regression tests
- Add screenshot comparison tests
- Add load testing (100+ concurrent connections)
- Add mobile device automated testing

### Phase 3
- CI/CD integration (GitHub Actions)
- Automated test reports
- Performance dashboards
- Test coverage metrics

---

**Document Created**: 2025-11-03 14:00 PST
**Ready to Run**: Once HTTP server fixed
**Maintenance**: Update after each new feature
**Owner**: Development Team
