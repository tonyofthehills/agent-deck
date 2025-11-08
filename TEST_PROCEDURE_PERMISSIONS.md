# Permissions Testing Procedure

**Agent Deck MVP - Accessibility and Security Permissions**

This document provides step-by-step procedures for testing permission flows, error handling, and user guidance when permissions are missing or denied.

---

## Overview

Agent Deck requires the following macOS permissions to function:

| Permission | Purpose | Required? | Failure Impact |
|-----------|---------|-----------|----------------|
| **Accessibility** | Window switching (NSRunningApplication.activate) | ✅ Required | Window switching fails with clear error |
| **Network (Firewall)** | HTTP/WebSocket servers on ports 3000/3001 | ⚠️ Recommended | PWA cannot connect |
| **Full Disk Access** | Reading transcript files from ~/.cache/claude | ⚠️ Optional | Output parsing unavailable (future) |

---

## Test Environment Setup

### Prerequisites

1. Fresh macOS installation OR clean permission state:
   ```bash
   # Reset permissions for Agent Deck
   tccutil reset Accessibility com.agentdeck.mac
   tccutil reset SystemPolicyAllFiles com.agentdeck.mac
   ```

2. Agent Deck built but not launched yet

3. System Preferences/Settings app closed

---

## Test 1: First Launch - No Permissions

### Objective
Verify that Agent Deck handles first launch gracefully when no permissions are granted.

### Steps

1. **Kill Agent Deck if running:**
   ```bash
   pkill -9 Agent-Deck
   ```

2. **Reset accessibility permissions:**
   ```bash
   tccutil reset Accessibility com.agentdeck.mac
   ```

3. **Launch Agent Deck:**
   ```bash
   open ~/Library/Developer/Xcode/DerivedData/Agent-Deck-*/Build/Products/Debug/Agent-Deck.app
   ```

4. **Observe behavior:**
   - App launches and appears in menubar
   - Servers start (ports 3000, 3001 listening)
   - No crashes

5. **Try to switch windows (via PWA):**
   - Connect to PWA from phone/browser
   - Tap an agent card to focus window

### Expected Results

- ✅ App launches successfully (no crash)
- ✅ Menubar icon appears
- ✅ Servers start normally
- ✅ PWA connects successfully
- ✅ Window switching fails with **clear, actionable error message**

**Error message should include:**
- ❗ Error type: "accessibility_permissions_required"
- ❗ User-friendly explanation
- ❗ Step-by-step instructions to grant permission
- ❗ Path to System Preferences

**Example error message (PWA):**
```
Agent Deck needs Accessibility permissions to switch windows.

Please grant permission:
1. Open System Preferences
2. Go to Privacy & Security → Accessibility
3. Enable Agent-Deck
4. Try again
```

**Verify in logs:**
```bash
log show --predicate 'subsystem == "com.agentdeck.mac"' --last 1m | grep -i "permission\|accessibility"
```

Should contain:
- Warning about missing accessibility permissions
- Clear log of permission check failure
- No crashes or unhandled exceptions

---

## Test 2: Granting Accessibility Permissions

### Objective
Verify that granting permissions enables window switching without restart.

### Steps

1. **With Agent Deck running (and permissions denied):**
   - Ensure PWA shows error message from Test 1

2. **Open System Preferences:**
   - Apple menu → System Preferences (macOS 12) / System Settings (macOS 13+)
   - Navigate to: **Privacy & Security → Accessibility**

3. **Attempt to enable Agent-Deck:**
   - Look for "Agent-Deck" in list
   - Click checkbox to enable

4. **Expected prompt:**
   - ✅ macOS shows "Agent-Deck" would like to control this computer using accessibility features"
   - ✅ Options: "Don't Allow" or "OK"

5. **Click "OK"**

6. **Verify permission granted:**
   ```bash
   sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" \
     "SELECT client, auth_value FROM access WHERE service='kTCCServiceAccessibility' AND client LIKE '%agent%'"
   ```
   - Should show: `com.agentdeck.mac` with `auth_value=1`

7. **Test window switching again:**
   - Return to PWA
   - Tap agent card
   - **No app restart required**

### Expected Results

- ✅ Permission prompt appears
- ✅ After granting permission, window switching works immediately
- ✅ **No app restart required**
- ✅ PWA shows success feedback (no more error)
- ✅ Mac switches to Claude Code window (<1s)

**Check logs:**
```bash
log show --predicate 'subsystem == "com.agentdeck.mac"' --last 30s | grep -i "permission\|focus"
```

Should show:
- Permission check now returns true
- Window focus commands succeed
- focus_success messages sent to PWA

---

## Test 3: Denying Accessibility Permissions

### Objective
Verify app handles denied permissions gracefully and provides retry guidance.

### Steps

1. **Reset permissions:**
   ```bash
   tccutil reset Accessibility com.agentdeck.mac
   pkill Agent-Deck
   ```

2. **Launch Agent Deck:**
   ```bash
   open ~/Library/Developer/Xcode/DerivedData/Agent-Deck-*/Build/Products/Debug/Agent-Deck.app
   ```

3. **Trigger permission prompt:**
   - Connect PWA
   - Tap agent card to switch windows

4. **macOS shows permission prompt:**
   - Click **"Don't Allow"**

5. **Observe behavior:**
   - Note error message in PWA
   - Check app behavior

### Expected Results

- ✅ App does NOT crash when permission denied
- ✅ PWA shows error message explaining permission is required
- ✅ Error message includes instructions to enable in System Preferences
- ✅ User can retry after manually enabling permission

**Error message should persist:**
- Every window switch attempt shows same error
- No indefinite retry loops
- No silent failures

**Check logs:**
```bash
log show --predicate 'subsystem == "com.agentdeck.mac"' --last 30s | grep -i error
```

Should show:
- Permission denied logged
- Graceful error handling
- No crashes or exceptions

---

## Test 4: Revoking Permissions (Mid-Session)

### Objective
Verify app detects permission revocation and handles gracefully.

### Steps

1. **Start with permissions granted:**
   - Agent Deck running
   - PWA connected
   - Window switching working

2. **Revoke accessibility permissions while running:**
   - Open System Preferences → Privacy & Security → Accessibility
   - Uncheck "Agent-Deck"
   - **Keep Agent Deck running** (don't restart)

3. **Try to switch windows:**
   - Tap agent card in PWA

### Expected Results

- ✅ Window switching fails with error message
- ✅ Error message appears immediately (no delay)
- ✅ App detects permission revocation dynamically
- ✅ No crash or hang
- ✅ Other functionality (monitoring, WebSocket) continues working

**Note:** Some macOS versions may require app restart for permission changes to take effect. Document behavior.

---

## Test 5: Firewall Blocking Network Connections

### Objective
Verify error handling when macOS Firewall blocks incoming connections.

### Steps

1. **Enable macOS Firewall:**
   - System Preferences → Security & Privacy → Firewall
   - Click "Turn On Firewall"
   - Click "Firewall Options..."
   - Set to "Block all incoming connections"

2. **Launch Agent Deck:**
   ```bash
   open ~/Library/Developer/Xcode/DerivedData/Agent-Deck-*/Build/Products/Debug/Agent-Deck.app
   ```

3. **Check if servers start:**
   ```bash
   lsof -iTCP:3000,3001 -sTCP:LISTEN
   ```

4. **Try to connect from PWA:**
   - Open PWA on phone: `http://[MAC-IP]:3000`

### Expected Results (Scenario A: Firewall blocks all)

- ⚠️ Servers may fail to bind (depends on firewall config)
- ⚠️ PWA cannot connect (Connection refused)
- ✅ Agent Deck logs error about server start failure
- ✅ Menubar icon shows warning state (or error message)

**Expected error in logs:**
```
Failed to start HTTP server on port 3000: Address already in use (or Permission denied)
```

### Expected Results (Scenario B: Firewall shows prompt)

- ✅ macOS shows firewall prompt: "Do you want to allow Agent-Deck to accept incoming connections?"
- ✅ Options: "Deny" or "Allow"
- ✅ If Allow: PWA connects successfully
- ✅ If Deny: PWA shows connection error with guidance

**Error message to user:**
```
Cannot connect to Agent Deck.

Possible causes:
1. Mac and phone on different WiFi networks
2. Mac firewall is blocking connections
3. Agent Deck is not running

Check:
- System Preferences → Security & Privacy → Firewall
- Allow incoming connections for Agent-Deck
```

---

## Test 6: Missing Permissions on App Update

### Objective
Verify permissions persist across app updates.

### Steps

1. **With permissions granted:**
   - Agent Deck running with accessibility permissions
   - Window switching working

2. **Simulate app update:**
   ```bash
   # Rebuild app (simulates new version)
   cd Agent-Deck
   xcodebuild -scheme Agent-Deck
   ```

3. **Restart app:**
   ```bash
   pkill Agent-Deck
   open ~/Library/Developer/Xcode/DerivedData/Agent-Deck-*/Build/Products/Debug/Agent-Deck.app
   ```

4. **Test window switching:**
   - Connect PWA
   - Tap agent card

### Expected Results

- ✅ Permissions persist (no re-prompt needed)
- ✅ Window switching works immediately
- ✅ No permission reset

**Note:** Permissions are tied to bundle identifier (`com.agentdeck.mac`), not binary path.

---

## Test 7: Permission Check Performance

### Objective
Verify permission checks don't cause performance degradation.

### Steps

1. **With permissions granted:**
   - Agent Deck running
   - PWA connected

2. **Rapid window switching:**
   - Tap agent card repeatedly (10 times in 10 seconds)

3. **Monitor performance:**
   ```bash
   # CPU usage
   ps aux | grep Agent-Deck

   # Permission check frequency in logs
   log show --predicate 'subsystem == "com.agentdeck.mac"' --last 1m | grep -i "permission"
   ```

### Expected Results

- ✅ No permission check per window switch (check once at startup or cache result)
- ✅ CPU usage remains <5%
- ✅ No lag or delays
- ✅ All window switches succeed

---

## Test 8: Error Message Clarity (User Testing)

### Objective
Verify error messages are understandable by non-technical users.

### Steps

1. **Recruit non-technical user**

2. **Reproduce permission error:**
   - Launch Agent Deck without accessibility permissions
   - Ask user to try switching windows via PWA

3. **Observe user behavior:**
   - Does user understand error message?
   - Can user follow instructions without help?
   - How long does it take to resolve?

4. **Interview user:**
   - Was error message clear?
   - Were instructions easy to follow?
   - Any confusion or frustration?

### Expected Results

- ✅ User understands why window switching failed
- ✅ User can navigate to System Preferences without help
- ✅ User successfully grants permission on first attempt
- ✅ <2 minutes to resolve issue

**If users struggle:**
- Improve error message wording
- Add screenshots to documentation
- Consider in-app tutorial or link to help page

---

## Test 9: Missing Permission Scenarios (Edge Cases)

### Edge Case A: Permission Granted But Not Taking Effect

**Scenario:** User grants permission but app still fails (rare macOS bug)

**Steps:**
1. Grant accessibility permission
2. Window switching still fails

**Expected Recovery:**
- Error message suggests restarting app
- Logs indicate permission is granted but API fails
- User can restart app to resolve

---

### Edge Case B: Permission Prompt Doesn't Appear

**Scenario:** macOS doesn't show permission prompt (system bug)

**Steps:**
1. Try to trigger permission prompt
2. Prompt doesn't appear

**Expected Recovery:**
- Error message guides user to manually enable in System Preferences
- No assumption that prompt will appear

---

### Edge Case C: System Preferences Doesn't Show Agent Deck

**Scenario:** Agent-Deck doesn't appear in Accessibility list

**Steps:**
1. Check Accessibility list in System Preferences
2. Agent-Deck not visible

**Expected Recovery:**
- Error message provides alternative instructions
- "If Agent-Deck doesn't appear in list, drag app to list manually"
- Link to Apple support article

---

## Test Checklist Summary

**Quick Permissions Test (5 minutes):**

- [ ] Fresh launch without permissions
- [ ] Error message appears with clear instructions
- [ ] Grant permission via System Preferences
- [ ] Window switching works without restart
- [ ] Revoke permission mid-session
- [ ] Error message appears again

**Full Permissions Test (15 minutes):**

- [ ] All scenarios above
- [ ] Firewall blocking test
- [ ] Permission persistence across updates
- [ ] Performance check (no degradation)
- [ ] User testing (clarity of messages)

---

## Expected Permission States

| State | Window Switching | Error Message | User Action Required |
|-------|-----------------|---------------|---------------------|
| No permissions | ❌ Fails | ✅ Clear error with steps | Grant in System Preferences |
| Permission granted | ✅ Works | ❌ No error | None |
| Permission denied | ❌ Fails | ✅ Clear error with steps | Manually enable in System Preferences |
| Permission revoked | ❌ Fails | ✅ Detects immediately | Re-enable in System Preferences |
| Firewall blocking | ⚠️ N/A (can't connect) | ✅ Network error | Allow in Firewall settings |

---

## Logging and Debugging

### Check Permission Status

```bash
# Query TCC database (requires SIP disabled or Full Disk Access)
sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" \
  "SELECT service, client, auth_value, auth_reason FROM access WHERE client LIKE '%agent%'"
```

**Output:**
- `service`: kTCCServiceAccessibility
- `auth_value`: 0 (denied), 1 (allowed), 2 (prompt)
- `auth_reason`: 3 (user set), etc.

### Agent Deck Logs

```bash
# Real-time logs
log stream --predicate 'subsystem == "com.agentdeck.mac"' --level debug

# Recent permission-related logs
log show --predicate 'subsystem == "com.agentdeck.mac"' --last 5m | grep -i "permission\|accessibility\|error"
```

### Expected Log Patterns

**Permission check on startup:**
```
[INFO] Checking accessibility permissions...
[INFO] Accessibility permissions: NOT_DETERMINED (or DENIED / AUTHORIZED)
```

**Permission check before window switch:**
```
[DEBUG] Attempting to focus window for PID 12345
[DEBUG] Checking accessibility permissions...
[WARNING] Accessibility permissions required but not granted
[ERROR] Window focus failed: accessibility_permissions_required
```

**After granting permission:**
```
[INFO] Accessibility permissions: AUTHORIZED
[INFO] Successfully focused window for PID 12345
```

---

## Test Report Template

```markdown
# Permissions Test Report

**Date:** YYYY-MM-DD
**Tester:** [Name]
**macOS Version:** [Ventura 13.5 / Sonoma 14.1 / etc.]
**Agent Deck Build:** [Commit hash or version]

## Test Results

| Test | Status | Notes |
|------|--------|-------|
| Fresh launch (no permissions) | ✅ PASS | Clear error shown |
| Grant permissions | ✅ PASS | Works immediately |
| Deny permissions | ✅ PASS | Graceful error handling |
| Revoke mid-session | ✅ PASS | Detected within 1s |
| Firewall blocking | ⚠️ PARTIAL | Error message needs improvement |
| Permission persistence | ✅ PASS | Survived app update |
| Performance check | ✅ PASS | No degradation |
| User testing | ✅ PASS | 90s average resolution time |

## Issues Found

1. **Error message too technical**
   - Severity: Medium
   - Users confused by "accessibility permissions" term
   - Recommendation: Use simpler language

## Recommendations

- Add visual guide (screenshots) to error messages
- Consider in-app button to open System Preferences
- Implement permission check caching (reduce API calls)
```

---

## Known Issues & Workarounds

### Issue: Permission Prompt Doesn't Appear on Monterey

**Symptoms:**
- Accessibility prompt never shows
- Agent-Deck doesn't appear in System Preferences list

**Workaround:**
1. Manually drag Agent-Deck.app to Accessibility list
2. Or run: `tccutil reset Accessibility` and try again

---

### Issue: Permission Changes Require App Restart (Sometimes)

**Symptoms:**
- Grant permission but app still fails
- Requires quit and relaunch

**Workaround:**
- Always restart app after granting permissions (mention in error message)

---

**Total Testing Time:** ~20 minutes (quick) to 45 minutes (comprehensive)

**Recommendation:** Test permissions on every macOS version before release.
