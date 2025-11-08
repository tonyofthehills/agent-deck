# Testing Quick Reference

**One-page cheat sheet for Agent Deck MVP testing**

---

## 🚀 Quick Start (5 minutes)

```bash
# Run quick test suite (skip 24-hour stability)
./run-all-tests.sh --quick --skip-stability

# View results
cat ~/.agent-deck/test-results-*/TEST_REPORT.md
```

**Expected:** ~30 minutes, all tests passing

---

## 📋 Available Test Scripts

| Script | Purpose | Time | Command |
|--------|---------|------|---------|
| **test-latency.sh** | Launch, status updates, window switching | 5-10 min | `./test-latency.sh` |
| **test-multi-instance.sh** | Concurrent agents, resource usage | 5-10 min | `./test-multi-instance.sh` |
| **test-resilience.sh** | Network errors, sleep/wake, failures | 15-30 min | `./test-resilience.sh` |
| **test-stability.sh** | 24-hour monitoring, memory leaks | 1-24 hours | `./test-stability.sh` |
| **run-all-tests.sh** | Run everything | 30 min - 24h | `./run-all-tests.sh` |

---

## 🎯 Common Commands

### Run Individual Tests

```bash
# Latency tests
./test-latency.sh --iterations 3 --verbose

# Multi-instance tests
./test-multi-instance.sh --instances 5 --clients 3

# Resilience (specific)
./test-resilience.sh network     # Network interruption only
./test-resilience.sh port        # Port conflict only

# Stability (custom duration)
./test-stability.sh --duration 1      # 1-hour test
./test-stability.sh monitor           # Real-time monitoring
```

### View Results

```bash
# Latest test results
cat ~/.agent-deck/test-results-*/TEST_REPORT.md

# Real-time logs
tail -f ~/.agent-deck/test-results-*/1-latency.log

# Stability CSV data
open ~/.agent-deck/stability-test-*.log.csv
```

### Check App Status

```bash
# Is Agent Deck running?
pgrep -x Agent-Deck

# Which ports are listening?
lsof -iTCP:3000,3001 -sTCP:LISTEN

# How many Claude Code instances?
pgrep -i claude | wc -l

# Resource usage
ps aux | grep Agent-Deck
```

---

## 📱 Manual Testing

### Mobile PWA (iOS/Android)

1. **Get Mac IP:** Click Agent Deck menubar → QR code
2. **Connect phone:** Same WiFi as Mac
3. **Open PWA:** `http://[MAC-IP]:3000`
4. **Follow:** `TEST_PROCEDURE_MOBILE.md` (607 lines)

**Time:** 15-60 minutes per platform

### Permissions Testing

1. **Reset permissions:** `tccutil reset Accessibility com.agentdeck.mac`
2. **Launch app**
3. **Follow:** `TEST_PROCEDURE_PERMISSIONS.md` (609 lines)

**Time:** 20-45 minutes

---

## ✅ Pre-Launch Checklist

**Quick (5 min):**
- [ ] `./run-all-tests.sh --quick --skip-stability`
- [ ] All tests passing
- [ ] No P0/P1 issues open

**Full (2 hours):**
- [ ] All automated tests passing
- [ ] iOS Safari manual tests complete
- [ ] Android Chrome manual tests complete
- [ ] Permissions tests complete
- [ ] 1-hour stability test passing

**Before Release:**
- [ ] 24-hour stability test complete
- [ ] Test report generated
- [ ] All issues documented
- [ ] README updated

---

## 🐛 Troubleshooting

### Tests Fail: "Agent Deck not running"

```bash
# Check if running
pgrep -x Agent-Deck

# Start manually
open ~/Library/Developer/Xcode/DerivedData/Agent-Deck-*/Build/Products/Debug/Agent-Deck.app

# Wait 3 seconds, then retry
sleep 3 && ./test-latency.sh
```

### Tests Fail: "Port already in use"

```bash
# Find what's using ports
lsof -iTCP:3000,3001 -sTCP:LISTEN

# Kill Agent Deck
pkill -9 Agent-Deck

# Wait and restart
sleep 2 && open ~/Library/Developer/Xcode/DerivedData/Agent-Deck-*/Build/Products/Debug/Agent-Deck.app
```

### Tests Fail: "No Claude Code instances"

```bash
# Start Claude Code
claude  # or open -a Claude

# Verify
pgrep -i claude
```

### WebSocket Tests Fail: "ws module not found"

```bash
# Install Node.js dependencies
npm install -g ws

# Or skip WebSocket tests (they'll show as warnings)
```

---

## 📊 Success Criteria

**Must Pass Before Launch:**

| Metric | Target | Check |
|--------|--------|-------|
| Launch time | <2s | ✅ |
| Status update latency | <500ms | ✅ |
| Window switch latency | <1s | ✅ |
| Memory usage (idle) | <100MB | ✅ |
| CPU usage (idle) | <5% | ✅ |
| 24-hour stability | No crashes | ✅ |
| PWA install | iOS + Android | ✅ |
| Network recovery | <5s | ✅ |

**Current Status (as of 2025-11-04):** 94% pass rate (17/18 tests)

---

## 📁 File Reference

### Automation Scripts
- `test-latency.sh` (429 lines) - Performance tests
- `test-multi-instance.sh` (443 lines) - Concurrency tests
- `test-resilience.sh` (514 lines) - Error handling tests
- `test-stability.sh` (433 lines) - Long-running tests
- `run-all-tests.sh` (346 lines) - Master runner

### Documentation
- `TEST_PROCEDURE_MOBILE.md` (607 lines) - Mobile testing guide
- `TEST_PROCEDURE_PERMISSIONS.md` (609 lines) - Permissions guide
- `TEST_REPORT_TEMPLATE.md` (601 lines) - Report template
- `TESTING_ISSUES_LOG.md` (484 lines) - Issue tracker
- `TESTING_SUITE_SUMMARY.md` (1200+ lines) - Complete overview

### Historical
- `TEST_REPORT.md` (495 lines) - 2025-11-04 test results
- `TESTING_REPORT.md` - Playwright test report
- `TESTING_SESSION_SUMMARY.md` - Session summary

---

## 🔍 Quick Diagnostics

### Check Test Environment

```bash
# macOS version
sw_vers

# Xcode version
xcodebuild -version

# App built?
ls ~/Library/Developer/Xcode/DerivedData/Agent-Deck-*/Build/Products/Debug/Agent-Deck.app

# WiFi network
networksetup -getairportnetwork en0

# Local IP
ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'
```

### View Logs

```bash
# Recent Agent Deck logs
log show --predicate 'subsystem == "com.agentdeck.mac"' --last 5m

# Stream real-time logs
log stream --predicate 'subsystem == "com.agentdeck.mac"'

# Filter for errors only
log show --predicate 'subsystem == "com.agentdeck.mac"' --last 5m | grep -i error
```

---

## 💡 Tips & Tricks

### Speed Up Testing

```bash
# Quick mode (fewer iterations)
./run-all-tests.sh --quick

# Skip long tests
./run-all-tests.sh --skip-stability

# Run specific test only
./test-latency.sh  # Just latency
```

### Parallel Testing

```bash
# Terminal 1: Run automated tests
./run-all-tests.sh --quick &

# Terminal 2: Manual mobile tests
open TEST_PROCEDURE_MOBILE.md

# Terminal 3: Monitor logs
log stream --predicate 'subsystem == "com.agentdeck.mac"'
```

### CI/CD Integration

```bash
# Exit codes for automation
# 0 = success, 1 = failure

# Example GitHub Actions
./run-all-tests.sh --quick && echo "✅ Tests passed" || echo "❌ Tests failed"
```

---

## 📞 Support

**Issues?** Update `TESTING_ISSUES_LOG.md`
**Questions?** See `TESTING_SUITE_SUMMARY.md`
**Full Details?** See individual `TEST_PROCEDURE_*.md` files

---

**Last Updated:** 2025-11-06
**Next Update:** After test runs or issue discoveries
