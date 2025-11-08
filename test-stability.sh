#!/bin/bash

# test-stability.sh
# 24-hour stability and resource monitoring for Agent Deck MVP
# Tests: Long-running stability, memory leaks, resource usage, connection stability
# Usage: ./test-stability.sh [--duration HOURS]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
APP_NAME="Agent-Deck"
DURATION_HOURS=24
SAMPLE_INTERVAL=300  # 5 minutes in seconds
LOG_FILE="$HOME/.agent-deck/stability-test-$(date +%Y%m%d-%H%M%S).log"
MAX_MEMORY_GROWTH_PERCENT=20  # Alert if memory grows >20%
MAX_CPU_AVERAGE=10  # Alert if average CPU >10%

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --duration)
            DURATION_HOURS="$2"
            shift 2
            ;;
        *)
            echo "Usage: $0 [--duration HOURS]"
            exit 1
            ;;
    esac
done

# Calculate total samples
TOTAL_SAMPLES=$((DURATION_HOURS * 3600 / SAMPLE_INTERVAL))

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Agent Deck Stability Test${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "Configuration:"
echo "  - Duration: ${DURATION_HOURS} hours"
echo "  - Sample interval: ${SAMPLE_INTERVAL}s ($(($SAMPLE_INTERVAL / 60)) minutes)"
echo "  - Total samples: ${TOTAL_SAMPLES}"
echo "  - Log file: ${LOG_FILE}"
echo ""

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

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
    local cpu=$(ps -o %cpu= -p $pid 2>/dev/null | tr -d ' ')
    if [ -z "$cpu" ]; then
        echo "0"
    else
        echo "$cpu" | awk '{printf "%.1f", $1}'
    fi
}

# Function to check network listeners
check_network() {
    local http_ok=0
    local ws_ok=0

    if lsof -iTCP:3000 -sTCP:LISTEN > /dev/null 2>&1; then
        http_ok=1
    fi

    if lsof -iTCP:3001 -sTCP:LISTEN > /dev/null 2>&1; then
        ws_ok=1
    fi

    echo "$http_ok $ws_ok"
}

# Function to log message
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Function to take sample
take_sample() {
    local sample_num=$1
    local pid=$2

    if ! ps -p $pid > /dev/null 2>&1; then
        log_message "ERROR: App process ($pid) no longer running"
        return 1
    fi

    local mem=$(get_memory_usage $pid)
    local cpu=$(get_cpu_usage $pid)
    local network=$(check_network)
    local http_ok=$(echo $network | awk '{print $1}')
    local ws_ok=$(echo $network | awk '{print $2}')
    local claude_count=$(pgrep -i "claude" | wc -l | tr -d ' ')

    # Format: sample_num,timestamp,mem,cpu,http_ok,ws_ok,claude_count
    echo "$sample_num,$(date +%s),$mem,$cpu,$http_ok,$ws_ok,$claude_count"
}

# =============================================================================
# Main Stability Test
# =============================================================================
run_stability_test() {
    echo -e "${YELLOW}Starting ${DURATION_HOURS}-hour stability test...${NC}"
    echo ""

    # Check if app is running
    if ! is_app_running; then
        echo -e "${RED}✗ Agent Deck is not running${NC}"
        echo "Please start Agent Deck before running stability test"
        exit 1
    fi

    local pid=$(get_app_pid)
    log_message "Starting stability test for Agent Deck (PID: $pid)"

    # Get baseline measurements
    local baseline_mem=$(get_memory_usage $pid)
    local baseline_cpu=$(get_cpu_usage $pid)

    log_message "Baseline: Memory=${baseline_mem}MB, CPU=${baseline_cpu}%"
    echo "Baseline:"
    echo "  - PID: $pid"
    echo "  - Memory: ${baseline_mem}MB"
    echo "  - CPU: ${baseline_cpu}%"
    echo ""

    # Initialize tracking variables
    local total_mem=0
    local total_cpu=0
    local max_mem=$baseline_mem
    local min_mem=$baseline_mem
    local max_cpu=$baseline_cpu
    local crashes=0
    local network_failures=0
    local samples_taken=0

    # CSV header
    echo "sample,timestamp,memory_mb,cpu_percent,http_ok,ws_ok,claude_count" > "${LOG_FILE}.csv"

    # Monitoring loop
    echo "Monitoring progress:"
    echo ""

    for sample in $(seq 1 $TOTAL_SAMPLES); do
        # Take sample
        local data=$(take_sample $sample $pid)

        if [ $? -ne 0 ]; then
            crashes=$((crashes + 1))
            log_message "CRASH DETECTED - App no longer running"
            echo -e "${RED}✗ App crashed at sample $sample${NC}"
            break
        fi

        # Parse data
        local mem=$(echo $data | cut -d, -f3)
        local cpu=$(echo $data | cut -d, -f4)
        local http_ok=$(echo $data | cut -d, -f5)
        local ws_ok=$(echo $data | cut -d, -f6)

        # Log to CSV
        echo "$data" >> "${LOG_FILE}.csv"

        # Update statistics
        total_mem=$((total_mem + mem))
        total_cpu=$(echo "$total_cpu + $cpu" | bc)
        samples_taken=$((samples_taken + 1))

        if [ $mem -gt $max_mem ]; then
            max_mem=$mem
        fi
        if [ $mem -lt $min_mem ]; then
            min_mem=$mem
        fi
        if [ $(echo "$cpu > $max_cpu" | bc) -eq 1 ]; then
            max_cpu=$cpu
        fi

        # Check network
        if [ $http_ok -eq 0 ] || [ $ws_ok -eq 0 ]; then
            network_failures=$((network_failures + 1))
            log_message "WARNING: Network listener down (HTTP=$http_ok, WS=$ws_ok)"
        fi

        # Progress indicator
        local elapsed_hours=$(echo "scale=1; $sample * $SAMPLE_INTERVAL / 3600" | bc)
        local percent=$((sample * 100 / TOTAL_SAMPLES))

        echo -ne "\rProgress: $percent% | Sample $sample/$TOTAL_SAMPLES | Elapsed: ${elapsed_hours}h | Mem: ${mem}MB | CPU: ${cpu}%     "

        # Periodic detailed log
        if [ $((sample % 12)) -eq 0 ]; then
            echo ""
            log_message "Sample $sample: Memory=${mem}MB, CPU=${cpu}%, Network=(HTTP=$http_ok,WS=$ws_ok)"
        fi

        # Wait for next sample
        if [ $sample -lt $TOTAL_SAMPLES ]; then
            sleep $SAMPLE_INTERVAL
        fi
    done

    echo ""
    echo ""

    # Calculate final statistics
    if [ $samples_taken -gt 0 ]; then
        local avg_mem=$((total_mem / samples_taken))
        local avg_cpu=$(echo "scale=1; $total_cpu / $samples_taken" | bc)
        local mem_growth=$((max_mem - baseline_mem))
        local mem_growth_percent=0

        if [ $baseline_mem -gt 0 ]; then
            mem_growth_percent=$((mem_growth * 100 / baseline_mem))
        fi

        log_message "Test completed: $samples_taken samples taken"
        log_message "Memory: Baseline=${baseline_mem}MB, Avg=${avg_mem}MB, Max=${max_mem}MB, Growth=${mem_growth_percent}%"
        log_message "CPU: Avg=${avg_cpu}%, Max=${max_cpu}%"
        log_message "Issues: Crashes=$crashes, Network failures=$network_failures"

        # Print results
        echo -e "${BLUE}================================${NC}"
        echo -e "${BLUE}Stability Test Results${NC}"
        echo -e "${BLUE}================================${NC}"
        echo ""
        echo "Duration: ${elapsed_hours}/${DURATION_HOURS} hours"
        echo "Samples taken: $samples_taken/$TOTAL_SAMPLES"
        echo ""
        echo "Memory Usage:"
        echo "  - Baseline: ${baseline_mem}MB"
        echo "  - Average: ${avg_mem}MB"
        echo "  - Maximum: ${max_mem}MB"
        echo "  - Minimum: ${min_mem}MB"
        echo "  - Growth: ${mem_growth}MB (${mem_growth_percent}%)"
        echo ""
        echo "CPU Usage:"
        echo "  - Average: ${avg_cpu}%"
        echo "  - Maximum: ${max_cpu}%"
        echo ""
        echo "Stability:"
        echo "  - Crashes: $crashes"
        echo "  - Network failures: $network_failures"
        echo ""
        echo "Log files:"
        echo "  - Text log: ${LOG_FILE}"
        echo "  - CSV data: ${LOG_FILE}.csv"
        echo ""

        # Determine pass/fail
        local passed=true

        if [ $crashes -gt 0 ]; then
            echo -e "${RED}✗ FAIL: App crashed during test${NC}"
            passed=false
        else
            echo -e "${GREEN}✓ PASS: No crashes${NC}"
        fi

        if [ $mem_growth_percent -gt $MAX_MEMORY_GROWTH_PERCENT ]; then
            echo -e "${RED}✗ FAIL: Memory growth ${mem_growth_percent}% exceeds threshold ${MAX_MEMORY_GROWTH_PERCENT}%${NC}"
            echo "  Possible memory leak - investigate"
            passed=false
        else
            echo -e "${GREEN}✓ PASS: Memory growth ${mem_growth_percent}% within limits${NC}"
        fi

        if [ $(echo "$avg_cpu > $MAX_CPU_AVERAGE" | bc) -eq 1 ]; then
            echo -e "${YELLOW}⚠ WARNING: Average CPU ${avg_cpu}% exceeds threshold ${MAX_CPU_AVERAGE}%${NC}"
        else
            echo -e "${GREEN}✓ PASS: Average CPU ${avg_cpu}% within limits${NC}"
        fi

        if [ $network_failures -gt $((TOTAL_SAMPLES / 10)) ]; then
            echo -e "${RED}✗ FAIL: Too many network failures ($network_failures)${NC}"
            passed=false
        elif [ $network_failures -gt 0 ]; then
            echo -e "${YELLOW}⚠ WARNING: $network_failures network failures${NC}"
        else
            echo -e "${GREEN}✓ PASS: No network failures${NC}"
        fi

        echo ""

        if [ "$passed" = true ]; then
            echo -e "${GREEN}✓ STABILITY TEST PASSED${NC}"
            return 0
        else
            echo -e "${RED}✗ STABILITY TEST FAILED${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ No samples collected${NC}"
        return 1
    fi
}

# =============================================================================
# Monitor Mode (Real-time display)
# =============================================================================
monitor_mode() {
    echo -e "${YELLOW}Real-time monitoring mode (Ctrl+C to stop)${NC}"
    echo ""

    if ! is_app_running; then
        echo -e "${RED}✗ Agent Deck is not running${NC}"
        exit 1
    fi

    local pid=$(get_app_pid)
    echo "Monitoring Agent Deck (PID: $pid)"
    echo ""

    while true; do
        local mem=$(get_memory_usage $pid)
        local cpu=$(get_cpu_usage $pid)
        local network=$(check_network)
        local http_ok=$(echo $network | awk '{print $1}')
        local ws_ok=$(echo $network | awk '{print $2}')
        local claude_count=$(pgrep -i "claude" | wc -l | tr -d ' ')

        local timestamp=$(date '+%H:%M:%S')

        echo -ne "\r[$timestamp] Memory: ${mem}MB | CPU: ${cpu}% | HTTP: $http_ok | WS: $ws_ok | Claude: $claude_count     "

        sleep 2
    done
}

# =============================================================================
# Analyze CSV Log
# =============================================================================
analyze_log() {
    local csv_file="$1"

    if [ ! -f "$csv_file" ]; then
        echo -e "${RED}✗ Log file not found: $csv_file${NC}"
        exit 1
    fi

    echo -e "${BLUE}Analyzing stability test log: $csv_file${NC}"
    echo ""

    # Use awk to analyze CSV
    awk -F, '
    NR > 1 {
        mem_sum += $3
        cpu_sum += $4
        if ($3 > max_mem) max_mem = $3
        if (NR == 2) min_mem = $3
        if ($3 < min_mem) min_mem = $3
        if ($4 > max_cpu) max_cpu = $4
        count++
    }
    END {
        if (count > 0) {
            printf "Samples: %d\n", count
            printf "Memory: Avg=%.1fMB, Min=%dMB, Max=%dMB\n", mem_sum/count, min_mem, max_mem
            printf "CPU: Avg=%.1f%%, Max=%.1f%%\n", cpu_sum/count, max_cpu
        }
    }
    ' "$csv_file"
}

# =============================================================================
# Main Entry Point
# =============================================================================
case "${1:-test}" in
    test)
        run_stability_test
        ;;
    monitor)
        monitor_mode
        ;;
    analyze)
        analyze_log "${2:-}"
        ;;
    --help|-h)
        echo "Usage: $0 [COMMAND] [OPTIONS]"
        echo ""
        echo "Commands:"
        echo "  test              Run stability test (default)"
        echo "  monitor           Real-time monitoring mode"
        echo "  analyze FILE.csv  Analyze existing log"
        echo ""
        echo "Options for 'test':"
        echo "  --duration HOURS  Test duration (default: 24)"
        echo ""
        echo "Examples:"
        echo "  $0                       # Run 24-hour test"
        echo "  $0 --duration 1          # Run 1-hour test"
        echo "  $0 monitor               # Real-time monitoring"
        echo "  $0 analyze stability.csv # Analyze log"
        exit 0
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
