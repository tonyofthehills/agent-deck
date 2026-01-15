# Testing Issues Log

**Agent Deck MVP - Issue Tracking During Testing**

This document tracks all issues discovered during the comprehensive testing phase (Tasks T099-T118.4). Issues are categorized by severity and status.

---

## Issue Status Legend

- 🔴 **OPEN** - Not yet fixed
- 🟡 **IN PROGRESS** - Currently being worked on
- 🟢 **FIXED** - Resolved and verified
- 🔵 **WONTFIX** - Intentional limitation or deferred to later phase
- ⚪ **DUPLICATE** - Duplicate of another issue

## Severity Levels

- **CRITICAL** - Blocks MVP launch, must fix immediately
- **HIGH** - Major functionality broken, should fix before launch
- **MEDIUM** - Functionality impaired but workarounds exist
- **LOW** - Minor issue, cosmetic, or edge case
- **ENHANCEMENT** - Not a bug, but improvement opportunity

---

## Critical Issues (P0)

### ❌ None Currently

_(All critical issues from earlier testing phases have been resolved)_

---

## High Priority Issues (P1)

### Issue #H001: Icon 404 Errors in PWA 🟢 FIXED
**Severity:** High (Cosmetic but affects install experience)
**Status:** 🟢 FIXED
**Discovered:** 2025-11-04 (TEST_REPORT.md)
**Fixed:** 2025-11-04

**Description:**
PWA manifest references icons at `/icons/icon-192.png` and `/icons/icon-512.png`, but actual icons are in `Resources/` root, causing 404 errors in browser console.

**Impact:**
- PWA install may show blank icon
- Browser console shows errors
- User experience slightly degraded

**Steps to Reproduce:**
1. Load PWA: http://localhost:3000
2. Open browser DevTools → Console
3. Observe 404 errors for icon files

**Root Cause:**
Mismatch between manifest.json path (`/icons/...`) and actual file location (`Resources/icon-*.png`)

**Fix Applied:**
```bash
# Option 1: Create icons/ directory and move files
mkdir -p Agent-Deck/Resources/icons
mv Agent-Deck/Resources/icon-*.png Agent-Deck/Resources/icons/

# Option 2: Update manifest.json paths (easier)
# Edit pwa/manifest.json to reference /icon-192.png instead of /icons/icon-192.png
```

**Verification:**
- ✅ No 404 errors in console
- ✅ PWA icon displays correctly when installed
- ✅ Add to Home Screen shows proper icon

**Related Files:**
- `pwa/manifest.json`
- `Agent-Deck/Resources/icon-192.png`
- `Agent-Deck/Resources/icon-512.png`

---

### Issue #H002: Terminal Claude Code Not Detected 🔵 WONTFIX (Phase 3)
**Severity:** Medium (Feature limitation, not a bug)
**Status:** 🔵 WONTFIX (Enhancement for Phase 3)
**Discovered:** 2025-11-04 (TEST_REPORT.md)

**Description:**
Agent Deck only detects GUI Claude.app instances, not terminal-based `claude` CLI processes. This is due to using `NSWorkspace.runningApplications` which only returns GUI apps.

**Impact:**
- Users running `claude` command in terminal won't see those instances
- Only GUI Claude.app detected
- Reduces utility for CLI-heavy users

**Steps to Reproduce:**
1. Run `claude` in terminal
2. Open Agent Deck PWA
3. Observe: terminal Claude instance not shown

**Root Cause:**
`NSWorkspace.runningApplications` API returns GUI applications only. Terminal processes require `ps` command or `libproc` APIs.

**Workaround:**
Launch Claude Code as GUI app (`open -a Claude`)

**Enhancement Plan (Phase 3):**
```swift
// Use ProcessInfo or sysctl to enumerate all processes
func getAllProcesses() -> [ProcessInfo] {
    // Use sysctl(KERN_PROC_ALL) or parse `ps aux` output
    // Filter for processes matching "claude" pattern
}
```

**Effort Estimate:** 2-3 hours
**Priority:** Phase 3 (post-MVP)

**Related Files:**
- `Agent-Deck/Services/ProcessMonitor.swift`

---

## Medium Priority Issues (P2)

### Issue #M001: No "Different Network" Error Message 🔴 OPEN
**Severity:** Medium (Usability issue)
**Status:** 🔴 OPEN
**Discovered:** 2025-11-04 (TEST_REPORT.md)

**Description:**
When Mac and phone are on different WiFi networks, PWA shows generic "Connection refused" error instead of specific "different network" guidance.

**Impact:**
- Users may not understand why connection fails
- Trial-and-error troubleshooting required
- Poor UX for first-time setup

**Steps to Reproduce:**
1. Connect Mac to WiFi A
2. Connect phone to WiFi B (or cellular)
3. Try to access PWA: http://[MAC-IP]:3000
4. Observe generic error

**Expected Behavior:**
Error message should detect network mismatch and provide specific guidance:
```
Cannot connect to Agent Deck.

It looks like your phone and Mac are on different networks.

To fix:
1. Connect your phone to the same WiFi as your Mac
2. Current Mac network: "Home WiFi"
3. Your phone network: "Mobile Data"
```

**Implementation Approach:**
1. Detect local network name on Mac
2. Include network SSID in HTTP response headers
3. PWA compares and shows specific error if mismatch

**Effort Estimate:** 1-2 hours
**Priority:** Phase 3 (enhancement)

**Related Files:**
- `pwa/app.js` (WebSocket error handling)
- `Agent-Deck/Services/HTTPServer.swift` (add CORS headers with network info)

---

### Issue #M002: Deprecated Meta Tag Warning 🟢 FIXED
**Severity:** Low (Cosmetic console warning)
**Status:** 🟢 FIXED
**Discovered:** 2025-11-04

**Description:**
Browser console shows deprecation warning: `<meta name="apple-mobile-web-app-capable">` is deprecated.

**Impact:**
- No functional impact (still works)
- Console warning clutter
- May break in future iOS versions

**Fix Applied:**
Added modern equivalent meta tag:
```html
<meta name="mobile-web-app-capable" content="yes">
```

**Related Files:**
- `pwa/index.html`

---

### Issue #M003: Instance ID Changes on Reconnect 🔴 OPEN
**Severity:** Low (Minor inconsistency)
**Status:** 🔴 OPEN
**Discovered:** 2025-11-04

**Description:**
Each time Agent Deck restarts, instance IDs (UUIDs) regenerate, causing PWA to treat same Claude Code instance as "new" instance.

**Impact:**
- Minor - focus still works correctly
- Confusing for debugging (logs show different IDs)
- Could affect future features (favorites, custom labels)

**Root Cause:**
Instance ID generated as random UUID on each discovery:
```swift
let instance = AgentInstance(
    id: UUID(),  // ← Random UUID each time
    pid: pid,
    // ...
)
```

**Enhancement:**
Generate stable ID based on PID + working directory:
```swift
let stableId = UUID(uuidString: SHA256("\(pid):\(cwd)"))
```

**Effort Estimate:** 30 minutes
**Priority:** Low (Phase 3 enhancement)

**Related Files:**
- `Agent-Deck/Models/AgentInstance.swift`
- `Agent-Deck/Services/ProcessMonitor.swift`

---

## Low Priority Issues (P3)

### Issue #L001: QR Code Manual Testing Required 🟡 IN PROGRESS
**Severity:** Low (Test coverage gap)
**Status:** 🟡 IN PROGRESS
**Discovered:** 2025-11-04 (TEST_REPORT.md)

**Description:**
QR code generation cannot be tested with Playwright (native menubar UI). Manual testing required.

**Impact:**
- Test coverage gap
- Automated tests skip US3 (QR Setup)
- Requires human verification

**Manual Test Steps:**
1. Click Agent Deck menubar icon
2. Select "View Mobile Interface" (if implemented)
3. Verify QR code displays correctly
4. Scan with phone camera
5. Verify URL matches local IP

**Status:**
- Automated test: ⚠️ SKIPPED (Playwright limitation)
- Manual test: 🟡 PENDING

**Effort to Automate:** Not feasible (native macOS UI)
**Workaround:** Document manual test procedure

**Related Files:**
- `Agent-Deck/Views/QRCodeView.swift`
- `TEST_PROCEDURE_MOBILE.md` (manual test steps)

---

### Issue #L002: WebSocket Frame Decoding Crash (HISTORICAL) 🟢 FIXED
**Severity:** Critical (was P0, now resolved)
**Status:** 🟢 FIXED
**Discovered:** 2025-11-03 (TEST_REPORT.md)
**Fixed:** 2025-11-03

**Description:**
App crashed with `EXC_BREAKPOINT` when receiving masked WebSocket frames from PWA client.

**Root Cause:**
Index out of bounds when accessing `maskingKey` slice. Data slices use base offset for indices, not zero-based.

**Fix Applied:**
```swift
// Before (crashed):
let maskingKey = data[offset..<offset+4]
payload[index] ^= maskingKey[i % 4]  // CRASH

// After (works):
let maskingKey = Array(data[offset..<offset+4])
unmaskedPayload.append(byte ^ maskingKey[i % 4])  // ✅
```

**Verification:**
- ✅ No crashes after fix
- ✅ Masked WebSocket frames decode correctly
- ✅ PWA connects successfully

**Lesson Learned:**
Data slices in Swift maintain base offset. Convert to Array for zero-based indexing.

**Related Files:**
- `Agent-Deck/Services/WebSocketServer.swift:335`
- `LESSONS_LEARNED.md`

---

### Issue #L003: lsof Path Incorrect (HISTORICAL) 🟢 FIXED
**Severity:** Medium (was P1, now resolved)
**Status:** 🟢 FIXED
**Discovered:** 2025-11-03
**Fixed:** 2025-11-03

**Description:**
Working directory detection failed with "lsof not found" error. Incorrect path `/usr/bin/lsof` used (actual path: `/usr/sbin/lsof`).

**Fix Applied:**
Changed path from `/usr/bin/lsof` to `/usr/sbin/lsof`

**Verification:**
- ✅ Working directories now detected correctly
- ✅ Agent cards show actual project paths

**Related Files:**
- `Agent-Deck/Services/ProcessMonitor.swift:132`

---

## Enhancement Opportunities (Not Bugs)

### Enhancement #E001: Visual Feedback Animations
**Priority:** Low
**Phase:** Phase 3+

**Description:**
Add visual feedback animations for better UX:
- Card tap animation (ripple effect)
- Focus success animation (green flash)
- Loading spinner during connection
- Smooth transitions for agent list updates

**Effort Estimate:** 2-3 hours
**Impact:** Improved user experience, more polished feel

---

### Enhancement #E002: Offline PWA Support
**Priority:** Medium
**Phase:** Phase 4+

**Description:**
Implement service worker caching for offline PWA skeleton:
- Cache HTML, CSS, JS for offline loading
- Show "Offline" state with cached UI
- Restore connection when network available

**Effort Estimate:** 3-4 hours
**Impact:** Better PWA experience, works when Mac temporarily offline

---

### Enhancement #E003: Multi-Monitor Support
**Priority:** Low
**Phase:** Phase 5+

**Description:**
Track which display/monitor each agent instance is on:
- Show monitor indicator in PWA
- Window switching focuses correct display
- Useful for multi-monitor setups

**Effort Estimate:** 4-5 hours
**Impact:** Improved UX for multi-monitor users

---

## Testing Metrics

**As of:** 2025-11-06

| Category | Open | In Progress | Fixed | Total |
|----------|------|-------------|-------|-------|
| Critical (P0) | 0 | 0 | 3 | 3 |
| High (P1) | 0 | 0 | 2 | 2 |
| Medium (P2) | 2 | 0 | 1 | 3 |
| Low (P3) | 0 | 1 | 2 | 3 |
| Enhancements | 3 | 0 | 0 | 3 |
| **TOTAL** | **5** | **1** | **8** | **14** |

**Pass Rate:** 94% (17/18 tests passing as of TEST_REPORT.md)

---

## Issue Templates

### Bug Report Template

```markdown
### Issue #[ID]: [Title]
**Severity:** [Critical / High / Medium / Low]
**Status:** [🔴 OPEN / 🟡 IN PROGRESS / 🟢 FIXED / 🔵 WONTFIX]
**Discovered:** YYYY-MM-DD
**Fixed:** YYYY-MM-DD (if applicable)

**Description:**
[Clear description of the issue]

**Impact:**
- [How it affects users]
- [Scope of impact]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Observe result]

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Root Cause:**
[Technical explanation]

**Fix Applied:** (if fixed)
[Description of fix with code snippets if applicable]

**Verification:**
- [ ] Test case added
- [ ] Fix verified on [device/OS]
- [ ] No regressions introduced

**Related Files:**
- `path/to/file.swift`

**Related Issues:**
- #[other issue number]
```

---

### Enhancement Template

```markdown
### Enhancement #E[ID]: [Title]
**Priority:** [High / Medium / Low]
**Phase:** [Phase N]

**Description:**
[What improvement to make]

**User Benefit:**
[How this helps users]

**Implementation Approach:**
[Technical approach]

**Effort Estimate:** [Hours/Days]
**Impact:** [High / Medium / Low]
```

---

## Closing Notes

**For Developers:**
- Update this log during testing sessions
- Close issues with verification steps
- Link to commits/PRs when fixing
- Update metrics table after changes

**For Testers:**
- Report new issues using templates above
- Include reproduction steps
- Attach screenshots/logs when relevant
- Verify fixes before marking as FIXED

**For Project Manager:**
- Review open P0/P1 issues before launch
- Prioritize based on user impact
- Track trends (common failure modes)
- Plan enhancements for future phases

---

**Last Updated:** 2025-11-06
**Next Review:** Before MVP launch
