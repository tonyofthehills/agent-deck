#!/bin/bash

# test-first-run.sh
# Test script for first-run experience verification
# Usage: ./test-first-run.sh [test-name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}Agent Deck First-Run Test Suite${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Function to check if Agent Deck is running
check_app_running() {
    if pgrep -x "Agent-Deck" > /dev/null; then
        echo -e "${GREEN}✓ Agent Deck is running${NC}"
        return 0
    else
        echo -e "${RED}✗ Agent Deck is not running${NC}"
        return 1
    fi
}

# Function to check if config exists
check_config_exists() {
    if [ -f "$HOME/.agent-deck/config.yaml" ]; then
        echo -e "${GREEN}✓ Config file exists${NC}"
        cat "$HOME/.agent-deck/config.yaml"
        return 0
    else
        echo -e "${RED}✗ Config file does not exist${NC}"
        return 1
    fi
}

# Function to check UserDefaults
check_user_defaults() {
    local value=$(defaults read com.agentdeck.mac hasLaunchedBefore 2>/dev/null || echo "NOT_SET")
    if [ "$value" = "1" ]; then
        echo -e "${GREEN}✓ hasLaunchedBefore = true${NC}"
        return 0
    elif [ "$value" = "NOT_SET" ]; then
        echo -e "${YELLOW}⚠ hasLaunchedBefore not set (first launch)${NC}"
        return 1
    else
        echo -e "${RED}✗ hasLaunchedBefore = $value${NC}"
        return 1
    fi
}

# Function to check network listeners
check_network() {
    echo -e "${YELLOW}Checking network listeners...${NC}"

    if lsof -iTCP:3000 -sTCP:LISTEN > /dev/null 2>&1; then
        echo -e "${GREEN}✓ HTTP server listening on port 3000${NC}"
        lsof -iTCP:3000 -sTCP:LISTEN | grep -v COMMAND
    else
        echo -e "${RED}✗ No listener on port 3000${NC}"
    fi

    if lsof -iTCP:3001 -sTCP:LISTEN > /dev/null 2>&1; then
        echo -e "${GREEN}✓ WebSocket server listening on port 3001${NC}"
        lsof -iTCP:3001 -sTCP:LISTEN | grep -v COMMAND
    else
        echo -e "${RED}✗ No listener on port 3001${NC}"
    fi
}

# Function to simulate first launch
simulate_first_launch() {
    echo -e "${YELLOW}Simulating first launch (cleaning state)...${NC}"

    # Kill app if running
    if pgrep -x "Agent-Deck" > /dev/null; then
        echo "  Quitting Agent Deck..."
        osascript -e 'quit app "Agent-Deck"' 2>/dev/null || true
        sleep 2
    fi

    # Delete UserDefaults
    echo "  Deleting UserDefaults..."
    defaults delete com.agentdeck.mac hasLaunchedBefore 2>/dev/null || true

    # Delete config directory
    echo "  Deleting ~/.agent-deck/..."
    rm -rf "$HOME/.agent-deck/"

    echo -e "${GREEN}✓ State cleaned (ready for first launch)${NC}"
    echo ""
    echo -e "${BLUE}Now launch Agent Deck manually and observe:${NC}"
    echo "  1. Welcome dialog should appear"
    echo "  2. Accessibility permission dialog should appear"
    echo "  3. Config file should be created at ~/.agent-deck/config.yaml"
    echo ""
}

# Function to simulate config deletion
simulate_config_deletion() {
    echo -e "${YELLOW}Simulating config deletion (keeping UserDefaults)...${NC}"

    # Kill app if running
    if pgrep -x "Agent-Deck" > /dev/null; then
        echo "  Quitting Agent Deck..."
        osascript -e 'quit app "Agent-Deck"' 2>/dev/null || true
        sleep 2
    fi

    # Delete only config file
    echo "  Deleting ~/.agent-deck/config.yaml..."
    rm -f "$HOME/.agent-deck/config.yaml"

    echo -e "${GREEN}✓ Config deleted (UserDefaults preserved)${NC}"
    echo ""
    echo -e "${BLUE}Now launch Agent Deck manually and observe:${NC}"
    echo "  1. No welcome dialog (not first launch)"
    echo "  2. Config file should be recreated automatically"
    echo ""
}

# Function to check logs
check_logs() {
    echo -e "${YELLOW}Checking recent logs...${NC}"
    echo ""

    log show --predicate 'subsystem == "com.agentdeck.mac"' --last 5m --style compact | tail -50
}

# Function to monitor shutdown
monitor_shutdown() {
    echo -e "${YELLOW}Monitoring shutdown process...${NC}"
    echo "Quit Agent Deck now (Cmd+Q)..."
    echo ""

    # Wait for app to quit
    while pgrep -x "Agent-Deck" > /dev/null; do
        sleep 0.5
    done

    echo -e "${GREEN}✓ App quit${NC}"
    echo ""

    # Check for orphan processes
    if pgrep -f "agent-deck" > /dev/null; then
        echo -e "${RED}✗ Orphan processes detected:${NC}"
        ps aux | grep -i agent-deck | grep -v grep
    else
        echo -e "${GREEN}✓ No orphan processes${NC}"
    fi

    # Check network listeners
    if lsof -iTCP:3000 -sTCP:LISTEN > /dev/null 2>&1 || lsof -iTCP:3001 -sTCP:LISTEN > /dev/null 2>&1; then
        echo -e "${RED}✗ Network listeners still active${NC}"
        lsof -iTCP:3000,3001 -sTCP:LISTEN
    else
        echo -e "${GREEN}✓ No network listeners (clean shutdown)${NC}"
    fi

    echo ""
    echo -e "${BLUE}Checking shutdown logs:${NC}"
    log show --predicate 'subsystem == "com.agentdeck.mac"' --last 1m --style compact | grep -E "(terminating|stopping|stopped|shutdown)"
}

# Function to run status check
status_check() {
    echo -e "${BLUE}Current Status:${NC}"
    echo ""

    echo "1. App Running:"
    check_app_running || true
    echo ""

    echo "2. Config File:"
    check_config_exists || true
    echo ""

    echo "3. UserDefaults:"
    check_user_defaults || true
    echo ""

    echo "4. Network:"
    check_network || true
    echo ""
}

# Main menu
show_menu() {
    echo ""
    echo "Available tests:"
    echo "  1. status          - Check current state"
    echo "  2. first-launch    - Simulate first launch (clean state)"
    echo "  3. config-recreate - Test config auto-creation"
    echo "  4. logs            - View recent logs"
    echo "  5. shutdown        - Monitor shutdown process"
    echo ""
    echo "Usage: $0 [test-name]"
    echo "Example: $0 first-launch"
}

# Parse command
case "${1:-}" in
    status)
        status_check
        ;;
    first-launch)
        simulate_first_launch
        ;;
    config-recreate)
        simulate_config_deletion
        ;;
    logs)
        check_logs
        ;;
    shutdown)
        monitor_shutdown
        ;;
    *)
        show_menu
        ;;
esac
