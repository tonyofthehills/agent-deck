#!/bin/bash

# run-all-tests.sh
# Master test runner for Agent Deck MVP
# Executes all automated test suites in sequence
# Usage: ./run-all-tests.sh [--quick] [--skip-stability]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
QUICK_MODE=false
SKIP_STABILITY=false
RESULTS_DIR="$HOME/.agent-deck/test-results-$(date +%Y%m%d-%H%M%S)"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            QUICK_MODE=true
            shift
            ;;
        --skip-stability)
            SKIP_STABILITY=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --quick           Run fewer iterations (faster)"
            echo "  --skip-stability  Skip 24-hour stability test"
            echo "  --help            Show this help message"
            echo ""
            echo "Test suites:"
            echo "  1. Latency tests (launch, status, window switching)"
            echo "  2. Multi-instance tests (concurrency, resource usage)"
            echo "  3. Resilience tests (network, sleep/wake, errors)"
            echo "  4. Stability test (24-hour monitoring)"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Create results directory
mkdir -p "$RESULTS_DIR"

echo -e "${CYAN}======================================${NC}"
echo -e "${CYAN}Agent Deck MVP - Master Test Runner${NC}"
echo -e "${CYAN}======================================${NC}"
echo ""
echo "Configuration:"
echo "  - Quick mode: $QUICK_MODE"
echo "  - Skip stability: $SKIP_STABILITY"
echo "  - Results directory: $RESULTS_DIR"
echo ""
echo "Starting test execution at $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Function to run test and log results
run_test_suite() {
    local test_name="$1"
    local test_script="$2"
    local test_args="$3"
    local log_file="$RESULTS_DIR/${test_name}.log"

    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Running: $test_name${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    if [ ! -f "$test_script" ]; then
        echo -e "${RED}✗ Test script not found: $test_script${NC}"
        echo "SKIPPED" > "$log_file"
        return 1
    fi

    # Run test and capture output
    local start_time=$(date +%s)

    if $test_script $test_args > "$log_file" 2>&1; then
        local exit_code=0
        local status="${GREEN}PASSED${NC}"
    else
        local exit_code=$?
        local status="${RED}FAILED${NC}"
    fi

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Display last 20 lines of output
    echo ""
    echo "Last 20 lines of output:"
    echo "---"
    tail -20 "$log_file"
    echo "---"
    echo ""

    echo -e "Status: $status (Exit code: $exit_code, Duration: ${duration}s)"
    echo -e "Full log: $log_file"

    return $exit_code
}

# Track results
declare -A test_results
test_count=0
passed_count=0

# =============================================================================
# TEST SUITE 1: Latency Tests
# =============================================================================
test_count=$((test_count + 1))

if [ "$QUICK_MODE" = true ]; then
    iterations="--iterations 2"
else
    iterations=""
fi

if run_test_suite "1-latency" "./test-latency.sh" "$iterations"; then
    test_results[1]="PASSED"
    passed_count=$((passed_count + 1))
else
    test_results[1]="FAILED"
fi

# =============================================================================
# TEST SUITE 2: Multi-Instance Tests
# =============================================================================
test_count=$((test_count + 1))

if [ "$QUICK_MODE" = true ]; then
    instances="--instances 2 --clients 2"
else
    instances=""
fi

if run_test_suite "2-multi-instance" "./test-multi-instance.sh" "$instances"; then
    test_results[2]="PASSED"
    passed_count=$((passed_count + 1))
else
    test_results[2]="FAILED"
fi

# =============================================================================
# TEST SUITE 3: Resilience Tests
# =============================================================================
test_count=$((test_count + 1))

# Run automated resilience tests only (skip manual tests in quick mode)
if [ "$QUICK_MODE" = true ]; then
    echo ""
    echo -e "${YELLOW}Running automated resilience tests only (quick mode)${NC}"
    echo ""

    # Run individual automated tests
    manual_pass=true

    for test_name in "network" "termination" "port"; do
        if run_test_suite "3-resilience-$test_name" "./test-resilience.sh" "$test_name"; then
            echo -e "${GREEN}✓ $test_name test passed${NC}"
        else
            echo -e "${RED}✗ $test_name test failed${NC}"
            manual_pass=false
        fi
    done

    if [ "$manual_pass" = true ]; then
        test_results[3]="PASSED"
        passed_count=$((passed_count + 1))
    else
        test_results[3]="FAILED"
    fi
else
    if run_test_suite "3-resilience" "./test-resilience.sh" "all"; then
        test_results[3]="PASSED"
        passed_count=$((passed_count + 1))
    else
        test_results[3]="FAILED"
    fi
fi

# =============================================================================
# TEST SUITE 4: Stability Test (Optional)
# =============================================================================
if [ "$SKIP_STABILITY" = false ]; then
    test_count=$((test_count + 1))

    if [ "$QUICK_MODE" = true ]; then
        duration="--duration 1"  # 1 hour in quick mode
        echo ""
        echo -e "${YELLOW}Running 1-hour stability test (quick mode)${NC}"
        echo ""
    else
        duration=""  # 24 hours in full mode
        echo ""
        echo -e "${YELLOW}Starting 24-hour stability test${NC}"
        echo -e "${YELLOW}This will take a long time. Press Ctrl+C to skip.${NC}"
        echo ""
        sleep 5
    fi

    if run_test_suite "4-stability" "./test-stability.sh" "$duration"; then
        test_results[4]="PASSED"
        passed_count=$((passed_count + 1))
    else
        test_results[4]="FAILED"
    fi
else
    echo ""
    echo -e "${YELLOW}Skipping stability test (--skip-stability)${NC}"
    echo ""
fi

# =============================================================================
# Generate Summary Report
# =============================================================================
echo ""
echo -e "${CYAN}======================================${NC}"
echo -e "${CYAN}Test Execution Summary${NC}"
echo -e "${CYAN}======================================${NC}"
echo ""
echo "Completed at: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "Test Results:"
echo ""

for i in "${!test_results[@]}"; do
    local test_name=""
    case $i in
        1) test_name="Latency Tests" ;;
        2) test_name="Multi-Instance Tests" ;;
        3) test_name="Resilience Tests" ;;
        4) test_name="Stability Test" ;;
    esac

    if [ "${test_results[$i]}" = "PASSED" ]; then
        echo -e "  ${GREEN}✓${NC} $test_name: ${GREEN}PASSED${NC}"
    else
        echo -e "  ${RED}✗${NC} $test_name: ${RED}FAILED${NC}"
    fi
done

echo ""
echo "Summary: $passed_count/$test_count test suites passed"
echo ""

# Calculate pass percentage
if [ $test_count -gt 0 ]; then
    pass_percentage=$((passed_count * 100 / test_count))
    echo "Pass rate: ${pass_percentage}%"
    echo ""
fi

# Generate detailed report
REPORT_FILE="$RESULTS_DIR/TEST_REPORT.md"

cat > "$REPORT_FILE" << EOF
# Agent Deck MVP - Test Report

**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Mode:** $([ "$QUICK_MODE" = true ] && echo "Quick" || echo "Full")
**Results Directory:** $RESULTS_DIR

---

## Summary

- **Total Test Suites:** $test_count
- **Passed:** $passed_count
- **Failed:** $((test_count - passed_count))
- **Pass Rate:** ${pass_percentage}%

---

## Test Results

EOF

for i in "${!test_results[@]}"; do
    local test_name=""
    local log_file="$RESULTS_DIR/${i}-*.log"

    case $i in
        1) test_name="Latency Tests" ;;
        2) test_name="Multi-Instance Tests" ;;
        3) test_name="Resilience Tests" ;;
        4) test_name="Stability Test" ;;
    esac

    echo "### $test_name" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "**Status:** ${test_results[$i]}" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Include last 30 lines of log
    local actual_log=$(ls $RESULTS_DIR/${i}-* 2>/dev/null | head -1)
    if [ -n "$actual_log" ] && [ -f "$actual_log" ]; then
        echo '```' >> "$REPORT_FILE"
        tail -30 "$actual_log" >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"
    fi

    echo "" >> "$REPORT_FILE"
done

cat >> "$REPORT_FILE" << EOF
---

## Files Generated

EOF

ls -1 "$RESULTS_DIR" >> "$REPORT_FILE"

echo ""
echo -e "Detailed report: ${CYAN}$REPORT_FILE${NC}"
echo ""

# Final status
if [ $passed_count -eq $test_count ]; then
    echo -e "${GREEN}✓ ALL TEST SUITES PASSED${NC}"
    exit 0
elif [ $passed_count -ge $((test_count / 2)) ]; then
    echo -e "${YELLOW}⚠ SOME TEST SUITES PASSED${NC}"
    exit 1
else
    echo -e "${RED}✗ MOST TEST SUITES FAILED${NC}"
    exit 1
fi
