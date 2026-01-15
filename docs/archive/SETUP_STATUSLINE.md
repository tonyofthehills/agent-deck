# Agent Deck - Claude Code Status Line Integration

## Overview

Agent Deck can display **what Claude Code is currently working on** by integrating with Claude Code's status line feature. This provides real-time task updates without requiring Accessibility permissions.

## How It Works

1. **Claude Code** calls a status line script whenever the conversation updates (every ~300ms)
2. The script **reads Claude's conversation transcript** to extract the current task
3. Task data is **written to a cache file** at `~/.agent-deck/task-{session_id}.json`
4. **Agent Deck** reads these cache files every 500ms to display current tasks

## Setup Instructions

### Step 1: Install the Status Line Script

Copy the Agent Deck status line script to your Claude config directory:

```bash
# Create the script
cp /tmp/agent-deck-statusline.py ~/.claude/agent-deck-statusline.py
chmod +x ~/.claude/agent-deck-statusline.py
```

**Or manually create** `~/.claude/agent-deck-statusline.py` with the script content from `/tmp/agent-deck-statusline.py`

### Step 2: Configure Claude Code

Add the following to your `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/agent-deck-statusline.py",
    "padding": 0
  }
}
```

**If you already have a status line configured:**
You can run both! Create a wrapper script:

```bash
#!/bin/bash
# ~/.claude/combined-statusline.sh

# Run your existing statusline
YOUR_EXISTING_STATUSLINE

# Also run Agent Deck's statusline (silently)
~/.claude/agent-deck-statusline.py
```

Then update settings.json:
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

Restart any running Claude Code instances for the changes to take effect:

```bash
# Find and kill Claude Code processes
pkill -9 claude

# Restart Claude Code in your terminal
claude
```

### Step 4: Launch Agent Deck

Agent Deck will automatically detect the cache files and display current tasks!

## Verification

Check that the integration is working:

```bash
# 1. Start a Claude Code session
claude

# 2. Ask Claude to do something
# "Can you explain this project?"

# 3. Check the cache file was created
ls -la ~/.agent-deck/

# You should see: task-{some-session-id}.json

# 4. View the content
cat ~/.agent-deck/task-*.json
```

You should see JSON like:
```json
{
  "task": "I'll analyze this project structure for you...",
  "model": "Sonnet",
  "cwd": "/path/to/your/project",
  "timestamp": "..."
}
```

## Troubleshooting

### No cache files created

**Check if the script is being called:**
```bash
# Add debug output to the script
echo "Script called at $(date)" >> /tmp/statusline-debug.log

# Check if Claude Code is calling it
tail -f /tmp/statusline-debug.log
```

**Verify your settings.json:**
```bash
cat ~/.claude/settings.json | grep -A 5 statusLine
```

### Cache files exist but Agent Deck shows "Idle"

The script extracts the **first line** of Claude's latest message. If Claude's response starts with markdown or formatting, it might not contain meaningful text.

**Manually check the transcript:**
```bash
# The script reads from Claude's transcript files
# Check recent Claude Code transcripts:
ls -ltr ~/.claude/transcripts/ | tail -5
```

### Permissions errors

Make sure the script is executable:
```bash
chmod +x ~/.claude/agent-deck-statusline.py
```

## Advanced: Custom Task Extraction

You can modify the script to extract different information. Edit `~/.claude/agent-deck-statusline.py`:

```python
# Current: Extracts first line of assistant's message
last_task = lines[0][:200]

# Alternative: Extract tool usage
if item.get('type') == 'tool_use':
    tool_name = item.get('name', '')
    last_task = f"Using tool: {tool_name}"

# Alternative: Look for specific patterns
import re
if re.search(r"Currently:.*", text):
    match = re.search(r"Currently: (.*)", text)
    last_task = match.group(1)
```

## How Agent Deck Uses This Data

Agent Deck's ProcessMonitor:
1. **Detects Claude Code instances** by PID
2. **Maps each PID** to a working directory
3. **Matches cache files** by comparing working directories
4. **Updates the UI** with task information every 500ms

The task text appears prominently in both:
- **macOS Menubar** dropdown
- **Mobile PWA** interface

## Benefits Over Other Approaches

✅ **No Accessibility permissions required**
✅ **Works with all terminal emulators** (Ghostty, Terminal, iTerm2, VS Code)
✅ **Reliable** - reads from Claude's actual transcript
✅ **Efficient** - small JSON files, no process scanning
✅ **Real-time** - updates every 300ms from Claude

## Next Steps

Once set up, Agent Deck will automatically display what each Claude Code instance is currently working on. No further configuration needed!

If you have multiple Claude Code sessions running, each will have its own cache file and will be tracked independently.
