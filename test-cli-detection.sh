#!/bin/bash
# Test script to verify proc_listpids can detect Claude Code instances

echo "=== Testing CLI Process Detection ==="
echo ""

# Check if proc_pidpath can read the claude PIDs
for pid in 35039 38671 9030; do
    if ps -p $pid > /dev/null 2>&1; then
        echo "PID $pid is running"
        # Get executable path
        path=$(lsof -p $pid -Fn 2>/dev/null | grep "^n" | head -1 | cut -c2-)
        echo "  Executable: $path"
    else
        echo "PID $pid not found"
    fi
    echo ""
done

echo "=== Expected Detection ==="
echo "Agent Deck should detect all three PIDs above"
echo ""
echo "If menubar shows 0 instances, there may be a sandbox issue."
echo "Check Console.app for 'Agent-Deck' logs to see detection errors."
