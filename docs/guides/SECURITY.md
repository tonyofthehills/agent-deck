# Security Scanning Guide

**Agent Deck - Security with Semgrep MCP**

**CRITICAL: Always scan AI-generated code before committing!**

Agent Deck is a dual-platform project (Swift menubar + React Native mobile) requiring security vigilance across both stacks.

**Last Updated**: 2025-01-24

---

## Table of Contents

1. [When to Scan](#when-to-scan)
2. [How to Scan](#how-to-scan)
3. [Priority Vulnerabilities by Platform](#priority-vulnerabilities-by-platform)
4. [Secure AI Coding Workflow](#secure-ai-coding-workflow)
5. [Project-Specific Custom Rules](#project-specific-custom-rules)
6. [Agent Deck Security Checklist](#agent-deck-security-checklist)
7. [Quick Reference](#quick-reference)

---

## When to Scan

**ALWAYS scan before committing when you:**

1. Generate or modify authentication code (session tokens, API keys)
2. Implement WebSocket communication or real-time updates
3. Add file operations or path handling (Swift menubar app)
4. Work with clipboard or pasteboard monitoring
5. Implement AsyncStorage or SecureStore (React Native)
6. Handle user input in either platform
7. Add pnpm dependencies (`pnpm install` for mobile)
8. Implement cross-origin communication (Swift ↔ React Native)

---

## How to Scan

### Swift Menubar App

```
Scan these files with semgrep_scan:
[
  {"path": "/absolute/path/to/apps/macos/Agent-Deck/Sources/Auth/*.swift"},
  {"path": "/absolute/path/to/apps/macos/Agent-Deck/Sources/WebSocket/*.swift"}
]
```

### React Native Mobile App

```
Scan these files with semgrep_scan:
[
  {"path": "/absolute/path/to/apps/mobile/src/services/websocket.ts"},
  {"path": "/absolute/path/to/apps/mobile/src/screens/QRScannerScreen.tsx"}
]
```

### Supply Chain (After pnpm install)

```bash
cd apps/mobile && semgrep_scan_supply_chain
```

---

## Priority Vulnerabilities by Platform

### Swift Menubar App (ERROR severity)

- ❌ Hardcoded API keys or session tokens
- ❌ Insecure Keychain usage
- ❌ Unsafe URL scheme handling
- ❌ UserDefaults for sensitive data
- ❌ Command injection in shell operations
- ❌ Path traversal in file operations
- ❌ Unvalidated WebSocket messages

### React Native Mobile (ERROR severity)

- ❌ XSS vulnerabilities in WebView components
- ❌ Insecure AsyncStorage for tokens/secrets
- ❌ Unvalidated WebSocket messages
- ❌ Deep link injection attacks
- ❌ Expo SDK misconfigurations
- ❌ Insecure network requests
- ❌ Unencrypted sensitive data storage

### Cross-Platform (ERROR severity)

- ❌ Session token exposure in transit
- ❌ Authentication bypass vulnerabilities
- ❌ Insecure communication channels
- ❌ API credential leakage

---

## Secure AI Coding Workflow

```
1. Request: "Add WebSocket authentication"
2. AI generates Swift + React Native code
3. ⚠️ STOP - Scan both platforms:
   - semgrep_scan: Swift files
   - semgrep_scan: TypeScript/TSX files
4. Review findings: Fix all ERROR severity issues
5. Re-scan to verify fixes
6. ✅ Commit only when clean (no ERROR findings)
```

---

## Project-Specific Custom Rules

### Example: Prevent Hardcoded WebSocket URLs

```yaml
rules:
  - id: hardcoded-websocket-url
    pattern: let wsURL = "ws://..."
    languages: [swift, typescript]
    severity: ERROR
    message: Never hardcode WebSocket URLs - use configuration
    metadata:
      fix: Use environment variables or configuration file
```

### Example: Validate WebSocket Messages

```yaml
rules:
  - id: unvalidated-websocket-message
    pattern: |
      ws.onmessage = (event) => {
        ...
        eval(event.data)
      }
    languages: [typescript, javascript]
    severity: ERROR
    message: Never execute WebSocket data without validation
```

---

## Agent Deck Security Checklist

### Swift Menubar App

- [ ] Validate all WebSocket messages before processing
- [ ] Use Keychain for session token storage
- [ ] Implement proper URL scheme validation
- [ ] Sanitize clipboard/pasteboard content
- [ ] Validate all file paths
- [ ] Implement request signing for API calls

### React Native Mobile

- [ ] Use SecureStore for sensitive data (not AsyncStorage)
- [ ] Validate all WebSocket messages before processing
- [ ] Sanitize all user input
- [ ] Implement deep link validation
- [ ] Use HTTPS for all network requests
- [ ] Implement certificate pinning for production
- [ ] Validate QR code scanner input

### Cross-Platform

- [ ] Encrypt sensitive data in transit
- [ ] Implement proper session management
- [ ] Validate authentication on both platforms
- [ ] Test offline/online state transitions
- [ ] Audit all communication channels

---

## Quick Reference

| Scenario | Semgrep Command |
|----------|-----------------|
| Scan Swift auth code | `semgrep_scan: apps/macos/*/Sources/Auth/*.swift` |
| Scan React Native code | `semgrep_scan: apps/mobile/src/**/*.{ts,tsx}` |
| Check WebSocket code | `semgrep_scan: */services/*WebSocket*` |
| Scan shared types | `semgrep_scan: packages/shared-types/src/**/*.ts` |
| Supply chain (mobile) | `cd apps/mobile && semgrep_scan_supply_chain` |
| Custom rule | `semgrep_scan_with_custom_rule` |

---

## Additional Resources

- **[MCP_INTEGRATION.md](./MCP_INTEGRATION.md)** - MCP server usage including Semgrep
- **[CLAUDE.md](../../CLAUDE.md)** - Main project guide
- **Workspace CLAUDE.md** - Comprehensive Semgrep MCP documentation
- **[Semgrep Docs](https://semgrep.dev/docs/)** - Official Semgrep documentation

---

**Version**: 1.0
**Extracted from**: CLAUDE.md (Agent Deck project)
**Last Updated**: 2025-01-24
