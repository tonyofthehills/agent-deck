# Agent Deck - Hook-Based Monitoring Setup

**Complete passive monitoring without changing your Claude Code workflow**

---

## Overview

Agent Deck monitors Claude Code activity using Claude's built-in hook system. This approach:

- ✅ **Zero workflow change** - Use Claude Code exactly as you always have
- ✅ **Works everywhere** - Terminal, VS Code, Cursor, any environment
- ✅ **Completely passive** - Agent Deck just reads files
- ✅ **No interference** - Your status line stays independent
- ✅ **Simple setup** - One-time 5-minute configuration

---

## How It Works

```
Claude Code runs → Hook fires on activity → Writes to ~/.agent-deck/ → Agent Deck reads files → Updates UI
```

**Hook events used:**
- `Notification` - Fires when Claude sends status updates
- Writes activity data to `~/.agent-deck/activity-{session_id}.json`
- Agent Deck polls these files every 500ms
- Matches sessions to processes by working directory

---

## Setup Instructions

### Step 1: Install the Monitor Hook Script

Copy the monitoring script to your Claude config directory:

```bash
# Copy the monitor script
cp /tmp/agent-deck-monitor.py ~/.claude/agent-deck-monitor.py

# Make it executable
chmod +x ~/.claude/agent-deck-monitor.py
```

**Verify installation:**
```bash
ls -la ~/.claude/agent-deck-monitor.py
# Should show: -rwxr-xr-x ... agent-deck-monitor.py
```

---

### Step 2: Configure Claude Code Hooks

Edit your `~/.claude/settings.json` to add the hook:

#### If you DON'T have hooks configured yet:

```json
{
  "hooks": {
    "Notification": {
      "type": "command",
      "command": "~/.claude/agent-deck-monitor.py"
    }
  }
}
```

#### If you ALREADY have hooks configured:

Add the `Notification` hook to your existing hooks section:

```json
{
  "hooks": {
    "PreToolUse": {
      "type": "command",
      "command": "your-existing-pretooluse-command"
    },
    "Notification": {
      "type": "command",
      "command": "~/.claude/agent-deck-monitor.py"
    }
  }
}
```

**Note:** You can have multiple hooks. Just add `Notification` alongside your existing ones.

---

### Step 3: Restart Claude Code

Kill any running Claude Code instances and restart:

```bash
# Kill all Claude Code processes
pkill -9 claude

# Start Claude Code (in your project directory)
cd your-project
claude
```

---

### Step 4: Launch Agent Deck

```bash
open /tmp/agent-deck-build/Build/Products/Debug/Agent-Deck.app
```

Or use the installed version if you've already installed it to /Applications.

---

## Verification

### Check if hook is working:

1. **Start Claude Code** in any project
2. **Ask Claude to do something** (e.g., "list files in this directory")
3. **Check for activity files:**

```bash
ls -la ~/.agent-deck/
```

You should see files like: `activity-{session-id}.json`

**View the content:**
```bash
cat ~/.agent-deck/activity-*.json
```

Expected output:
```json
{
  "session_id": "abc123...",
  "cwd": "/Users/you/project",
  "model": "Sonnet",
  "last_activity": "2025-11-04T11:45:00",
  "event": "Notification",
  "current_task": "I'll help you list the files..."
}
```

### Check Agent Deck UI:

1. Click the Agent Deck menubar icon
2. You should see detected Claude Code instances
3. Task text should appear in real-time as Claude works
4. Status updates every 500ms

---

## Troubleshooting

### No activity files are created

**Check hook configuration:**
```bash
cat ~/.claude/settings.json | jq '.hooks.Notification'
```

Should show:
```json
{
  "type": "command",
  "command": "/Users/you/.claude/agent-deck-monitor.py"
}
```

**Check script permissions:**
```bash
ls -la ~/.claude/agent-deck-monitor.py
```

Should show `x` (executable) permissions.

**Fix permissions:**
```bash
chmod +x ~/.claude/agent-deck-monitor.py
```

**Check Claude Code is running:**
```bash
ps aux | grep -i claude | grep -v grep
```

---

### Activity files exist but Agent Deck shows "Idle"

**Check working directory matching:**
```bash
# Get Claude Code working directory
lsof -p $(pgrep claude | head -1) -a -d cwd -F n

# Compare with activity file cwd:
cat ~/.agent-deck/activity-*.json | jq '.cwd'
```

If they don't match, the matching logic needs adjustment (file a bug report).

**Check activity file content:**
```bash
cat ~/.agent-deck/activity-*.json | jq '.'
```

If `current_task` is null or missing, transcript parsing may have failed (this is normal if Claude hasn't sent messages yet).

---

### Agent Deck doesn't show any instances

**Check process detection:**
```bash
ps aux | grep -i claude | grep -v grep
```

If you see Claude Code processes but Agent Deck doesn't, check Agent Deck logs:

```bash
log show --predicate 'subsystem == "com.agentdeck.app"' --last 1m | grep -i "detected"
```

---

### Hook script errors

**Add debug logging:**

Edit `~/.claude/agent-deck-monitor.py` and uncomment the error logging line:

```python
except Exception as e:
    # Silently fail - don't break Claude Code if something goes wrong
    sys.stderr.write(f"Agent Deck monitor error: {e}\n")  # UNCOMMENT THIS
    pass
```

Then check Claude Code output for error messages.

---

## Advanced Configuration

### Multiple Hook Events

You can monitor multiple events for better activity tracking:

```json
{
  "hooks": {
    "Notification": {
      "type": "command",
      "command": "~/.claude/agent-deck-monitor.py"
    },
    "Stop": {
      "type": "command",
      "command": "~/.claude/agent-deck-monitor.py"
    },
    "PostToolUse": {
      "type": "command",
      "command": "~/.claude/agent-deck-monitor.py"
    }
  }
}
```

This gives more frequent updates but may create more file I/O.

---

### Custom Activity Tracking

Edit `~/.claude/agent-deck-monitor.py` to add custom fields:

```python
activity_data = {
    'session_id': session_id,
    'cwd': cwd,
    'model': model_name,
    'last_activity': datetime.now().isoformat(),
    'event': event_name,
    'timestamp': data.get('timestamp', ''),
    'custom_field': 'your-custom-data'  # Add custom tracking
}
```

---

## Compatibility

### Works with:
- ✅ Terminal.app
- ✅ iTerm2
- ✅ Ghostty
- ✅ Alacritty
- ✅ VS Code integrated terminal
- ✅ Cursor integrated terminal
- ✅ Any terminal emulator
- ✅ SSH sessions
- ✅ Tmux/Screen

### Limitations:
- ❌ **Cursor's built-in AI agent** - Different architecture, not Claude Code
- ❌ **VS Code extensions** (except Claude Code CLI) - Separate tools
- ⚠️ **Requires Claude Code CLI** - This monitors `claude` command line tool only

---

## Uninstallation

To remove Agent Deck monitoring:

1. **Remove hook from settings.json:**
```bash
# Edit ~/.claude/settings.json and remove the Notification hook
```

2. **Delete monitor script:**
```bash
rm ~/.claude/agent-deck-monitor.py
```

3. **Clean up activity files:**
```bash
rm ~/.agent-deck/activity-*.json
```

Your Claude Code workflow returns to normal immediately.

---

## Support

**Issues?** File a bug report at: https://github.com/yourusername/agent-deck/issues

**Questions?** Check the main README or open a discussion.

---

## Technical Details

**File Format:** JSON
**Update Frequency:** Every ~300ms (Claude Code hook firing rate)
**Polling Frequency:** Every 500ms (Agent Deck polling rate)
**Storage:** `~/.agent-deck/activity-{session_id}.json`
**Process Matching:** By working directory (cwd)
**Task Extraction:** From Claude's conversation transcript

**Privacy:** All data stays local on your machine. No cloud services involved.

---

**Ready to monitor!** After setup, Agent Deck will automatically track all your Claude Code sessions. 🚀
