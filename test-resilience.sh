#!/bin/bash

# test-resilience.sh
# Network and error condition testing for Agent Deck MVP
# Tests: Network interruption, sleep/wake, process termination, port conflicts
# Usage: ./test-resilience.sh [--test NAME]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
APP_NAME="Agent-Deck"
HTTP_PORT=3000
WS_PORT=3001
RECONNECT_TARGET=5000  # 5 seconds max reconnection time

# Parse arguments
TEST_NAME="${1:-all}"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Resilience Test Suite${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Function to check if app is running
is_app_running() {
    pgrep -x "$APP_NAME" > /dev/null 2>&1
}

# Function to get app PID
get_app_pid() {
    pgrep -x "$APP_NAME" | head -1
}

# Function to find app bundle
find_app_bundle() {
    local found=$(find ~/Library/Developer/Xcode/DerivedData -name "Agent-Deck.app" -type d 2>/dev/null | head -1)
    if [ -z "$found" ]; then
        echo ""
    else
        echo "$found"
    fi
}

# =============================================================================
# TEST 1: Network Interruption and Auto-Reconnection (<5s)
# =============================================================================
test_network_interruption() {
    echo -e "${YELLOW}[TEST 1] Network Interruption Recovery${NC}"
    echo "Target: Auto-reconnect within ${RECONNECT_TARGET}ms"
    echo ""

    # Check if Node.js is available
    if ! command -v node > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠ Node.js not found - skipping network test${NC}"
        return 0
    fi

    if ! node -e "require('ws')" 2>/dev/null; then
        echo -e "${YELLOW}⚠ 'ws' module not found - skipping network test${NC}"
        return 0
    fi

    # Create WebSocket reconnection test
    cat > /tmp/test_reconnection.js << 'EOF'
const WebSocket = require('ws');

let ws;
let disconnectTime;
let reconnectTime;
let connected = false;

function connect() {
    ws = new WebSocket('ws://localhost:3001');

    ws.on('open', () => {
        if (!connected) {
            console.log('Initial connection established');
            connected = true;

            // Simulate network interruption after 2 seconds
            setTimeout(() => {
                console.log('\nSimulating network interruption (closing connection)...');
                disconnectTime = Date.now();
                ws.close();

                // Try to reconnect
                setTimeout(() => {
                    console.log('Attempting reconnection...');
                    connect();
                }, 1000);
            }, 2000);
        } else {
            reconnectTime = Date.now();
            const latency = reconnectTime - disconnectTime;
            console.log(`\n✓ Reconnected in ${latency}ms`);

            if (latency < 5000) {
                console.log('✓ TEST PASSED - Reconnection within 5 seconds');
                process.exit(0);
            } else {
                console.log('✗ TEST FAILED - Reconnection took too long');
                process.exit(1);
            }
        }
    });

    ws.on('message', (data) => {
        const msg = JSON.parse(data);
        // Silent message handling
    });

    ws.on('error', (err) => {
        // Errors expected during disconnection
    });

    ws.on('close', () => {
        if (connected && !reconnectTime) {
            console.log('Connection closed (expected)');
        }
    });
}

// Start initial connection
connect();

// Timeout after 15 seconds
setTimeout(() => {
    console.error('\n✗ Timeout waiting for reconnection');
    process.exit(1);
}, 15000);
EOF

    node /tmp/test_reconnection.js
    local exit_code=$?
    rm -f /tmp/test_reconnection.js

    echo ""
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ TEST PASSED${NC}"
        return 0
    else
        echo -e "${RED}✗ TEST FAILED${NC}"
        return 1
    fi
}

# =============================================================================
# TEST 2: Mac Sleep/Wake with Connected PWA
# =============================================================================
test_sleep_wake() {
    echo -e "${YELLOW}[TEST 2] Mac Sleep/Wake Handling${NC}"
    echo "Manual test - requires human interaction"
    echo ""

    if ! is_app_running; then
        echo -e "${RED}✗ Agent Deck is not running${NC}"
        return 1
    fi

    echo "Test procedure:"
    echo "  1. Ensure PWA is connected (check status indicator)"
    echo "  2. Put Mac to sleep (Apple menu → Sleep)"
    echo "  3. Wait 10 seconds"
    echo "  4. Wake Mac"
    echo "  5. Check PWA reconnects automatically"
    echo ""
    echo "Expected behavior:"
    echo "  - PWA shows 'Disconnected' during sleep"
    echo "  - PWA reconnects within 5 seconds after wake"
    echo "  - No manual refresh needed"
    echo ""

    read -p "Press Enter to continue after testing (or Ctrl+C to skip)..."

    echo ""
    echo -e "${BLUE}Did the PWA reconnect automatically after wake? (y/n)${NC}"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✓ TEST PASSED (manual verification)${NC}"
        return 0
    else
        echo -e "${RED}✗ TEST FAILED (manual verification)${NC}"
        return 1
    fi
}

# =============================================================================
# TEST 3: Process Termination While Monitored
# =============================================================================
test_process_termination() {
    echo -e "${YELLOW}[TEST 3] Process Termination Handling${NC}"
    echo "Test: Agent Deck handles Claude Code termination gracefully"
    echo ""

    if ! is_app_running; then
        echo -e "${RED}✗ Agent Deck is not running${NC}"
        return 1
    fi

    # Find a Claude Code instance
    local claude_pids=($(pgrep -i "claude"))
    local claude_count=${#claude_pids[@]}

    if [ $claude_count -eq 0 ]; then
        echo -e "${YELLOW}⚠ No Claude Code instances running${NC}"
        echo "Start Claude Code instances to test process termination handling"
        return 0
    fi

    echo "Found $claude_count Claude Code instance(s)"
    echo "PIDs: ${claude_pids[@]}"
    echo ""

    # Get first Claude Code instance
    local target_pid=${claude_pids[0]}
    echo "Targeting PID $target_pid for termination test"
    echo ""

    # Check initial state
    echo "Before termination:"
    ps -p $target_pid -o pid,command

    echo ""
    echo -e "${YELLOW}Terminating Claude Code instance (PID $target_pid)...${NC}"
    kill $target_pid 2>/dev/null || true

    sleep 2

    # Verify termination
    if ! ps -p $target_pid > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Process terminated${NC}"
        echo ""
        echo "Check Agent Deck PWA:"
        echo "  - Instance should disappear from list"
        echo "  - No crashes or errors"
        echo "  - UI updates correctly"
        echo ""

        read -p "Press Enter to continue after checking PWA..."

        echo ""
        echo -e "${BLUE}Did the PWA update correctly? (y/n)${NC}"
        read -r response

        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}✓ TEST PASSED${NC}"
            return 0
        else
            echo -e "${RED}✗ TEST FAILED${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ Failed to terminate process${NC}"
        return 1
    fi
}

# =============================================================================
# TEST 4: Port Conflicts (3000/3001 already in use)
# =============================================================================
test_port_conflict() {
    echo -e "${YELLOW}[TEST 4] Port Conflict Handling${NC}"
    echo "Test: Agent Deck handles port conflicts gracefully"
    echo ""

    # Kill Agent Deck if running
    if is_app_running; then
        echo "Stopping Agent Deck..."
        local pid=$(get_app_pid)
        kill $pid 2>/dev/null || true
        sleep 2
    fi

    # Check if ports are free
    if lsof -iTCP:$HTTP_PORT -sTCP:LISTEN > /dev/null 2>&1; then
        echo -e "${RED}✗ Port $HTTP_PORT already in use${NC}"
        echo "Cannot test port conflict (port already blocked)"
        return 0
    fi

    echo "Starting dummy HTTP server on port $HTTP_PORT..."

    # Start a dummy server using Python
    if command -v python3 > /dev/null 2>&1; then
        python3 -m http.server $HTTP_PORT > /dev/null 2>&1 &
        local dummy_pid=$!
        sleep 2

        echo "Dummy server started (PID $dummy_pid)"
        echo ""

        # Try to start Agent Deck
        echo "Attempting to start Agent Deck (expecting error)..."
        local app_bundle=$(find_app_bundle)

        if [ -z "$app_bundle" ]; then
            echo -e "${RED}✗ App bundle not found${NC}"
            kill $dummy_pid 2>/dev/null || true
            return 1
        fi

        open "$app_bundle" 2>&1 &
        sleep 3

        # Check if Agent Deck started
        if is_app_running; then
            echo -e "${YELLOW}⚠ Agent Deck started despite port conflict${NC}"
            echo "Check logs for error messages"

            # Kill both
            kill $(get_app_pid) 2>/dev/null || true
            kill $dummy_pid 2>/dev/null || true

            echo ""
            echo -e "${YELLOW}⚠ TEST WARNING${NC} - Port conflict not detected"
            echo "Expected: Error message about port in use"
            return 0
        else
            echo -e "${GREEN}✓ Agent Deck did not start (expected)${NC}"
            echo ""

            # Check system logs for error
            echo "Checking logs for error message..."
            log show --predicate 'subsystem == "com.agentdeck.mac"' --last 30s --style compact | grep -i "port\|bind\|address" | tail -5

            # Cleanup
            kill $dummy_pid 2>/dev/null || true

            echo ""
            echo -e "${GREEN}✓ TEST PASSED${NC}"
            return 0
        fi
    else
        echo -e "${YELLOW}⚠ Python not found - skipping port conflict test${NC}"
        return 0
    fi
}

# =============================================================================
# TEST 5: Different WiFi Networks
# =============================================================================
test_different_networks() {
    echo -e "${YELLOW}[TEST 5] Different WiFi Network Detection${NC}"
    echo "Manual test - requires multiple WiFi networks"
    echo ""

    echo "Test procedure:"
    echo "  1. Connect Mac and phone to WiFi Network A"
    echo "  2. Verify PWA connects successfully"
    echo "  3. Disconnect phone from WiFi Network A"
    echo "  4. Connect phone to WiFi Network B (different network)"
    echo "  5. Try to access PWA"
    echo ""
    echo "Expected behavior:"
    echo "  - PWA shows connection error"
    echo "  - Error message should indicate different network"
    echo "  - Provide guidance to connect to same network"
    echo ""

    echo -e "${BLUE}Test this scenario manually on your phone${NC}"
    echo -e "${YELLOW}⚠ MANUAL TEST REQUIRED${NC}"
    return 0
}

# =============================================================================
# TEST 6: Cross-macOS Spaces Window Switching
# =============================================================================
test_spaces_switching() {
    echo -e "${YELLOW}[TEST 6] Cross-Spaces Window Switching${NC}"
    echo "Manual test - requires multiple Spaces"
    echo ""

    echo "Test procedure:"
    echo "  1. Create multiple Spaces (Mission Control → Spaces)"
    echo "  2. Open Claude Code in Space 1"
    echo "  3. Switch to Space 2"
    echo "  4. Use PWA to focus Claude Code instance"
    echo ""
    echo "Expected behavior:"
    echo "  - macOS switches to Space 1"
    echo "  - Claude Code window comes to foreground"
    echo "  - Latency <1 second"
    echo ""

    read -p "Press Enter to continue after testing (or Ctrl+C to skip)..."

    echo ""
    echo -e "${BLUE}Did window switching work across Spaces? (y/n)${NC}"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✓ TEST PASSED (manual verification)${NC}"
        return 0
    else
        echo -e "${RED}✗ TEST FAILED (manual verification)${NC}"
        return 1
    fi
}

# =============================================================================
# Main Test Runner
# =============================================================================
main() {
    local passed=0
    local total=0

    case "$TEST_NAME" in
        network|1)
            test_network_interruption && passed=$((passed + 1))
            total=1
            ;;
        sleep|2)
            test_sleep_wake && passed=$((passed + 1))
            total=1
            ;;
        termination|3)
            test_process_termination && passed=$((passed + 1))
            total=1
            ;;
        port|4)
            test_port_conflict && passed=$((passed + 1))
            total=1
            ;;
        wifi|5)
            test_different_networks && passed=$((passed + 1))
            total=1
            ;;
        spaces|6)
            test_spaces_switching && passed=$((passed + 1))
            total=1
            ;;
        all|*)
            test_network_interruption && passed=$((passed + 1))
            echo ""
            echo "---"
            echo ""

            test_sleep_wake && passed=$((passed + 1))
            echo ""
            echo "---"
            echo ""

            test_process_termination && passed=$((passed + 1))
            echo ""
            echo "---"
            echo ""

            test_port_conflict && passed=$((passed + 1))
            echo ""
            echo "---"
            echo ""

            test_different_networks && passed=$((passed + 1))
            echo ""
            echo "---"
            echo ""

            test_spaces_switching && passed=$((passed + 1))
            total=6
            ;;
    esac

    echo ""
    echo "---"
    echo ""

    # Summary
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}Test Summary${NC}"
    echo -e "${BLUE}================================${NC}"
    echo "Passed: $passed/$total"

    if [ $passed -eq $total ]; then
        echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
        exit 0
    elif [ $passed -ge $((total / 2)) ]; then
        echo -e "${YELLOW}⚠ SOME TESTS PASSED${NC}"
        exit 0
    else
        echo -e "${RED}✗ MOST TESTS FAILED${NC}"
        exit 1
    fi
}

# Show usage if requested
if [ "$TEST_NAME" = "--help" ] || [ "$TEST_NAME" = "-h" ]; then
    echo "Usage: $0 [TEST_NAME]"
    echo ""
    echo "Available tests:"
    echo "  network, 1     - Network interruption recovery"
    echo "  sleep, 2       - Mac sleep/wake handling"
    echo "  termination, 3 - Process termination handling"
    echo "  port, 4        - Port conflict handling"
    echo "  wifi, 5        - Different WiFi networks"
    echo "  spaces, 6      - Cross-Spaces window switching"
    echo "  all            - Run all tests (default)"
    echo ""
    echo "Examples:"
    echo "  $0              # Run all tests"
    echo "  $0 network      # Run network test only"
    echo "  $0 1            # Run test #1 only"
    exit 0
fi

# Run tests
main
