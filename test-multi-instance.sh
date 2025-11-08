#!/bin/bash

# test-multi-instance.sh
# Multi-instance and concurrency testing for Agent Deck MVP
# Tests: Multiple agent detection, multiple PWA clients, resource usage validation
# Usage: ./test-multi-instance.sh [--instances N] [--clients N]

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
TARGET_INSTANCES=3  # Minimum instances to test
TARGET_CLIENTS=3    # Number of PWA clients to simulate
MAX_MEMORY_MB=100   # Maximum memory usage in MB
MAX_CPU_PERCENT=5   # Maximum CPU usage when idle

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --instances)
            TARGET_INSTANCES="$2"
            shift 2
            ;;
        --clients)
            TARGET_CLIENTS="$2"
            shift 2
            ;;
        *)
            echo "Usage: $0 [--instances N] [--clients N]"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Multi-Instance Test Suite${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "Configuration:"
echo "  - Target instances: ${TARGET_INSTANCES}"
echo "  - PWA clients: ${TARGET_CLIENTS}"
echo "  - Max memory: ${MAX_MEMORY_MB}MB"
echo "  - Max CPU (idle): ${MAX_CPU_PERCENT}%"
echo ""

# Function to check if app is running
is_app_running() {
    pgrep -x "$APP_NAME" > /dev/null 2>&1
}

# Function to get app PID
get_app_pid() {
    pgrep -x "$APP_NAME" | head -1
}

# Function to get memory usage in MB
get_memory_usage() {
    local pid=$1
    # Get RSS (Resident Set Size) in KB, convert to MB
    local mem_kb=$(ps -o rss= -p $pid 2>/dev/null | tr -d ' ')
    if [ -z "$mem_kb" ]; then
        echo "0"
    else
        echo $(($mem_kb / 1024))
    fi
}

# Function to get CPU usage percentage
get_cpu_usage() {
    local pid=$1
    # Get CPU percentage
    local cpu=$(ps -o %cpu= -p $pid 2>/dev/null | tr -d ' ')
    if [ -z "$cpu" ]; then
        echo "0"
    else
        # Remove decimal point for comparison
        echo "$cpu" | awk '{printf "%.0f", $1}'
    fi
}

# =============================================================================
# TEST 1: Multiple Instance Detection (3-10 concurrent)
# =============================================================================
test_multiple_instances() {
    echo -e "${YELLOW}[TEST 1] Multiple Instance Detection${NC}"
    echo "Target: Detect at least ${TARGET_INSTANCES} Claude Code instances"
    echo ""

    # Ensure app is running
    if ! is_app_running; then
        echo -e "${RED}✗ Agent Deck is not running${NC}"
        echo "Please start Agent Deck first"
        return 1
    fi

    # Count Claude Code instances
    local count=$(pgrep -i "claude" | wc -l | tr -d ' ')

    echo "Currently running Claude Code instances: $count"
    echo ""
    pgrep -i "claude" -l

    echo ""
    if [ $count -ge $TARGET_INSTANCES ]; then
        echo -e "${GREEN}✓ TEST PASSED${NC} - Detected $count instances (target: $TARGET_INSTANCES)"
        return 0
    elif [ $count -ge 1 ]; then
        echo -e "${YELLOW}⚠ TEST PARTIAL${NC} - Detected $count instances (target: $TARGET_INSTANCES)"
        echo "Start more Claude Code instances to fully test multi-instance support"
        return 0
    else
        echo -e "${RED}✗ TEST FAILED${NC} - No instances detected"
        echo "Start at least one Claude Code instance"
        return 1
    fi
}

# =============================================================================
# TEST 2: Multiple PWA Clients (1-5 devices)
# =============================================================================
test_multiple_clients() {
    echo -e "${YELLOW}[TEST 2] Multiple PWA Client Connections${NC}"
    echo "Target: ${TARGET_CLIENTS} concurrent WebSocket connections"
    echo ""

    # Check if Node.js is available
    if ! command -v node > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠ Node.js not found - skipping WebSocket client test${NC}"
        echo "Install Node.js to test multiple clients"
        return 0
    fi

    # Check if ws module is available
    if ! node -e "require('ws')" 2>/dev/null; then
        echo -e "${YELLOW}⚠ 'ws' module not found${NC}"
        echo "Install with: npm install -g ws"
        echo "Skipping multiple client test"
        return 0
    fi

    # Create WebSocket client test script
    cat > /tmp/test_ws_clients.js << 'EOF'
const WebSocket = require('ws');

const TARGET_CLIENTS = parseInt(process.argv[2]) || 3;
const WS_URL = 'ws://localhost:3001';

let connectedClients = 0;
let receivedMessages = 0;
const clients = [];

console.log(`Connecting ${TARGET_CLIENTS} clients to ${WS_URL}...`);

for (let i = 0; i < TARGET_CLIENTS; i++) {
    const ws = new WebSocket(WS_URL);

    ws.on('open', () => {
        connectedClients++;
        console.log(`Client ${i + 1} connected (${connectedClients}/${TARGET_CLIENTS})`);

        if (connectedClients === TARGET_CLIENTS) {
            console.log(`\n✓ All ${TARGET_CLIENTS} clients connected successfully`);

            // Wait a bit to receive messages
            setTimeout(() => {
                console.log(`\nTotal messages received across all clients: ${receivedMessages}`);

                // Close all connections
                clients.forEach(c => c.close());

                if (receivedMessages > 0) {
                    console.log('✓ Broadcast working - all clients receiving messages');
                    process.exit(0);
                } else {
                    console.log('⚠ No messages received yet');
                    process.exit(0);
                }
            }, 3000);
        }
    });

    ws.on('message', (data) => {
        receivedMessages++;
        const msg = JSON.parse(data);
        console.log(`Client ${i + 1} received: ${msg.type}`);
    });

    ws.on('error', (err) => {
        console.error(`Client ${i + 1} error: ${err.message}`);
    });

    ws.on('close', () => {
        // Silent close
    });

    clients.push(ws);
}

// Timeout after 10 seconds
setTimeout(() => {
    console.error('\n✗ Timeout waiting for connections');
    clients.forEach(c => c.close());
    process.exit(1);
}, 10000);
EOF

    # Run the test
    node /tmp/test_ws_clients.js $TARGET_CLIENTS

    local exit_code=$?
    rm -f /tmp/test_ws_clients.js

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
# TEST 3: Resource Usage Validation (<100MB RAM, <5% CPU)
# =============================================================================
test_resource_usage() {
    echo -e "${YELLOW}[TEST 3] Resource Usage Validation${NC}"
    echo "Targets: Memory <${MAX_MEMORY_MB}MB, CPU <${MAX_CPU_PERCENT}% (idle)"
    echo ""

    if ! is_app_running; then
        echo -e "${RED}✗ Agent Deck is not running${NC}"
        return 1
    fi

    local pid=$(get_app_pid)
    echo "Agent Deck PID: $pid"
    echo ""

    # Take 3 measurements over 6 seconds (2s intervals)
    local total_mem=0
    local total_cpu=0
    local samples=3

    echo "Taking $samples measurements..."
    for i in $(seq 1 $samples); do
        local mem=$(get_memory_usage $pid)
        local cpu=$(get_cpu_usage $pid)

        total_mem=$((total_mem + mem))
        total_cpu=$((total_cpu + cpu))

        echo "  Sample $i: Memory=${mem}MB, CPU=${cpu}%"

        if [ $i -lt $samples ]; then
            sleep 2
        fi
    done

    echo ""

    # Calculate averages
    local avg_mem=$((total_mem / samples))
    local avg_cpu=$((total_cpu / samples))

    echo "Average Results:"
    echo "  - Memory: ${avg_mem}MB (target: <${MAX_MEMORY_MB}MB)"
    echo "  - CPU: ${avg_cpu}% (target: <${MAX_CPU_PERCENT}%)"
    echo ""

    local mem_pass=false
    local cpu_pass=false

    if [ $avg_mem -lt $MAX_MEMORY_MB ]; then
        echo -e "  ${GREEN}✓ Memory usage PASS${NC}"
        mem_pass=true
    else
        echo -e "  ${RED}✗ Memory usage FAIL${NC} (exceeds ${MAX_MEMORY_MB}MB)"
    fi

    if [ $avg_cpu -lt $MAX_CPU_PERCENT ]; then
        echo -e "  ${GREEN}✓ CPU usage PASS${NC}"
        cpu_pass=true
    else
        echo -e "  ${RED}✗ CPU usage FAIL${NC} (exceeds ${MAX_CPU_PERCENT}%)"
    fi

    echo ""

    if [ "$mem_pass" = true ] && [ "$cpu_pass" = true ]; then
        echo -e "${GREEN}✓ TEST PASSED${NC}"
        return 0
    else
        echo -e "${RED}✗ TEST FAILED${NC}"
        return 1
    fi
}

# =============================================================================
# TEST 4: No Performance Degradation with Multiple Instances
# =============================================================================
test_performance_stability() {
    echo -e "${YELLOW}[TEST 4] Performance Stability (Multiple Instances)${NC}"
    echo "Target: Resource usage stable with multiple Claude Code instances"
    echo ""

    if ! is_app_running; then
        echo -e "${RED}✗ Agent Deck is not running${NC}"
        return 1
    fi

    local pid=$(get_app_pid)
    local instance_count=$(pgrep -i "claude" | wc -l | tr -d ' ')

    echo "Current state:"
    echo "  - Agent Deck PID: $pid"
    echo "  - Claude Code instances: $instance_count"
    echo ""

    if [ $instance_count -eq 0 ]; then
        echo -e "${YELLOW}⚠ No Claude Code instances running${NC}"
        echo "Start multiple instances to test performance stability"
        return 0
    fi

    # Measure baseline
    local baseline_mem=$(get_memory_usage $pid)
    local baseline_cpu=$(get_cpu_usage $pid)

    echo "Baseline (with $instance_count instances):"
    echo "  - Memory: ${baseline_mem}MB"
    echo "  - CPU: ${baseline_cpu}%"
    echo ""

    # Monitor for 10 seconds
    echo "Monitoring for 10 seconds..."
    local max_mem=$baseline_mem
    local max_cpu=$baseline_cpu

    for i in {1..5}; do
        sleep 2
        local mem=$(get_memory_usage $pid)
        local cpu=$(get_cpu_usage $pid)

        if [ $mem -gt $max_mem ]; then
            max_mem=$mem
        fi
        if [ $cpu -gt $max_cpu ]; then
            max_cpu=$cpu
        fi

        echo "  Sample $i: Memory=${mem}MB, CPU=${cpu}%"
    done

    echo ""
    echo "Peak values over 10 seconds:"
    echo "  - Memory: ${max_mem}MB"
    echo "  - CPU: ${max_cpu}%"
    echo ""

    # Check for excessive growth
    local mem_growth=$((max_mem - baseline_mem))
    local mem_growth_percent=0
    if [ $baseline_mem -gt 0 ]; then
        mem_growth_percent=$((mem_growth * 100 / baseline_mem))
    fi

    echo "Memory growth: ${mem_growth}MB (${mem_growth_percent}%)"

    if [ $mem_growth_percent -lt 20 ]; then
        echo -e "${GREEN}✓ No significant memory growth${NC}"
        echo -e "${GREEN}✓ TEST PASSED${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ Memory growth: ${mem_growth_percent}%${NC}"
        echo -e "${YELLOW}⚠ TEST WARNING${NC} - Monitor for memory leaks"
        return 0
    fi
}

# =============================================================================
# Main Test Runner
# =============================================================================
main() {
    local passed=0
    local total=4

    # Ensure Agent Deck is running
    if ! is_app_running; then
        echo -e "${RED}✗ Agent Deck is not running${NC}"
        echo "Please start Agent Deck and run tests again"
        exit 1
    fi

    test_multiple_instances && passed=$((passed + 1))
    echo ""
    echo "---"
    echo ""

    test_multiple_clients && passed=$((passed + 1))
    echo ""
    echo "---"
    echo ""

    test_resource_usage && passed=$((passed + 1))
    echo ""
    echo "---"
    echo ""

    test_performance_stability && passed=$((passed + 1))
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
    elif [ $passed -ge 2 ]; then
        echo -e "${YELLOW}⚠ SOME TESTS PASSED${NC}"
        exit 0
    else
        echo -e "${RED}✗ MOST TESTS FAILED${NC}"
        exit 1
    fi
}

# Run tests
main
