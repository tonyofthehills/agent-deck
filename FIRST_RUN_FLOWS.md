# First-Run Experience - Visual Flows

Quick visual reference for first-run behavior and shutdown sequence.

---

## Flow 1: First Launch (Clean State)

```
┌─────────────────────────────────────────────────────────────┐
│                    USER LAUNCHES APP                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
            ┌────────────────────┐
            │ applicationDid     │
            │ FinishLaunching()  │
            └─────────┬──────────┘
                      │
                      ▼
            ┌────────────────────┐
            │ handleFirstLaunch()│
            └─────────┬──────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ Check UserDefaults:          │
       │ hasLaunchedBefore = false    │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │  Show Welcome Dialog         │
       │                              │
       │  "Welcome to Agent Deck!"    │
       │                              │
       │  - What it does              │
       │  - Next steps                │
       │  - Config location           │
       │                              │
       │  [Get Started]               │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ Set hasLaunchedBefore = true │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ setupStatusBar()             │
       │ (Create menubar icon)        │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ loadConfiguration()          │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ ConfigManager:               │
       │ Check ~/.agent-deck/ exists? │
       └──────────────┬───────────────┘
                      │
              ┌───────┴───────┐
              │               │
              ▼               ▼
           [NO]            [YES]
              │               │
              ▼               │
    ┌──────────────────┐      │
    │ Create directory │      │
    └────────┬─────────┘      │
             │                │
             ▼                │
    ┌──────────────────────────────┐
    │ Check config.yaml exists?    │
    └────────┬─────────────────────┘
             │
      ┌──────┴──────┐
      │             │
      ▼             ▼
    [NO]         [YES]
      │             │
      ▼             │
┌─────────────────────────────┐
│ Copy Resources/             │
│ default-config.yaml         │
│ to ~/.agent-deck/           │
└─────────┬───────────────────┘
          │                   │
          └──────┬────────────┘
                 │
                 ▼
       ┌──────────────────────────────┐
       │ Config loaded successfully   │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ setupServices()              │
       │ - ProcessMonitor             │
       │ - WebSocketServer            │
       │ - HTTPServer                 │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ checkAndPromptFor            │
       │ AccessibilityPermissions()   │
       └──────────────┬───────────────┘
                      │
              ┌───────┴───────┐
              │               │
              ▼               ▼
        [GRANTED]      [NOT GRANTED]
              │               │
              │               ▼
              │    ┌────────────────────────┐
              │    │ Show Permission Dialog │
              │    │                        │
              │    │ "Accessibility         │
              │    │  Permissions Required" │
              │    │                        │
              │    │ [Open Settings]        │
              │    │ [Remind Me Later]      │
              │    └─────────┬──────────────┘
              │              │
              │       ┌──────┴──────┐
              │       │             │
              │       ▼             ▼
              │   [Open]        [Later]
              │       │             │
              │       ▼             │
              │   ┌──────────────┐  │
              │   │ Open System  │  │
              │   │ Settings +   │  │
              │   │ Trigger      │  │
              │   │ Permission   │  │
              │   │ Dialog       │  │
              │   └──────┬───────┘  │
              │          │          │
              └──────────┴──────────┘
                         │
                         ▼
          ┌──────────────────────────────┐
          │   APP READY - MENUBAR ICON   │
          │   Services Running           │
          └──────────────────────────────┘
```

---

## Flow 2: Subsequent Launch (Normal Operation)

```
┌─────────────────────────────────────────────────────────────┐
│                    USER LAUNCHES APP                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
            ┌────────────────────┐
            │ handleFirstLaunch()│
            └─────────┬──────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ Check UserDefaults:          │
       │ hasLaunchedBefore = true     │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ Log: "Subsequent launch"     │
       │ (No welcome dialog)          │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ setupStatusBar()             │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ loadConfiguration()          │
       │ (Existing config)            │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ setupServices()              │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ Check accessibility          │
       │ (Only prompt if not granted) │
       └──────────────┬───────────────┘
                      │
                      ▼
          ┌──────────────────────────────┐
          │   APP READY                  │
          └──────────────────────────────┘
```

---

## Flow 3: Config Auto-Recreation

```
┌─────────────────────────────────────────────────────────────┐
│  Config file missing (but UserDefaults set)                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ loadConfiguration()          │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ Check ~/.agent-deck/         │
       │ config.yaml exists?          │
       └──────────────┬───────────────┘
                      │
                      ▼
                    [NO]
                      │
                      ▼
       ┌──────────────────────────────┐
       │ createDefaultConfig()        │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ Try: Copy bundled            │
       │ Resources/default-config.yaml│
       └──────────────┬───────────────┘
                      │
              ┌───────┴────────┐
              │                │
              ▼                ▼
         [SUCCESS]        [FAILED]
              │                │
              │                ▼
              │     ┌────────────────────┐
              │     │ Fallback:          │
              │     │ Generate           │
              │     │ programmatically   │
              │     └─────────┬──────────┘
              │               │
              └───────┬───────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ Config created successfully  │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ Load and parse config        │
       └──────────────┬───────────────┘
                      │
                      ▼
          ┌──────────────────────────────┐
          │   Continue normal startup    │
          └──────────────────────────────┘
```

---

## Flow 4: Accessibility Permission Retry

```
┌─────────────────────────────────────────────────────────────┐
│  User tries to switch windows                               │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ WindowManager.focusWindow()  │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ checkAccessibilityPermissions│
       └──────────────┬───────────────┘
                      │
              ┌───────┴────────┐
              │                │
              ▼                ▼
         [GRANTED]      [NOT GRANTED]
              │                │
              ▼                ▼
       ┌──────────────┐  ┌─────────────────┐
       │ Switch       │  │ Return error    │
       │ window       │  │ to WebSocket    │
       │ successfully │  │ client          │
       └──────────────┘  └────────┬────────┘
                                  │
                                  ▼
                      ┌───────────────────────────┐
                      │ hasPromptedForPermissions?│
                      └───────────┬───────────────┘
                                  │
                          ┌───────┴────────┐
                          │                │
                          ▼                ▼
                      [FALSE]          [TRUE]
                          │                │
                          ▼                │
              ┌────────────────────────┐   │
              │ Show Permission Dialog │   │
              │ (Only once per session)│   │
              └─────────┬──────────────┘   │
                        │                  │
                        ▼                  │
              ┌────────────────────────┐   │
              │ Set hasPrompted = true │   │
              └─────────┬──────────────┘   │
                        │                  │
                        └──────┬───────────┘
                               │
                               ▼
                  ┌────────────────────────────┐
                  │ Return error to client     │
                  │ "Accessibility permissions │
                  │  required"                 │
                  └────────────────────────────┘
```

---

## Flow 5: Clean Shutdown Sequence

```
┌─────────────────────────────────────────────────────────────┐
│                    USER QUITS APP (Cmd+Q)                   │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ applicationWillTerminate()   │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ performCleanShutdown()       │
       └──────────────┬───────────────┘
                      │
                      │
                      ▼
       ┌──────────────────────────────┐
       │ STEP 1:                      │
       │ processMonitor.              │
       │   stopMonitoring()           │
       │                              │
       │ • Cancel timer               │
       │ • Stop FSEvents watcher      │
       │ • Clear instances            │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ STEP 2:                      │
       │ webSocketServer.stop()       │
       │                              │
       │ • Cancel listener            │
       │ • Close all connections      │
       │ • Clear connections array    │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ STEP 3:                      │
       │ httpServer.stop()            │
       │                              │
       │ • Cancel connection timeouts │
       │ • Clear active connections   │
       │ • Cancel listener            │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ STEP 4:                      │
       │ cancellables.removeAll()     │
       │                              │
       │ • Cancel all Combine         │
       │   subscriptions              │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ STEP 5:                      │
       │ Nil out references           │
       │                              │
       │ • processMonitor = nil       │
       │ • webSocketServer = nil      │
       │ • httpServer = nil           │
       │ • windowManager = nil        │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │ Log: "Clean shutdown         │
       │       complete"              │
       └──────────────┬───────────────┘
                      │
                      ▼
          ┌──────────────────────────────┐
          │   APP TERMINATED CLEANLY     │
          │   • No orphan processes      │
          │   • No network listeners     │
          │   • All memory freed         │
          └──────────────────────────────┘
```

---

## Decision Tree: When to Show Dialogs

```
         ┌─────────────────┐
         │  App Launches   │
         └────────┬────────┘
                  │
                  ▼
       ┌────────────────────────┐
       │ First launch?          │
       │ (UserDefaults check)   │
       └────────┬───────────────┘
                │
         ┌──────┴──────┐
         │             │
         ▼             ▼
       [YES]         [NO]
         │             │
         ▼             │
   ┌──────────┐        │
   │ Show     │        │
   │ Welcome  │        │
   │ Dialog   │        │
   └────┬─────┘        │
        │              │
        └──────┬───────┘
               │
               ▼
    ┌────────────────────────┐
    │ Accessibility granted? │
    └────────┬───────────────┘
             │
      ┌──────┴──────┐
      │             │
      ▼             ▼
    [YES]         [NO]
      │             │
      │             ▼
      │    ┌─────────────────┐
      │    │ Show Permission │
      │    │ Dialog          │
      │    └────────┬────────┘
      │             │
      │   ┌─────────┴─────────┐
      │   │                   │
      │   ▼                   ▼
      │ [Open Settings]  [Remind Later]
      │   │                   │
      └───┴───────┬───────────┘
                  │
                  ▼
           ┌──────────────┐
           │ Start        │
           │ Services     │
           └──────────────┘
```

---

## State Transitions

```
                        FIRST LAUNCH
┌──────────────────────────────────────────────────────┐
│ State: Clean (no UserDefaults, no config)            │
│                                                       │
│ Actions:                                              │
│ • Show welcome dialog                                 │
│ • Create config directory                             │
│ • Copy default config                                 │
│ • Set hasLaunchedBefore = true                        │
│ • Prompt for permissions                              │
└─────────────────────┬────────────────────────────────┘
                      │
                      ▼
                SUBSEQUENT LAUNCHES
┌──────────────────────────────────────────────────────┐
│ State: Configured (UserDefaults set, config exists)  │
│                                                       │
│ Actions:                                              │
│ • Load existing config                                │
│ • Start services normally                             │
│ • Only prompt permissions if missing                  │
└─────────────────────┬────────────────────────────────┘
                      │
                      ▼
                   RUNNING
┌──────────────────────────────────────────────────────┐
│ State: Active (all services running)                 │
│                                                       │
│ Services:                                             │
│ • ProcessMonitor (polling + FSEvents)                 │
│ • WebSocketServer (port 3001)                         │
│ • HTTPServer (port 3000)                              │
│ • Combine subscriptions active                        │
└─────────────────────┬────────────────────────────────┘
                      │
                      ▼
                  SHUTDOWN
┌──────────────────────────────────────────────────────┐
│ State: Terminating                                    │
│                                                       │
│ Sequence:                                             │
│ 1. Stop ProcessMonitor                                │
│ 2. Stop WebSocketServer                               │
│ 3. Stop HTTPServer                                    │
│ 4. Cancel Combine subscriptions                       │
│ 5. Nil out references                                 │
└─────────────────────┬────────────────────────────────┘
                      │
                      ▼
                 TERMINATED
┌──────────────────────────────────────────────────────┐
│ State: Stopped (no processes, no listeners)          │
│                                                       │
│ Verification:                                         │
│ • ps aux | grep agent-deck → empty                    │
│ • lsof -iTCP:3000,3001 → empty                        │
│ • Activity Monitor → no Agent-Deck entry              │
└──────────────────────────────────────────────────────┘
```

---

## Error Handling Flow

```
                ┌─────────────────┐
                │  Any Operation  │
                └────────┬────────┘
                         │
                         ▼
                  ┌──────────────┐
                  │ Try operation│
                  └──────┬───────┘
                         │
                  ┌──────┴──────┐
                  │             │
                  ▼             ▼
             [SUCCESS]      [ERROR]
                  │             │
                  ▼             ▼
       ┌──────────────┐  ┌─────────────────┐
       │ Log success  │  │ Catch error     │
       │ Continue     │  │ Log error       │
       └──────────────┘  └────────┬────────┘
                                  │
                                  ▼
                         ┌─────────────────┐
                         │ Is critical?    │
                         └────────┬────────┘
                                  │
                          ┌───────┴────────┐
                          │                │
                          ▼                ▼
                       [YES]            [NO]
                          │                │
                          ▼                ▼
                ┌──────────────────┐  ┌──────────────┐
                │ Show NSAlert     │  │ Log warning  │
                │ to user          │  │ Continue     │
                │                  │  └──────────────┘
                │ • Clear message  │
                │ • Actionable     │
                │ • Next steps     │
                └──────────────────┘
```

---

## Summary of Key Behaviors

| Scenario | Welcome Dialog | Permission Dialog | Config Created | Notes |
|----------|---------------|-------------------|----------------|-------|
| **First launch (clean)** | ✅ Yes | ✅ Yes (if needed) | ✅ Yes | Full onboarding |
| **Subsequent launch** | ❌ No | ❌ No (if granted) | ❌ No (uses existing) | Normal operation |
| **Config deleted** | ❌ No | ❌ No | ✅ Yes (recreated) | Auto-recovery |
| **Permissions revoked** | ❌ No | ✅ Yes (on launch) | ❌ No | Permission prompt only |
| **Window switch attempt without permissions** | ❌ No | ⚠️ Once per session | ❌ No | Error with retry |

---

**Visual Quick Reference Complete** ✅

For detailed implementation, see:
- FIRST_RUN_IMPLEMENTATION.md (comprehensive details)
- IMPLEMENTATION_SUMMARY.md (quick reference)
- VERIFICATION_CHECKLIST.md (testing steps)
