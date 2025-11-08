# Status Line Integration - Implementation Complete ✅

**Date:** November 4, 2025
**Status:** Ready for testing

---

## Summary

Agent Deck has been successfully updated to display **real-time task information** from Claude Code using the status line integration approach. The task text is now prominently displayed in both the menubar and PWA interfaces.

## What Was Implemented

### 1. Status Line Script (`/tmp/agent-deck-statusline.py`)

**Purpose:** Extracts current task from Claude Code's conversation transcript

**How it works:**
- Receives Claude Code session data via stdin
- Reads the transcript JSON file
- Extracts the first line of Claude's latest message as the current task
- Writes task data to `~/.agent-deck/task-{session_id}.json`

**Output format:**
```json
{
  "task": "Implementing cache file monitoring in ProcessMonitor",
  "model": "Sonnet",
  "cwd": "/Users/you/project",
  "timestamp": "2025-11-04T06:50:00Z"
}
```

### 2. ProcessMonitor Updates (`ProcessMonitor.swift:295-329`)

**New method: `readTaskFromCacheFiles()`**
- Reads all cache files from `~/.agent-deck/`
- Matches files to instances by comparing working directories
- Returns task text for matching instance
- Updates every 500ms (existing polling interval)

**Changes:**
- Replaced `extractTaskFromTerminal()` with `readTaskFromCacheFiles()`
- Deprecated the Accessibility API approach
- Task text now comes directly from Claude Code's transcript

### 3. UI Updates (Already Complete)

**Menubar (MenuBarView.swift:183-198):**
- Task text is the primary visual element (`.subheadline`, `.semibold`)
- Status dot is smaller and less prominent
- Shows "Idle - waiting for input" when no task detected

**PWA (app.js:252-259):**
- Task text displayed prominently with large font
- Idle state shows italicized placeholder text
- Real-time updates via WebSocket

---

## What You Need to Do Next

### Step 1: Install the Status Line Script

Copy the script to your Claude config directory:

```bash
# Create script
cp /tmp/agent-deck-statusline.py ~/.claude/agent-deck-statusline.py
chmod +x ~/.claude/agent-deck-statusline.py
```

### Step 2: Configure Claude Code

Add to your `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/agent-deck-statusline.py",
    "padding": 0
  }
}
```

**If you already have a status line configured**, create a wrapper script:

```bash
#!/bin/bash
# ~/.claude/combined-statusline.sh

# Run your existing statusline
YOUR_EXISTING_STATUSLINE_COMMAND

# Also run Agent Deck's statusline (silently)
~/.claude/agent-deck-statusline.py
```

Then update settings.json to use the wrapper:
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/combined-statusline.sh",
    "padding": 0
  }
}
```

### Step 3: Restart Claude Code

Kill and restart any running Claude Code instances:

```bash
pkill -9 claude
claude  # Start new instance
```

### Step 4: Verify It Works

**Check cache files are being created:**
```bash
# Do something in Claude Code (ask it a question)
# Then check:
ls -la ~/.agent-deck/

# You should see: task-{some-session-id}.json

# View the content:
cat ~/.agent-deck/task-*.json
```

**Expected output:**
```json
{
  "task": "I'll help you implement that feature...",
  "model": "Sonnet",
  "cwd": "/path/to/your/project",
  "timestamp": "2025-11-04T..."
}
```

### Step 5: Launch Agent Deck

```bash
open /tmp/agent-deck-build/Build/Products/Debug/Agent-Deck.app
```

**What you should see:**
- Menubar icon appears
- Click it to open dropdown
- Claude Code instances show with prominent task text
- Task text updates in real-time as Claude works

---

## How It Works End-to-End

```
1. Claude Code executes → Calls status line script (every ~300ms)
                          ↓
2. Status line script  → Reads transcript JSON
                          ↓
3. Extracts task text  → Writes to ~/.agent-deck/task-{session}.json
                          ↓
4. ProcessMonitor      → Polls every 500ms
                          ↓
5. Reads cache files   → Matches by working directory
                          ↓
6. Updates UI          → Menubar + PWA show task text
```

---

## Architecture Benefits

✅ **No Accessibility Permissions** - Doesn't require macOS Accessibility access
✅ **Direct from Source** - Reads Claude's actual conversation transcript
✅ **Terminal Agnostic** - Works with Ghostty, Terminal, iTerm2, VS Code, etc.
✅ **Real-time** - Status line executes every ~300ms, we poll every 500ms
✅ **Reliable** - No screen scraping or OCR needed
✅ **Efficient** - Small JSON files, minimal I/O overhead

---

## Troubleshooting

### No cache files are being created

**Check if status line is configured:**
```bash
cat ~/.claude/settings.json | grep -A 3 statusLine
```

**Check if script is executable:**
```bash
ls -la ~/.claude/agent-deck-statusline.py
chmod +x ~/.claude/agent-deck-statusline.py
```

**Add debug logging to script:**
```python
# Add this near the top of agent-deck-statusline.py
import sys
sys.stderr.write(f"DEBUG: Script called at {datetime.now()}\n")
```

Then check Claude's stderr output.

### Cache files exist but Agent Deck shows "Idle"

**Check working directory matching:**
```bash
# Get Claude Code working directory
lsof -p $(pgrep claude) -a -d cwd -F n

# Compare with cache file cwd:
cat ~/.agent-deck/task-*.json | grep cwd
```

If they don't match, the matching logic needs adjustment.

**Check cache file content:**
```bash
cat ~/.agent-deck/task-*.json
```

If `task` is null or empty, Claude hasn't sent any messages yet, or the transcript parsing failed.

### Tasks show but are outdated

Status line is working but files aren't being updated. Possible causes:
- Claude Code status line feature disabled
- Status line script crashed (check for syntax errors)
- Filesystem permissions (check ~/.agent-deck/ is writable)

---

## Files Modified

### New Files
- `/tmp/agent-deck-statusline.py` - Status line integration script
- `/Users/tonyofthehills/dev/apps/app-009-agent-deck/SETUP_STATUSLINE.md` - User setup guide

### Modified Files
- `Agent-Deck/Services/ProcessMonitor.swift:103-108` - Replaced task extraction call
- `Agent-Deck/Services/ProcessMonitor.swift:291-329` - Added `readTaskFromCacheFiles()` method

### Previously Modified (from earlier UI work)
- `Agent-Deck/Views/MenuBarView.swift:183-198` - Prominent task display
- `Agent-Deck/Resources/WebRoot/app.js:252-259` - PWA task rendering
- `Agent-Deck/Resources/WebRoot/styles.css:273-289` - Task styling

---

## Next Steps (Future Enhancements)

1. **Better Session Matching**: Currently matches by working directory. Could also match by:
   - Session ID correlation
   - Process parent-child relationships
   - Terminal window title parsing

2. **Task History**: Store recent tasks for each instance
   - Show last 5 tasks in dropdown
   - Track task completion times
   - Identify patterns (e.g., "Claude keeps failing at X")

3. **Status Detection**: Parse task text to infer status:
   - "Implementing..." → working
   - "Testing..." → working
   - "Fixed..." → done
   - "Error..." → error

4. **Multiple Agent Support**: Extend to Cursor, Windsurf, etc.
   - Cursor has similar CLI tools
   - Could implement similar status line approach
   - Phase 3+ feature

---

## Testing Checklist

- [ ] Install status line script to ~/.claude/
- [ ] Update ~/.claude/settings.json
- [ ] Restart Claude Code
- [ ] Verify cache files created in ~/.agent-deck/
- [ ] Launch Agent Deck
- [ ] Open menubar dropdown
- [ ] Verify task text appears
- [ ] Ask Claude to do something
- [ ] Verify task text updates in real-time
- [ ] Test on PWA (open http://localhost:3000 on phone)
- [ ] Verify task text shows on mobile

---

## Build Status

✅ **Build Successful** (November 4, 2025 6:50 AM)

```
** BUILD SUCCEEDED **
```

App Location: `/tmp/agent-deck-build/Build/Products/Debug/Agent-Deck.app`

---

## Documentation References

- **Setup Guide**: `SETUP_STATUSLINE.md` - Complete user-facing setup instructions
- **Status Line Script**: `/tmp/agent-deck-statusline.py` - Python implementation
- **ProcessMonitor Code**: `Agent-Deck/Services/ProcessMonitor.swift:291-329`

---

**Ready to test!** Follow the steps above to set up the status line integration and see real-time task updates in Agent Deck.
