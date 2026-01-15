# Mobile PWA Testing Procedure

**Agent Deck MVP - Cross-Platform Mobile Testing**

This document provides step-by-step procedures for testing the Agent Deck Progressive Web App on iOS and Android devices.

---

## Prerequisites

- **Mac Requirements:**
  - Agent Deck app installed and running
  - Mac connected to WiFi network
  - Local IP address known (check QR code view or run `ifconfig`)

- **Mobile Device Requirements:**
  - iOS 14+ (Safari) OR Android with Chrome 90+
  - Connected to the SAME WiFi network as Mac
  - Stable internet connection

---

## Test Environment Setup

### 1. Prepare Mac

```bash
# Start Agent Deck
open ~/Library/Developer/Xcode/DerivedData/Agent-Deck-*/Build/Products/Debug/Agent-Deck.app

# Verify servers are running
lsof -iTCP:3000,3001 -sTCP:LISTEN

# Get local IP address
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Expected output:**
- HTTP server listening on port 3000
- WebSocket server listening on port 3001
- Local IP address (e.g., 192.168.1.100)

### 2. Open QR Code View (if available)

1. Click Agent Deck menubar icon
2. Select "View Mobile Interface" (if implemented)
3. QR code should display with local IP
4. Note the URL shown (e.g., `http://192.168.1.100:3000`)

### 3. Prepare Mobile Device

1. Ensure WiFi is enabled
2. Connect to same network as Mac
3. Verify internet connectivity
4. Close all browser tabs (fresh start)

---

## iOS Safari Testing (iPhone/iPad)

### Test 1: Initial PWA Load ✓

**Steps:**
1. Open Safari on iPhone
2. Navigate to: `http://[MAC-IP]:3000` (replace [MAC-IP] with your Mac's local IP)
3. Wait for page to load

**Expected Results:**
- ✅ Page loads within 2 seconds
- ✅ "Agent Deck" title appears
- ✅ Dark theme background visible
- ✅ Connection status indicator shows "Connecting..." then "Connected"
- ✅ No console errors (check Safari developer tools if connected)

**If page doesn't load:**
- Verify Mac and iPhone are on same WiFi network
- Check Mac firewall settings (allow port 3000)
- Try accessing `http://localhost:3000` from Mac browser first
- Check Agent Deck logs: `log show --predicate 'subsystem == "com.agentdeck.mac"' --last 1m`

---

### Test 2: PWA Installation ✓

**Steps:**
1. With PWA loaded in Safari, tap the **Share** button (box with arrow)
2. Scroll down and tap **"Add to Home Screen"**
3. Edit name if desired (default: "Agent Deck")
4. Tap **"Add"**
5. Go to home screen
6. Locate Agent Deck icon
7. Tap icon to launch

**Expected Results:**
- ✅ Icon appears on home screen
- ✅ App opens in fullscreen mode (no Safari UI)
- ✅ PWA reconnects automatically
- ✅ Connection status shows "Connected" within 2 seconds
- ✅ Same functionality as Safari browser version

**Verification:**
- Check if address bar is hidden (fullscreen PWA mode)
- Try switching apps and returning - should maintain state

---

### Test 3: WebSocket Connection ✓

**Steps:**
1. With PWA connected, observe connection status indicator
2. Start a Claude Code instance on Mac (if not already running)
3. Wait 2-5 seconds

**Expected Results:**
- ✅ Connection status remains "Connected" (green dot)
- ✅ Agent card appears for Claude Code instance
- ✅ Card shows:
  - Agent type: "claude-code"
  - Process ID (PID)
  - Status: "Idle" or current status
  - Working directory path
- ✅ No "Disconnected" messages

**If connection fails:**
- Check WiFi signal strength
- Verify WebSocket port 3001 is open
- Check Mac firewall settings
- Review WebSocket logs in Safari developer console

---

### Test 4: Agent Card Display ✓

**Steps:**
1. Ensure at least one Claude Code instance is running
2. Observe agent card in PWA

**Expected Results:**
- ✅ Card displays with dark background
- ✅ Status indicator (colored dot) visible on left border
- ✅ Agent type label readable
- ✅ PID displayed correctly
- ✅ Current task field shows "Unknown" or actual task
- ✅ Working directory shows full path
- ✅ Last activity timestamp updates

**Visual Check:**
- Text is readable (not too small)
- Contrast is sufficient (dark mode)
- Layout doesn't overflow or clip
- Touch target size is adequate (>44px)

---

### Test 5: Window Switching (Tap Agent Card) ✓

**Steps:**
1. Ensure Claude Code window is NOT focused (switch to another app on Mac)
2. On iPhone, tap the agent card for Claude Code instance
3. Observe Mac screen

**Expected Results:**
- ✅ Mac switches to Claude Code window within 1 second
- ✅ Claude Code comes to foreground
- ✅ iPhone shows brief "success" feedback (visual indicator)
- ✅ No error messages

**If switching fails:**
- Check if accessibility permissions are granted on Mac
  - System Preferences → Privacy & Security → Accessibility
  - Agent-Deck should be in the list with checkbox enabled
- Verify Claude Code is still running (not crashed)
- Check error message on PWA (should explain issue)

---

### Test 6: Real-Time Updates (<500ms) ✓

**Steps:**
1. With PWA connected, start a new Claude Code instance on Mac
2. Note time delay until PWA shows new instance

**Expected Results:**
- ✅ New agent card appears within 1-2 seconds
- ✅ No manual refresh needed
- ✅ Card shows correct information immediately

**Performance Check:**
- Update latency should be <500ms (target)
- Multiple updates don't cause lag
- No flickering or re-rendering issues

---

### Test 7: Network Interruption Recovery ✓

**Steps:**
1. With PWA connected, enable Airplane Mode on iPhone
2. Wait 5 seconds
3. Disable Airplane Mode
4. Observe reconnection

**Expected Results:**
- ✅ PWA shows "Disconnected" status immediately
- ✅ PWA automatically attempts to reconnect
- ✅ Connection restored within 5-10 seconds
- ✅ Agent list repopulates after reconnection
- ✅ No data loss or corruption

**Check logs for:**
- Reconnection attempts logged
- Exponential backoff working (1s, 2s, 4s, 8s...)
- No infinite retry loops

---

### Test 8: Multi-Device Connection ✓

**Steps:**
1. Keep iPhone connected
2. Open PWA on iPad (same WiFi network)
3. Navigate to same URL
4. Tap agent card on one device

**Expected Results:**
- ✅ Both devices show same agent list
- ✅ Both receive real-time updates
- ✅ Window switching works from either device
- ✅ No conflicts or race conditions

---

### Test 9: Orientation Changes ✓

**Steps:**
1. With PWA loaded, rotate iPhone to landscape
2. Rotate back to portrait

**Expected Results:**
- ✅ Layout adapts smoothly
- ✅ No content clipped or hidden
- ✅ Touch targets remain accessible
- ✅ Connection maintained during rotation

---

### Test 10: Background/Foreground Transitions ✓

**Steps:**
1. With PWA connected, press Home button (or swipe up)
2. Wait 30 seconds
3. Re-open Agent Deck from home screen

**Expected Results:**
- ✅ PWA still connected (no reconnection needed)
- ✅ OR reconnects automatically within 2 seconds
- ✅ Agent list up-to-date
- ✅ No stale data

**Note:** iOS may suspend WebSocket connections after ~30s in background

---

## Android Chrome Testing

### Test 1: Initial PWA Load ✓

**Steps:**
1. Open Chrome on Android device
2. Navigate to: `http://[MAC-IP]:3000`
3. Wait for page to load

**Expected Results:**
- ✅ Page loads within 2 seconds
- ✅ Dark theme renders correctly
- ✅ Connection status shows "Connected"
- ✅ No mixed content warnings

---

### Test 2: PWA Installation (Add to Home Screen) ✓

**Steps:**
1. With PWA loaded, tap Chrome menu (⋮)
2. Select **"Add to Home screen"**
3. Confirm installation
4. Tap "Add"
5. Go to home screen
6. Launch Agent Deck icon

**Expected Results:**
- ✅ Install prompt appears (or manual add option available)
- ✅ Icon appears on launcher
- ✅ Opens in standalone mode (no browser chrome)
- ✅ Behaves like native app

**Check for:**
- Fullscreen display (no Chrome UI visible)
- Status bar matches theme color
- Back button exits app (not browser navigation)

---

### Test 3: WebSocket Connection ✓

**Steps:**
1. Ensure Claude Code is running on Mac
2. Open PWA on Android
3. Observe agent cards

**Expected Results:**
- ✅ WebSocket connects successfully
- ✅ Agent cards display
- ✅ Real-time updates work
- ✅ No "Connection refused" errors

---

### Test 4: Touch Interactions ✓

**Steps:**
1. Tap agent card
2. Long-press agent card (if applicable)
3. Scroll through multiple agents

**Expected Results:**
- ✅ Tap registers immediately (no delay)
- ✅ Visual feedback on tap (ripple or color change)
- ✅ Smooth scrolling
- ✅ No accidental taps

---

### Test 5: Offline Mode (Service Worker) ⚠️

**Steps:**
1. With PWA installed, load successfully once
2. Enable Airplane Mode
3. Close and reopen PWA

**Expected Results:**
- ⚠️ PWA loads offline skeleton/cache (if service worker implemented)
- ⚠️ Shows "Disconnected" message
- ⚠️ Cached UI remains functional

**Note:** Full offline support may not be in MVP. Check service-worker.js implementation.

---

### Test 6: Notification Support (Phase 2+) ⚠️

**Steps:**
1. Check if notification permission prompt appears
2. Grant notification permissions

**Expected Results:**
- ⚠️ Not implemented in MVP (Phase 5+)
- ⚠️ No notification prompt should appear yet

---

## Performance Testing

### Load Time Metrics

**Measure with Chrome DevTools:**

1. Open PWA in Chrome
2. Open DevTools (F12)
3. Go to Network tab
4. Hard reload (Ctrl+Shift+R)

**Target Metrics:**
- ✅ Initial load: <2 seconds
- ✅ First Contentful Paint (FCP): <1 second
- ✅ Time to Interactive (TTI): <2 seconds
- ✅ Total bundle size: <500KB

---

### Network Latency

**Test WebSocket round-trip time:**

1. Open browser console
2. Note timestamps in WebSocket messages
3. Measure time from send to receive

**Target:**
- ✅ Status update latency: <500ms
- ✅ Focus command response: <1 second

---

## Accessibility Testing

### Screen Reader Support (iOS VoiceOver)

**Steps:**
1. Enable VoiceOver on iPhone
2. Navigate PWA with swipe gestures

**Expected Results:**
- ✅ Agent cards announced clearly
- ✅ Status indicators read aloud
- ✅ Buttons have accessible labels
- ✅ Focus order makes sense

---

### Color Contrast

**Check with contrast analyzer:**
- ✅ Text on background: min 4.5:1 ratio
- ✅ Status indicators distinguishable (not color-only)

---

## Security Testing

### HTTPS vs HTTP ⚠️

**Current State:**
- ⚠️ MVP uses HTTP (ws://)
- ⚠️ Not encrypted (local network only)

**Phase 6 Requirements:**
- Use HTTPS (wss://)
- Valid SSL certificate
- Secure authentication

---

### Same-Origin Policy ✓

**Verify:**
- ✅ PWA only connects to Mac app (no external domains)
- ✅ No mixed content warnings
- ✅ WebSocket origin matches HTTP origin

---

## Known Issues & Limitations

### iOS Limitations
- **WebSocket suspension**: iOS may suspend WebSocket after 30s in background
- **No true background**: PWA doesn't run truly in background like native app
- **Storage limits**: LocalStorage/IndexedDB quotas

### Android Limitations
- **Battery optimization**: Android may kill background processes
- **Notification support**: Limited compared to native apps

### General PWA Limitations
- **No app store presence**: Users must bookmark or add to home screen manually
- **No native features**: Can't access all device APIs (Bluetooth, NFC, etc.)
- **Browser compatibility**: Features vary by browser

---

## Troubleshooting

### "Cannot connect to server"

**Causes:**
1. Different WiFi networks
2. Mac firewall blocking ports
3. Agent Deck not running
4. Wrong IP address

**Solutions:**
- Verify same WiFi network: `ipconfig getifaddr en0` (Mac) vs phone WiFi settings
- Check firewall: System Preferences → Security & Privacy → Firewall
- Restart Agent Deck
- Regenerate QR code to get current IP

---

### "Connection lost" repeatedly

**Causes:**
1. Weak WiFi signal
2. Network instability
3. Mac sleep mode
4. Process crash

**Solutions:**
- Move closer to WiFi router
- Check WiFi signal strength on both devices
- Disable Mac sleep while testing: `caffeinate -d`
- Check Agent Deck logs for crashes

---

### Agent cards not updating

**Causes:**
1. WebSocket disconnected
2. ProcessMonitor not running
3. Stale cache

**Solutions:**
- Check connection status indicator
- Restart Agent Deck
- Hard refresh PWA (Ctrl+Shift+R or clear cache)
- Check Mac logs: `log show --predicate 'subsystem == "com.agentdeck.mac"'`

---

### Window switching fails

**Causes:**
1. Missing accessibility permissions
2. Claude Code not running
3. Window already focused

**Solutions:**
- Grant accessibility permissions: System Preferences → Privacy & Security
- Verify Claude Code is running: `pgrep -i claude`
- Switch to different app first, then try again

---

## Test Report Template

```markdown
# Mobile PWA Test Report

**Date:** YYYY-MM-DD
**Tester:** [Name]
**Device:** [iPhone 14 / Samsung Galaxy S23 / etc.]
**OS Version:** [iOS 17.1 / Android 14 / etc.]
**Browser:** [Safari / Chrome / etc.]

## Test Results

| Test | Status | Notes |
|------|--------|-------|
| Initial Load | ✅ PASS | Loaded in 1.2s |
| PWA Install | ✅ PASS | Icon added successfully |
| WebSocket Connection | ✅ PASS | Connected immediately |
| Agent Card Display | ✅ PASS | All data visible |
| Window Switching | ✅ PASS | <1s latency |
| Real-Time Updates | ✅ PASS | ~300ms latency |
| Network Recovery | ✅ PASS | Reconnected in 3s |
| Multi-Device | ✅ PASS | Both devices synced |
| Orientation Changes | ✅ PASS | Layout adapted |
| Background Transitions | ⚠️ PARTIAL | Reconnects after 30s |

## Issues Found

1. **Issue description**
   - Severity: Low/Medium/High
   - Steps to reproduce
   - Expected vs actual behavior

## Screenshots

- (Attach screenshots of PWA on device)

## Recommendations

- List any improvements or fixes needed
```

---

## Appendix: Quick Test Checklist

**Pre-Launch Checklist (5 minutes):**

- [ ] Mac and phone on same WiFi
- [ ] Agent Deck running (ports 3000, 3001 listening)
- [ ] At least one Claude Code instance running
- [ ] QR code generated (or IP address known)

**Core Functionality (10 minutes):**

- [ ] PWA loads successfully
- [ ] Install to home screen works
- [ ] WebSocket connects
- [ ] Agent cards display
- [ ] Window switching works
- [ ] Real-time updates working

**Edge Cases (10 minutes):**

- [ ] Network interruption recovery
- [ ] Background/foreground transitions
- [ ] Orientation changes
- [ ] Multi-device connections

**Performance (5 minutes):**

- [ ] Load time <2s
- [ ] Update latency <500ms
- [ ] Window switch latency <1s
- [ ] No memory leaks (use DevTools)

---

**Total Testing Time:**
- Quick test: ~15 minutes
- Full test: ~45 minutes
- With multiple devices: ~1 hour

**Recommendation:** Perform quick test before each release, full test before major launches.
