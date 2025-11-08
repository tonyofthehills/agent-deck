# First-Run Experience Implementation

**Tasks Implemented:** T074-T080
**Date:** 2025-01-06
**Status:** Complete

---

## Overview

Implemented zero-config first-run experience for Agent Deck with automatic setup, permissions handling, and clean shutdown.

## Files Modified

### 1. AppDelegate.swift
**Location:** `/Users/tonyofthehills/dev/apps/app-009-agent-deck/Agent-Deck/Agent-Deck/AppDelegate.swift`

**Changes:**
- Added `handleFirstLaunch()` method to detect first launch via UserDefaults key "hasLaunchedBefore"
- Added `showWelcomeMessage()` to display user-friendly welcome dialog on first launch
- Added `checkAndPromptForAccessibilityPermissions()` to handle accessibility permissions proactively
- Enhanced `performCleanShutdown()` to ensure all services stop cleanly (Task T078-T080)
- Added comprehensive logging throughout lifecycle

**New Methods:**
```swift
// MARK: - First Launch Handling
private func handleFirstLaunch()
private func showWelcomeMessage()

// MARK: - Accessibility Permissions
private func checkAndPromptForAccessibilityPermissions()

// MARK: - Clean Shutdown
private func performCleanShutdown()
```

**Key Features:**
- Detects first launch using UserDefaults
- Shows welcome dialog with setup instructions
- Automatically prompts for accessibility permissions
- Clean shutdown sequence: ProcessMonitor → WebSocketServer → HTTPServer → Combine cancellables
- All resources properly released on termination

---

### 2. ConfigManager.swift
**Location:** `/Users/tonyofthehills/dev/apps/app-009-agent-deck/Agent-Deck/Agent-Deck/Services/ConfigManager.swift`

**Changes:**
- Enhanced `createDefaultConfig()` to copy from bundled `default-config.yaml` (Task T075)
- Added fallback to programmatic generation if bundled file not found
- Improved error handling and logging

**Implementation:**
```swift
private func createDefaultConfig() throws {
    // 1. Try to copy from bundled Resources/default-config.yaml
    if let bundledConfigURL = Bundle.main.url(forResource: "default-config", withExtension: "yaml") {
        let bundledConfigData = try String(contentsOf: bundledConfigURL, encoding: .utf8)
        try bundledConfigData.write(to: configFile, atomically: true, encoding: .utf8)
        // Success!
        return
    }

    // 2. Fallback: Generate programmatically
    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(Configuration.default)
    try yamlString.write(to: configFile, atomically: true, encoding: .utf8)
}
```

**Benefits:**
- Users get human-readable config with comments
- Easier to customize (no need to encode/decode)
- Maintains backwards compatibility with programmatic generation

---

### 3. WindowManager.swift
**Location:** `/Users/tonyofthehills/dev/apps/app-009-agent-deck/Agent-Deck/Agent-Deck/Services/WindowManager.swift`

**Changes:**
- Added `hasPromptedForPermissions` state to avoid repeated prompts
- Added `checkAccessibilityWithFeedback()` for user-friendly permission checking (Task T076-T077)
- Added `resetPermissionPromptState()` for manual retry
- Enhanced error messages with actionable instructions

**New Methods:**
```swift
func checkAccessibilityWithFeedback() -> Bool
func resetPermissionPromptState()
```

**Retry Mechanism:**
- Prompts user with dialog explaining why permissions are needed
- Provides "Open System Settings" button that:
  1. Triggers system permission dialog
  2. Opens System Settings to Accessibility pane
- Only prompts once per session to avoid annoyance
- Can be manually reset if needed

---

## First-Run Flow Diagram

```
┌─────────────────────────────────────────┐
│     User Launches Agent Deck            │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Check UserDefaults["hasLaunchedBefore"]│
└──────────────┬──────────────────────────┘
               │
        ┌──────┴──────┐
        │             │
        ▼             ▼
   [FALSE]        [TRUE]
First Launch   Subsequent Launch
        │             │
        ▼             │
┌──────────────┐      │
│ Show Welcome │      │
│   Dialog     │      │
└──────┬───────┘      │
       │              │
       ▼              │
┌──────────────┐      │
│ Set flag to  │      │
│    true      │      │
└──────┬───────┘      │
       │              │
       └──────┬───────┘
              │
              ▼
┌─────────────────────────────────────────┐
│      Setup Menubar & Load Config        │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  ConfigManager checks ~/.agent-deck/    │
│         config.yaml exists?             │
└──────────────┬──────────────────────────┘
               │
        ┌──────┴──────┐
        │             │
        ▼             ▼
     [NO]          [YES]
        │             │
        ▼             │
┌──────────────┐      │
│ Create dir   │      │
│ ~/.agent-deck│      │
└──────┬───────┘      │
       │              │
       ▼              │
┌──────────────────┐  │
│ Copy bundled     │  │
│ default-config   │  │
│ .yaml to user dir│  │
└──────┬───────────┘  │
       │              │
       └──────┬───────┘
              │
              ▼
┌─────────────────────────────────────────┐
│    Initialize Services (Monitor,        │
│    WebSocket, HTTP)                      │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Check Accessibility Permissions?       │
└──────────────┬──────────────────────────┘
               │
        ┌──────┴──────┐
        │             │
        ▼             ▼
   [GRANTED]    [NOT GRANTED]
        │             │
        │             ▼
        │    ┌──────────────────┐
        │    │ Show Permission  │
        │    │  Explanation     │
        │    │     Dialog       │
        │    └────────┬─────────┘
        │             │
        │      ┌──────┴──────┐
        │      │             │
        │      ▼             ▼
        │  [Open Settings] [Later]
        │      │             │
        │      ▼             │
        │  ┌──────────┐      │
        │  │ Trigger  │      │
        │  │ System   │      │
        │  │ Prompt   │      │
        │  └────┬─────┘      │
        │       │            │
        └───────┴────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│        App Ready - Running              │
└─────────────────────────────────────────┘
```

---

## Shutdown Sequence

```
┌─────────────────────────────────────────┐
│   User Quits App (Cmd+Q or Menu)       │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  applicationWillTerminate() called      │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│     performCleanShutdown()              │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  STEP 1: Stop ProcessMonitor            │
│  - Cancel timer (stopMonitoring())      │
│  - Stop FSEvents watcher                │
│  - Clear instance list                  │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  STEP 2: Stop WebSocketServer           │
│  - Cancel listener                      │
│  - Close all connections                │
│  - Clear connections array              │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  STEP 3: Stop HTTPServer                │
│  - Cancel all connection timeouts       │
│  - Clear active connections             │
│  - Cancel listener                      │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  STEP 4: Cancel Combine Subscriptions   │
│  - cancellables.removeAll()             │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  STEP 5: Nil Out Service References     │
│  - processMonitor = nil                 │
│  - webSocketServer = nil                │
│  - httpServer = nil                     │
│  - windowManager = nil                  │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│       App Terminated Cleanly            │
└─────────────────────────────────────────┘
```

**Key Points:**
- Sequential shutdown prevents race conditions
- Each service cleans up its own resources
- Combine subscriptions cancelled to prevent leaks
- All service references set to nil for deallocation
- Comprehensive logging at each step

---

## Testing Verification Steps

### Test 1: First Launch Experience

**Simulate "clean" state:**
```bash
# Delete UserDefaults key
defaults delete com.agentdeck.mac hasLaunchedBefore

# Delete config directory
rm -rf ~/.agent-deck/
```

**Expected behavior:**
1. ✅ Welcome dialog appears on launch
2. ✅ `~/.agent-deck/` directory is created
3. ✅ `~/.agent-deck/config.yaml` is created with content from `Resources/default-config.yaml`
4. ✅ Accessibility permission dialog appears (if not already granted)
5. ✅ Menubar icon appears
6. ✅ App starts successfully

**Verification:**
```bash
# Check UserDefaults was set
defaults read com.agentdeck.mac hasLaunchedBefore
# Expected: 1

# Check config file was created
ls -l ~/.agent-deck/config.yaml
cat ~/.agent-deck/config.yaml
# Expected: File exists with default configuration

# Check logs
log stream --predicate 'subsystem == "com.agentdeck.mac"' --level info
# Expected: "First launch - performing initial setup"
```

---

### Test 2: Subsequent Launch (Normal Operation)

**Precondition:**
- First launch already completed (UserDefaults key exists)
- Config file exists at `~/.agent-deck/config.yaml`

**Expected behavior:**
1. ✅ NO welcome dialog (only on first launch)
2. ✅ Config loaded from existing file (no recreation)
3. ✅ Services start normally
4. ✅ No accessibility prompt (if already granted)

**Verification:**
```bash
# Check logs
log stream --predicate 'subsystem == "com.agentdeck.mac"' --level info
# Expected: "Subsequent launch"
```

---

### Test 3: Config Auto-Creation

**Test bundled config:**
```bash
# Delete only config file (keep UserDefaults)
rm ~/.agent-deck/config.yaml
```

**Launch app**

**Expected behavior:**
1. ✅ No welcome dialog (not first launch)
2. ✅ Config file recreated from `Resources/default-config.yaml`
3. ✅ App starts normally

**Verification:**
```bash
cat ~/.agent-deck/config.yaml
# Expected: Contains comments and structure from bundled file

log stream --predicate 'subsystem == "com.agentdeck.mac"' | grep "config"
# Expected: "Created config from bundled default-config.yaml"
```

---

### Test 4: Accessibility Permissions Flow

**Simulate no permissions:**
```bash
# Remove accessibility permissions via System Settings:
# System Settings > Privacy & Security > Accessibility > Remove Agent Deck
```

**Launch app**

**Expected behavior:**
1. ✅ App launches normally
2. ✅ Accessibility explanation dialog appears
3. ✅ User can click "Open System Settings"
4. ✅ System Settings opens to Accessibility pane
5. ✅ macOS system permission dialog appears

**Try window switching:**
- Click on an agent in menubar dropdown
- Expected: Error message "Accessibility permissions required"

**Grant permissions and retry:**
- Enable Agent Deck in System Settings > Accessibility
- Try window switching again
- Expected: Window switches successfully

---

### Test 5: Clean Shutdown

**Start app normally, then quit**

**Verification in Activity Monitor:**
```bash
# Before quitting, note running processes
ps aux | grep -E "(Agent-Deck|agent-deck)"

# Quit app (Cmd+Q)

# After quitting, check for orphan processes
ps aux | grep -E "(Agent-Deck|agent-deck)"
# Expected: No Agent Deck processes running

# Check for network listeners
lsof -iTCP:3000 -sTCP:LISTEN
lsof -iTCP:3001 -sTCP:LISTEN
# Expected: No listeners on these ports

# Check logs
log show --predicate 'subsystem == "com.agentdeck.mac"' --last 1m
# Expected: Clean shutdown sequence logged:
#   - "Stopping ProcessMonitor..."
#   - "Stopping WebSocketServer..."
#   - "Stopping HTTPServer..."
#   - "Clean shutdown complete"
```

**Verify in Console.app:**
- Open Console.app
- Filter by subsystem: `com.agentdeck.mac`
- Scroll to end of log
- Verify shutdown sequence appears in order

---

### Test 6: Resource Cleanup

**Monitor resource usage during shutdown:**

```bash
# Terminal 1: Watch memory usage
while true; do
    ps aux | grep -E "Agent-Deck" | grep -v grep | awk '{print $4}'
    sleep 1
done

# Terminal 2: Watch open files
while true; do
    lsof -p $(pgrep Agent-Deck) 2>/dev/null | wc -l
    sleep 1
done

# Launch app, wait 30 seconds, then quit

# Expected:
# - Memory usage drops to 0 after quit
# - Open file descriptors drop to 0
# - No zombie processes remain
```

---

### Test 7: Permission Retry Mechanism

**Test repeated permission prompts:**

1. Launch app without accessibility permissions
2. Click "Remind Me Later" on permission dialog
3. Try to switch windows
4. Expected: Error message (no repeated dialogs)

5. Restart app
6. Expected: Permission dialog appears again (new session)

**Test manual reset:**
```swift
// In code or via debugger
windowManager?.resetPermissionPromptState()
```

Expected: Next window switch attempt shows permission dialog

---

## Integration Points

### ConfigManager Integration
- Called from `AppDelegate.loadConfiguration()`
- Creates `~/.agent-deck/` directory if missing
- Copies bundled `Resources/default-config.yaml` to user directory
- Falls back to programmatic generation if bundled file not found

### WindowManager Integration
- Used in `AppDelegate.checkAndPromptForAccessibilityPermissions()`
- Checks permissions on app launch
- Provides user-friendly error messages
- Retry mechanism prevents prompt spam

### Service Lifecycle
- **Startup:** AppDelegate → ConfigManager → ProcessMonitor → WebSocketServer → HTTPServer
- **Shutdown:** AppDelegate → ProcessMonitor → WebSocketServer → HTTPServer → Combine cleanup

---

## Code Standards Compliance

✅ **Logger Utility:** All logging uses `Logger.info()`, `Logger.error()`, `Logger.warning()`
✅ **Error Handling:** Comprehensive try-catch blocks with user-friendly messages
✅ **Thread Safety:** Shutdown sequence runs on main thread, services handle their own queues
✅ **Resource Management:** All resources released in proper order
✅ **Code Comments:** Methods documented with Tasks references (T074-T080)
✅ **Existing Patterns:** Follows existing project structure and naming conventions

---

## Known Limitations

1. **macOS System Settings URL:** The direct URL to Accessibility pane may not work on all macOS versions (Apple deprecated some URL schemes). The system permission dialog (`AXIsProcessTrustedWithOptions`) still works reliably.

2. **Permission Detection Timing:** Accessibility permissions require app restart to take effect. Users must quit and relaunch Agent Deck after granting permissions.

3. **Single Prompt Per Session:** The retry mechanism only prompts once per session to avoid annoyance. If user dismisses without granting, they won't be prompted again until restart (by design).

4. **Config File Comments:** Programmatically generated config (fallback) lacks human-readable comments. This should never happen in production since bundled file is included in bundle.

---

## Future Enhancements (Post-MVP)

- Add "Retry" button in accessibility error dialog (instead of requiring restart)
- Monitor accessibility permission changes in real-time (using DistributedNotificationCenter)
- Add "Troubleshooting" section in welcome dialog
- Persist user choice for "Remind Me Later" (don't ask again this session)
- Add telemetry for first-run funnel analysis

---

## Success Criteria

✅ **T074:** First-launch detection via UserDefaults
✅ **T075:** Auto-create default config from bundled resource
✅ **T076:** Check accessibility permissions before window switching
✅ **T077:** Show helpful error message with retry mechanism
✅ **T078:** Implement clean shutdown in applicationWillTerminate
✅ **T079:** Stop all services gracefully (ProcessMonitor, WebSocket, HTTP)
✅ **T080:** Release all resources (timers, observers, connections, Combine cancellables)

**Result:** Zero-config first-run experience complete. Users can install Agent Deck and start using it immediately with no manual configuration required.
