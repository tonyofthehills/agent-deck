# Monitoring Fixes - Testing Guide

Quick reference for testing the critical bug fixes in Agent Deck's monitoring system.

---

## Quick Test Scenarios

### Test 1: Subagents Appear and Disappear ⏱️ 2 minutes

**Setup:**
1. Open Agent Deck (menubar) and PWA (phone)
2. Start Claude Code in a project

**Test Steps:**
```bash
# In Claude Code, trigger a subagent:
# Ask: "Research SwiftUI best practices using a subagent"
```

**Expected Results:**
- ✅ PWA shows: "activeSubagents: 1"
- ✅ Subagent description appears
- ⏳ Wait for subagent to complete
- ✅ PWA shows: "activeSubagents: 0"
- ✅ Subagent disappears from list

**FAIL Conditions:**
- ❌ Subagent count never decreases
- ❌ Completed subagents persist forever

---

### Test 2: Status Doesn't Bounce ⏱️ 3 minutes

**Setup:**
1. Agent Deck running with PWA connected
2. Claude Code working on multi-todo task

**Test Steps:**
```bash
# In Claude Code:
# Ask: "Create a todo list with 3 tasks and start working on the first one"
```

**Watch PWA Status Field:**
- Should show: `"status": "working"`
- Should NOT flicker between working/idle/done

**Expected Results:**
- ✅ Status stable at "working" during active task
- ✅ Status changes to "idle" when all todos pending
- ✅ No rapid flickering

**FAIL Conditions:**
- ❌ Status bounces between working/done every 2 seconds
- ❌ Status shows "done" while actively working

---

### Test 3: Path Matching Precision ⏱️ 4 minutes

**Setup:**
1. Terminal 1: `cd ~/myproject && claude`
2. Terminal 2: `cd ~/myproject/subdir && claude`
3. Agent Deck PWA showing both instances

**Test Steps:**
1. In Terminal 1 Claude: "Create a todo: Fix authentication"
2. Check PWA - instance 1 should show that todo
3. In Terminal 2 Claude: "Create a todo: Update database schema"
4. Check PWA - instance 2 should show different todo

**Expected Results:**
- ✅ Instance 1 shows: "Fix authentication"
- ✅ Instance 2 shows: "Update database schema"
- ✅ No data mixing

**FAIL Conditions:**
- ❌ Both instances show same todos
- ❌ Data from one instance appears on the other

---

### Test 4: Todo List Accuracy ⏱️ 3 minutes

**Setup:**
1. Agent Deck + Claude Code running

**Test Steps:**
```bash
# In Claude Code:
# Step 1: "Create a todo list with these tasks:
#   1. Setup database
#   2. Create API endpoints
#   3. Write tests"

# Verify PWA shows 3 todos

# Step 2: "Mark 'Setup database' as completed"

# Verify PWA shows 2 todos (completed one removed)

# Step 3: "Create a new todo list:
#   1. Deploy to staging
#   2. Run smoke tests"

# Verify PWA shows ONLY 2 new todos (old ones gone)
```

**Expected Results:**
- ✅ Initially: 3 todos
- ✅ After completion: 2 todos (completed removed)
- ✅ After new TodoWrite: 2 different todos
- ✅ Old todos completely replaced

**FAIL Conditions:**
- ❌ Completed todos persist
- ❌ See todos from previous TodoWrite calls
- ❌ Todo count keeps growing

---

### Test 5: Instance Cleanup ⏱️ 1 minute

**Setup:**
1. Agent Deck running
2. Claude Code instance active
3. PWA showing the instance

**Test Steps:**
```bash
# Kill Claude Code:
# Ctrl+C in terminal OR close Terminal window
```

**Expected Results:**
- ⏳ Wait 2-4 seconds
- ✅ Instance disappears from PWA
- ✅ Instance count decreases

**FAIL Conditions:**
- ❌ Instance persists after process killed
- ❌ Takes >10 seconds to disappear

---

## Detailed Test: Multi-Instance Scenario ⏱️ 10 minutes

**Comprehensive test covering all fixes:**

### Setup
```bash
# Terminal 1 (Project A)
cd ~/projects/app-001-famrally
claude

# Terminal 2 (Project B)
cd ~/projects/app-009-agent-deck
claude

# Open Agent Deck PWA on phone
```

### Test Sequence

**1. Initial State** (0:00)
- PWA should show 2 instances
- Each with correct working directory
- Status: idle

**2. Start Work in Project A** (0:30)
```
In Claude Terminal 1:
"Create a todo list:
1. Implement user authentication
2. Add database migrations
3. Write integration tests

Start with authentication."
```

**Expected:**
- Project A: status "working", 3 todos (1 in_progress)
- Project B: status "idle", no todos
- ✅ Data doesn't mix

**3. Trigger Subagent in Project A** (2:00)
```
In Claude Terminal 1:
"Research authentication best practices using a subagent"
```

**Expected:**
- Project A: 1 active subagent
- Project B: 0 subagents
- ✅ Subagent appears

**4. Complete Task in Project A** (4:00)
```
Wait for subagent and task to complete
```

**Expected:**
- Project A: subagent count → 0
- Project A: authentication todo → completed (removed from list)
- Project A: 2 remaining todos
- ✅ Subagent disappears
- ✅ Completed todo removed

**5. Start Work in Project B** (5:00)
```
In Claude Terminal 2:
"Create a todo:
1. Fix QR code rendering

Start working on it."
```

**Expected:**
- Project A: Still showing 2 todos
- Project B: 1 todo, status "working"
- ✅ Independent operation

**6. Watch Status Stability** (6:00-8:00)
```
Continue working in both projects
Watch PWA status fields
```

**Expected:**
- ✅ No flickering between working/done
- ✅ Status reflects actual work state

**7. Kill Project A** (8:00)
```
Ctrl+C in Terminal 1
```

**Expected:**
- Project A instance disappears within 2-4s
- Project B still visible and working
- ✅ Clean removal

**8. New TodoWrite in Project B** (9:00)
```
In Claude Terminal 2:
"Create a new todo list:
1. Deploy to staging
2. Run smoke tests"
```

**Expected:**
- Project B: Shows ONLY new 2 todos
- Old "Fix QR code" todo is gone
- ✅ Latest TodoWrite replaces old

---

## Debugging Failed Tests

### If Subagents Don't Disappear:

**Check:**
1. Open transcript file: `~/.claude/projects/*/[session].jsonl`
2. Search for `"type":"tool_result"` entries
3. Verify they have `"tool_use_id"` field matching Task tool_use

**Look for:**
```json
{"type":"tool_use","name":"Task","id":"toolu_123"}
// Should eventually have:
{"type":"tool_result","tool_use_id":"toolu_123"}
```

### If Status Bounces:

**Check:**
1. Enable debug logging in ProcessMonitor
2. Watch console for status changes
3. Look for rapid toggling every 2s

**Add logging:**
```swift
Logger.debug("Status transition: \(oldStatus) → \(newStatus), hasInProgress: \(hasInProgressTodos)", log: Logger.monitoring)
```

### If Path Matching Fails:

**Check:**
1. Print working directories in console
2. Verify exact match (no substring matching)
3. Check session IDs are being extracted

**Add logging:**
```swift
Logger.debug("Instance WD: \($0.workingDirectory), Transcript WD: \(workingDir), Session: \(sessionId)", log: Logger.monitoring)
```

### If Todos Accumulate:

**Check:**
1. Verify reverse iteration is working
2. Check if completed todos are filtered
3. Look for multiple TodoWrite calls in transcript

**Add logging:**
```swift
Logger.debug("Found TodoWrite with \(todos.count) todos, completed filtered: \(filteredCount)", log: Logger.monitoring)
```

---

## Test Environment Requirements

**macOS:**
- macOS 12+ (Monterey or later)
- Xcode installed (for building)
- Terminal.app or Ghostty

**Claude Code:**
- Latest version from claude.ai/code
- Running in multiple terminal windows

**Agent Deck:**
- Mac app running (menubar)
- WebSocket server on port 3000
- PWA connected from mobile device

**Network:**
- Mac and mobile on same WiFi
- Port 3000 accessible

---

## Success Criteria

All tests pass if:

✅ Subagents appear when Task tool starts
✅ Subagents disappear when Task tool completes
✅ Status stable during active work (no bouncing)
✅ Multiple instances show independent data (no mixing)
✅ Todo list shows only latest TodoWrite
✅ Completed todos removed from display
✅ Instances disappear within 2-4s after process kill

**Pass Rate:** 7/7 scenarios must pass for deployment

---

## Quick Command Reference

**View Logs:**
```bash
# macOS Console
log stream --predicate 'subsystem == "com.agentdeck.app"'

# Filter to monitoring only
log stream --predicate 'subsystem == "com.agentdeck.app" AND category == "monitoring"'
```

**Check Transcript:**
```bash
# Find transcript files
ls -la ~/.claude/projects/*/

# View latest transcript
tail -f ~/.claude/projects/[project]/[session].jsonl | jq .
```

**Monitor PWA:**
```bash
# WebSocket traffic (if wscat installed)
wscat -c ws://[mac-ip]:3000
```

---

## Automated Test Script (Future)

```bash
#!/bin/bash
# test-monitoring-fixes.sh

echo "Testing Agent Deck Monitoring Fixes..."

# Test 1: Subagents
echo "Test 1: Subagent lifecycle"
# Start Claude with subagent task
# Verify count increases then decreases
# PASS/FAIL

# Test 2: Status stability
echo "Test 2: Status bouncing"
# Monitor status field for 30s
# Count transitions
# FAIL if >2 transitions
# PASS

# Test 3: Path matching
echo "Test 3: Instance isolation"
# Start 2 Claude instances
# Verify data independence
# PASS/FAIL

# Test 4: Todo accuracy
echo "Test 4: Todo list updates"
# Create, complete, replace todos
# Verify counts match expected
# PASS/FAIL

# Test 5: Cleanup
echo "Test 5: Instance removal"
# Kill process
# Time until disappearance
# FAIL if >5s
# PASS

echo "Test suite complete: X/5 passed"
```

---

**Testing Guide Version:** 1.0
**Last Updated:** 2025-01-06
**Related:** MONITORING_FIXES_SUMMARY.md
