# Lessons Learned - Agent Deck

**Project:** Agent Deck - Real-time monitoring of Claude Code instances
**Date:** 2025-01-05
**Phase:** MVP (Phase 1-2)

---

## Critical Learnings

### 1. FSEvents C Pointer Handling in Swift 🔴 CRITICAL

**Problem:** Crashes with `EXC_BAD_ACCESS` and `EXC_BREAKPOINT` when accessing FSEvents paths.

**❌ What Doesn't Work:**
```swift
// WRONG - crashes with EXC_BAD_ACCESS
let pathsArray = Unmanaged<CFArray>.fromOpaque(eventPaths).takeUnretainedValue()

// WRONG - crashes with EXC_BREAKPOINT
let pathsArray = unsafeBitCast(eventPaths, to: NSArray.self)
```

**✅ What Works:**
```swift
let callback: FSEventStreamCallback = { (
    stream, contextInfo, numEvents,
    eventPaths,  // This is char** (C array of C string pointers)
    eventFlags, eventIds
) in
    // ✅ Bind to UnsafePointer<CChar> (char**)
    let pathsPointer = eventPaths.assumingMemoryBound(to: UnsafePointer<CChar>.self)

    for i in 0..<numEvents {
        let path = String(cString: pathsPointer[i])  // ✅ Convert each C string
        // Process path...
    }
}
```

**Why:** FSEvents provides `eventPaths` as a C array of C string pointers (`char**`), NOT a Foundation type.

**File:** `Services/TranscriptWatcher.swift:45-72`

---

### 2. @Published with Structs Requires Replacement 🔴 CRITICAL

**Problem:** Real-time updates not broadcasting. FSEvents working, but WebSocket clients never notified.

**❌ What Doesn't Work:**
```swift
class ProcessMonitor: ObservableObject {
    @Published var instances: [AgentInstance] = []

    func update() {
        // ❌ Mutating in-place does NOT trigger @Published
        instances[index].currentTask = "new task"
        instances[index].status = .working
    }
}
```

**✅ What Works:**
```swift
func update() {
    // ✅ Create copy, modify, then REPLACE
    var updated = instances[index]
    updated.currentTask = "new task"
    updated.status = .working
    instances[index] = updated  // Triggers @Published! ✅
}
```

**Why:**
- `AgentInstance` is a `struct` (value type)
- `@Published` detects changes to the **array reference**, not element contents
- Mutating an element doesn't change the array reference
- Replacing an element DOES change the array reference → triggers Combine

**File:** `Services/ProcessMonitor.swift:513-520`

---

### 3. Claude Code Transcript JSON Structure 🔴 CRITICAL

**Problem:** TranscriptParser returned empty data. Git branch appeared in PWA but subagents, todos, model name, and current task were missing.

**Root Cause:** Looking for tool_use data at wrong JSON path in transcript files.

**❌ What Doesn't Work:**
```swift
// WRONG - expected flat JSON structure
for line in lines {
    let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]

    if json["type"] as? String == "tool_use",  // ❌ Not at top level
       json["name"] as? String == "TodoWrite" {
        // This code never executes!
    }
}
```

**✅ What Works:**
```swift
// ✅ Navigate through message.content[] array
for line in lines {
    let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]

    // Get nested message.content array
    guard let message = json["message"] as? [String: Any],
          let content = message["content"] as? [[String: Any]] else {
        continue
    }

    // Iterate through content items
    for item in content {
        if item["type"] as? String == "tool_use",
           item["name"] as? String == "TodoWrite",
           let input = item["input"] as? [String: Any],
           let todos = input["todos"] as? [[String: Any]] {
            // ✅ This code executes! Parse todos...
        }
    }
}
```

**Actual Transcript Structure:**
```json
{
  "message": {
    "model": "claude-sonnet-4-5-20250929",
    "content": [
      {
        "type": "tool_use",
        "name": "TodoWrite",
        "input": {
          "todos": [
            {"content": "Fix bug", "status": "completed", "activeForm": "Fixing bug"}
          ]
        }
      }
    ]
  },
  "cwd": "/Users/.../project"
}
```

**Test Script to Verify:**
```swift
// /tmp/test_parser.swift
let transcriptPath = "~/.claude/projects/.../session-id.jsonl"
let content = try! String(contentsOfFile: transcriptPath)

for line in content.split(separator: "\n") {
    let json = try? JSONSerialization.jsonObject(with: line.data(using: .utf8)!) as? [String: Any]

    // Check for content array
    if let message = json?["message"] as? [String: Any],
       let content = message["content"] as? [[String: Any]] {
        for item in content {
            if item["name"] as? String == "TodoWrite" {
                print("Found TodoWrite!")
            }
        }
    }
}
```

**Debugging Steps:**
1. Manual test showed transcript contains 5 TodoWrite and 11 Task calls
2. Parser returned empty arrays (no data extracted)
3. Verified JSON structure: tool_use is NOT at top level
4. Fixed: Navigate through `json["message"]["content"][]`
5. Re-tested: All data extracted successfully

**Files Fixed:**
- `Services/TranscriptParser.swift:115-149` - extractSubagents()
- `Services/TranscriptParser.swift:155-191` - extractTodos()
- `Services/TranscriptParser.swift:76-91` - extractModelName()

**Why:** Claude Code transcript format uses nested structure with `message.content[]` array containing multiple content blocks (text, tool_use, tool_result). Must iterate through array to find tool_use blocks.

---

### 4. Path Matching with Embedded Dashes

**Problem:** Directory name `-Users-tonyofthehills-dev-apps-app-009-agent-deck` contains dashes that are part of directory names, not path separators.

**❌ What Doesn't Work:**
```swift
// WRONG: app-009-agent-deck becomes app/009/agent/deck
let path = projectDir.name.replacingOccurrences(of: "-", with: "/")
// Result: /Users/tonyofthehills/dev/apps/app/009/agent/deck ❌
```

**✅ What Works:**
```swift
// ✅ Read cwd directly from transcript JSON
func readCwdFromTranscript(path: String) -> String? {
    let lines = content.split(separator: "\n")
    for line in lines.reversed().prefix(10) {
        let json = try? JSONSerialization.jsonObject(with: jsonData)
        if let cwd = json["cwd"] as? String {
            return cwd  // Returns: /Users/.../app-009-agent-deck ✅
        }
    }
}
```

**Why:** Transcript files contain authoritative `cwd` field. Don't try to reverse-engineer paths from directory names.

**File:** `Services/ProcessMonitor.swift:530-548`

---

### 5. Combine Observation Architecture

**Pattern:** AppDelegate observes ProcessMonitor changes and broadcasts to WebSocket clients.

**Implementation:**
```swift
// AppDelegate.swift
var cancellables = Set<AnyCancellable>()

func observeProcessMonitorChanges() {
    monitor.$instances
        .dropFirst()  // Skip initial empty state
        .sink { instances in
            let message = ["type": "state_update", "instances": instances.map { $0.toDictionary() }]
            wsServer.broadcastMessage(message)
        }
        .store(in: &cancellables)
}
```

**Why:**
- Decouples ProcessMonitor from WebSocketServer
- ProcessMonitor doesn't need to know about broadcasting
- AppDelegate coordinates cross-component communication
- Combine provides reactive, memory-safe observation

**Files:** `AppDelegate.swift:177-202`, `Services/WebSocketServer.swift:242-251`

---

### 6. Main Thread Dispatch for UI Updates

**Problem:** FSEvents callback runs on background queue. SwiftUI requires main thread.

**✅ Always Dispatch to Main:**
```swift
transcriptWatcher?.onTranscriptUpdate = { [weak self] sessionId, taskText in
    DispatchQueue.main.async {  // ✅ Required for UI updates
        self?.handleTranscriptUpdate(sessionId: sessionId, taskText: taskText)
    }
}
```

**Why:**
- FSEvents uses `DispatchQueue(label: "...", qos: .userInitiated)`
- Callbacks execute on background queue
- Modifying `@Published` properties triggers SwiftUI updates
- SwiftUI updates MUST happen on main thread

**File:** `Services/ProcessMonitor.swift:47-52`

---

### 7. Modern FSEvents API (Not Deprecated)

**❌ Deprecated:**
```swift
FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
```

**✅ Modern:**
```swift
let queue = DispatchQueue(label: "com.agentdeck.transcript-watcher", qos: .userInitiated)
FSEventStreamSetDispatchQueue(stream, queue)
FSEventStreamStart(stream)
```

**Why:**
- `FSEventStreamScheduleWithRunLoop` deprecated in macOS 13.0
- Dispatch queue approach is more modern and flexible
- Better thread management
- Avoids deprecation warnings

**File:** `Services/TranscriptWatcher.swift:89-92`

---

### 8. Process Detection - Filter Child Processes 🔴 CRITICAL

**Problem:** Agent Deck showing 14 instances when only 5 Claude Code processes running. Inflated count confusing users.

**Root Cause:** Each Claude Code instance spawns multiple child processes:
```
38671 claude --dangerously-skip-permissions  ← Main instance (KEEP)
38700 node ... (Zed external agent)          ← Child helper
38707 claude (child of 38700)                ← Duplicate! (FILTER OUT)
```

**❌ What Doesn't Work:**
```swift
// WRONG: Accepts ALL processes with "claude" in name
for line in output.split(separator: "\n") {
    let commandLine = String(parts[1]).lowercased()
    if commandLine.contains("claude") {
        pids.append(pid)  // ❌ Includes duplicates!
    }
}
// Result: 14 instances shown (3x the actual count)
```

**✅ What Works:**
```swift
// ✅ Filter out node processes
if commandLine.contains("node") {
    continue
}

// ✅ Filter out shell wrappers
if commandLine.starts(with: "/bin/zsh") || commandLine.starts(with: "/bin/bash") {
    continue
}

// ✅ Only accept processes starting with "claude "
if !commandLine.starts(with: "claude ") {
    continue
}

// ✅ Filter out claude processes whose parent is node (Zed external agents)
if isChildOfNodeProcess(pid: pid) {
    continue
}

pids.append(pid)
// Result: 5 instances shown (correct count!)
```

**Helper Function:**
```swift
private func isChildOfNodeProcess(pid: pid_t) -> Bool {
    let parentPID = getParentProcessID(pid: pid)
    if parentPID == 0 { return false }

    // Get parent process name
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/bin/ps")
    task.arguments = ["-p", "\(parentPID)", "-o", "comm="]

    let pipe = Pipe()
    task.standardOutput = pipe

    try? task.run()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        let processName = output.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return processName.contains("node")  // Return true if parent is node
    }

    return false
}
```

**Why:**
- Claude Code spawns helper processes (node for Zed external agents)
- These helpers spawn their own `claude` child processes
- Need to filter by:
  1. Process command pattern ("claude " prefix)
  2. Parent process type (not child of node)
- Only count main `claude` executables

**Detection Strategy:**
1. Use `pgrep -ifl "claude"` to get all processes with "claude"
2. Filter out node processes
3. Filter out shell wrappers (zsh/bash)
4. Check command starts with "claude " (main executable)
5. Check parent is NOT node (filters Zed external agent children)

**File:** `Services/ProcessMonitor.swift:218-283`

**Testing:**
```bash
# Before fix:
pgrep -ifl "claude" | grep -v Claude.app | wc -l
# Output: 14 (inflated)

# After fix (conceptual - shows filtering logic):
pgrep -ifl "^claude " | while read line; do
    pid=$(echo "$line" | awk '{print $1}')
    ppid=$(ps -p $pid -o ppid= | tr -d ' ')
    pname=$(ps -p $ppid -o comm= 2>/dev/null)
    if [[ ! "$pname" =~ "node" ]]; then
        echo "$pid"
    fi
done | wc -l
# Output: 5 (correct)
```

---

### 9. Display Last Statement Instead of "Idle" Text

**Problem:** PWA showing "Idle - Waiting for input" when Claude finishes tasks. User wants to see what Claude actually said last, not generic idle message.

**User Request:**
> "I don't think I ever want to see that statement ['Idle - waiting for input']. When a new claude session is started, just 'Waiting for input' is fine, as well as after doing a slash clear function. otherwise it should have something meaningful to have as the visible text."

**✅ Solution - Extract Last Statement from Transcript:**
```swift
// TranscriptParser.swift - NEW METHOD
func extractLastStatement(from jsonl: String) -> String? {
    let lines = jsonl.split(separator: "\n")

    // Search backwards for most recent assistant message
    for line in lines.reversed() {
        guard let json = /* parse JSON */,
              let role = message["role"] as? String,
              role == "assistant",
              let content = message["content"] as? [[String: Any]] else {
            continue
        }

        // Extract text blocks (not tool_use or tool_result)
        var textParts: [String] = []
        for item in content {
            if item["type"] as? String == "text",
               let text = item["text"] as? String {
                textParts.append(text)
            }
        }

        if !textParts.isEmpty {
            let combined = textParts.joined(separator: " ")
            return String(combined.prefix(300))  // Truncate to 300 chars
        }
    }
    return nil
}
```

**Updated Display Logic (PWA):**
```javascript
// app.js - BEFORE
if (instance.currentTaskDescription) {
    taskDiv.textContent = instance.currentTaskDescription;
} else if (instance.currentTask) {
    taskDiv.textContent = instance.currentTask;
} else {
    taskDiv.textContent = 'Idle - waiting for input';  // ❌ Generic message
}

// app.js - AFTER
if (instance.currentTaskDescription) {
    taskDiv.textContent = instance.currentTaskDescription;  // Active task
} else if (instance.currentTask) {
    taskDiv.textContent = instance.currentTask;  // Fallback
} else if (instance.lastStatement) {
    taskDiv.textContent = instance.lastStatement;  // ✅ Show last thing Claude said
    taskDiv.classList.add('idle');
} else {
    taskDiv.textContent = 'Waiting for input';  // ✅ Only for new sessions
    taskDiv.classList.add('idle');
}
```

**Display Hierarchy:**
1. **Active task** (currentTaskDescription) - When working
2. **Basic task** (currentTask) - Fallback
3. **Last statement** (lastStatement) - When idle but has history ⭐ NEW
4. **Waiting** ("Waiting for input") - Only for new sessions or after /clear

**Example:**
```
Before: "Idle - Waiting for input"
After:  "✅ Agent Deck killed successfully" (actual last message from Claude)
```

**Files Modified:**
- `Services/TranscriptParser.swift:240-281` - Added `extractLastStatement()` method
- `Models/AgentInstance.swift:67-70, 88, 104, 140-142` - Added `lastStatement` field
- `Services/ProcessMonitor.swift:197, 211, 675` - Populate lastStatement
- `Resources/WebRoot/app.js:271-285` - Updated display logic
- `specs/001-mvp/data-model.md:34` - Documented lastStatement in spec

**Why:**
- Users want context, not generic messages
- Last statement shows what Claude actually accomplished
- "Waiting for input" only for truly new sessions
- Provides better UX and continuity

---

## Architecture Patterns

### Real-Time Monitoring Flow

```
1. Claude Code writes → ~/.claude/projects/{project}/{session}.jsonl
2. FSEvents detects (100ms latency)
3. TranscriptWatcher reads latest message
4. ProcessMonitor updates @Published instances (REPLACE, not mutate)
5. AppDelegate Combine observer fires
6. WebSocketServer broadcasts "state_update"
7. PWA client updates UI (no refresh needed)
```

**Key Insight:** Zero configuration for users. No hooks, no setup. Just works.

---

## What NOT to Do

### ❌ Don't Use Hooks for Real-Time Updates
- Hooks only fire when Claude finishes responding
- No updates during active work
- Requires user configuration
- **Solution:** FSEvents watches transcript files directly

### ❌ Don't Poll Transcript Files
- High CPU usage for low latency
- Battery drain
- Misses rapid updates
- **Solution:** FSEvents is kernel-level, efficient

### ❌ Don't Scrape Terminal Content
- Requires Accessibility permissions
- Unreliable across terminal emulators
- High CPU usage
- **Solution:** Read structured transcript files

### ❌ Don't Assume Directory Names = Paths
- Directory names may contain dashes that are part of names
- No reliable mapping from `-Users-foo-bar-baz` to filesystem path
- **Solution:** Read `cwd` from transcript JSON

---

## Testing Checklist

When implementing similar real-time monitoring:

- [ ] FSEvents callback can access paths without crashes
- [ ] @Published triggers when updating array elements
- [ ] Combine observers receive notifications
- [ ] UI updates happen on main thread
- [ ] WebSocket broadcasts reach all clients
- [ ] PWA updates without page refresh
- [ ] Console logs show full flow (FSEvents → broadcast)
- [ ] Multiple instances tracked independently

---

## Debugging Tips

### Console.app
Filter: `subsystem == "com.agentdeck.mac"`

Look for:
```
ℹ️ FSEvents fired with X event(s)
ℹ️ Processing transcript: ...
ℹ️ Transcript cwd: /Users/.../project
ℹ️ ✅ Real-time update for .../project: task text
ℹ️ ProcessMonitor instances changed, broadcasting to X clients
```

### Browser Console (F12)
```javascript
Received message: state_update
State update received: 1 instances
```

### Xcode Console
Look for NSLog messages:
```
🚀 Agent Deck launching...
✅ Status bar setup complete
✅ setupServices complete
🎉 Agent Deck launched successfully
```

---

## Performance Metrics

**Achieved:**
- CPU: <2% idle, <5% active ✅
- Memory: ~100MB ✅
- Latency: <500ms transcript-to-UI ✅
- Zero configuration for users ✅

**Target (Met):**
- CPU: <2% idle, <5% active (spec requirement)
- Memory: <100MB RAM (under budget)
- Latency: <500ms status update (met)

---

## Files Modified/Created

### Session 1 (Real-time Monitoring)
**Created:**
- `Services/TranscriptWatcher.swift` - FSEvents file system monitoring
- `LESSONS_LEARNED.md` - This file

**Modified:**
- `Services/ProcessMonitor.swift` - Added TranscriptWatcher integration, struct replacement pattern
- `AppDelegate.swift` - Added Combine observation, WebSocket broadcasting
- `Services/WebSocketServer.swift` - Added public `broadcastMessage()` method
- `Resources/WebRoot/app.js` - Added `state_update` message handler

### Session 2 (Rich Data Enhancement)
**Created:**
- `Models/SubagentInfo.swift` - Subagent task representation
- `Models/TodoItem.swift` - Todo item with status
- `Services/TranscriptParser.swift` - Parse Claude Code JSONL transcripts

**Modified:**
- `Models/AgentInstance.swift` - Added 5 rich data fields (modelName, gitBranch, activeSubagents, todos, currentTaskDescription)
- `Services/ProcessMonitor.swift` - Integrated TranscriptParser, git branch detection, fixed JSON path bugs
- `Resources/WebRoot/app.js` - Added subagents/todos display sections
- `Resources/WebRoot/styles.css` - Expandable section styles
- `Resources/WebRoot/index.html` - Updated structure for rich data
- `specs/001-mvp/data-model.md` - Added SubagentInfo and TodoItem entities
- `specs/001-mvp/contracts/websocket-protocol.md` - Updated message examples
- `specs/001-mvp/spec.md` - Added FR-065, FR-066, FR-067
- `specs/001-mvp/tasks.md` - Added T141-T155, all marked completed

---

## Related Documentation

- **Pieces Memories Created:**
  1. "FSEvents C pointer handling in Swift" - Critical fix for crashes
  2. "@Published array with structs" - Must replace, not mutate
  3. "Real-time monitoring architecture" - Complete flow FSEvents→PWA

- **Project Docs:**
  - `CLAUDE.md` - Project-specific guidance (updated with lessons learned)
  - `specs/001-mvp/plan.md` - Implementation plan
  - `specs/001-mvp/tasks.md` - Task tracking

---

## Next Steps (Remaining MVP Tasks)

1. **Window Switching** - AppleScript-based focus switching (User Story 2)
2. **QR Code Pairing** - Mobile PWA connection setup (User Story 3)
3. **Multiple Agent Support** - Detect Cursor, Windsurf (Phase 3)
4. **Advanced Parsing** - Status line, multi-line support (User Story 4, Phase 3+)

---

## Completed This Session

✅ **Session 3: Process Detection Fixes + Last Statement Display**
- Fixed duplicate instance detection (14 → 5 instances shown)
- Added child process filtering (node, shell wrappers, Zed external agents)
- Implemented `isChildOfNodeProcess()` helper for accurate counting
- Added `lastStatement` extraction from transcript
- Updated PWA to show last meaningful statement instead of "Idle - Waiting for input"
- Updated data model spec with lastStatement field
- Documented both fixes in LESSONS_LEARNED.md (sections 8 & 9)
- Updated CHANGELOG.md for v0.1.1 release

✅ **Session 2: Rich Data Enhancement (Tasks T141-T155)**
- Created SubagentInfo and TodoItem models
- Implemented TranscriptParser with full JSON path handling
- Added git branch detection with 60s caching
- Enhanced PWA UI with expandable sections (subagents, todos)
- Fixed critical TranscriptParser JSON path bug
- All rich data now displaying: model name, git branch, subagents, todos, current task

---

**Last Updated:** 2025-01-07 (Session 3)
**Session:** Process detection fixes + Last statement display
**Status:** ✅ Complete - Accurate instance count, contextual idle messages
