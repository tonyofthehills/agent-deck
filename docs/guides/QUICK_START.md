# Quick Start Guide

**Agent Deck - Get started in 5 minutes**

Fast setup guide for running Agent Deck on your Mac and mobile device.

**Last Updated**: 2025-12-10

---

## Prerequisites

- macOS 12+ (Monterey or later)
- Xcode 14+
- Node.js 18+
- pnpm 8+ (or use `corepack enable`)
- iOS/Android device with Expo Go app (for mobile testing)

---

## First-Time Setup

### 1. Install Dependencies

```bash
# Install pnpm (if not already installed)
npm install -g pnpm

# Or use Corepack (Node.js 16.13+)
corepack enable
corepack prepare pnpm@latest --activate

# Install all dependencies (root + workspaces)
cd /path/to/agent-deck
pnpm install
```

**Expected result**: 619+ packages installed

---

### 2. Open Mac App in Xcode

```bash
cd apps/macos/Agent-Deck
open AgentDeck.xcodeproj
```

**In Xcode:**
1. Select "AgentDeck" scheme
2. Click Run (⌘R) or Product → Run
3. App appears in menubar (top right)
4. Grant Accessibility permissions if prompted

---

### 3. Start Mobile App

```bash
# From project root
pnpm mobile

# Or run on specific platform
pnpm mobile:ios      # iOS simulator
pnpm mobile:android  # Android emulator
```

**Expected result**: Expo dev server starts, QR code displayed

---

## Running the System

### Start Mac App (Terminal-Free)

1. Open `apps/macos/Agent-Deck/AgentDeck.xcodeproj` in Xcode
2. Click Run (⌘R)
3. App runs in menubar

**Status check:**
- ✅ Menubar icon visible
- ✅ Dropdown shows agent list
- ✅ QR code visible in settings

---

### Start Mobile App

**Option 1: Physical Device (Recommended)**

```bash
pnpm mobile
```

1. Install Expo Go from App Store (iOS) or Play Store (Android)
2. Scan QR code with Expo Go app
3. App loads on device

**Option 2: Simulator**

```bash
# iOS
pnpm mobile:ios

# Android
pnpm mobile:android
```

---

## Testing the Connection

### Step 1: Start Mac App
- Mac app running in menubar ✓
- WebSocket server on port 3000 ✓

### Step 2: Pair Mobile App
1. Mobile app loaded (via Expo Go or simulator)
2. Tap "Scan QR Code" button
3. Scan QR code from Mac app settings
4. OR manually enter WebSocket URL: `ws://192.168.x.x:3000`

### Step 3: Verify Connection
- ✅ Mobile app shows "Connected" status (green)
- ✅ Agent list displays running Claude Code instances
- ✅ Tapping agent card switches window on Mac

---

## Common Commands

### Monorepo Management

```bash
# Install all dependencies
pnpm install

# Add dependency to mobile app
pnpm --filter mobile add <package-name>

# Type check all packages
pnpm typecheck

# Type check mobile only
pnpm --filter mobile typecheck
```

### Mobile Development

```bash
# Start Expo dev server
pnpm mobile

# Run on iOS simulator
pnpm mobile:ios

# Run on Android emulator
pnpm mobile:android

# Clear cache
pnpm mobile -- --clear
```

### Xcode (Mac App)

```bash
# Open project
cd apps/macos/Agent-Deck && open AgentDeck.xcodeproj

# Build from command line
xcodebuild -project AgentDeck.xcodeproj -scheme AgentDeck build

# View logs
log stream --predicate 'subsystem == "com.agentdeck.app"'
```

---

## Troubleshooting

### "Cannot connect to Mac app"

**Check:**
1. Mac app running? (menubar icon visible)
2. Same WiFi network? (Mac and mobile device)
3. Firewall blocking port 3000?
4. WebSocket URL correct? (`ws://192.168.x.x:3000`)

**Fix:**
```bash
# Check Mac app is listening
lsof -i :3000

# Get Mac IP address
ifconfig en0 | grep "inet "
```

---

### "pnpm command not found"

```bash
# Install pnpm
npm install -g pnpm

# Or use Corepack
corepack enable
```

---

### "Expo Go won't connect"

1. Restart Expo dev server: `pnpm mobile`
2. Clear Expo cache: `pnpm mobile -- --clear`
3. Check firewall settings
4. Try entering URL manually in Expo Go

---

### "Accessibility permission denied"

**Mac App needs Accessibility permissions for window switching**

1. Open System Settings → Privacy & Security → Accessibility
2. Add Agent Deck to allowed apps
3. Toggle permission on
4. Restart Agent Deck app

---

## Next Steps

✅ **System running?** Great! Now explore:

1. **[REACT_NATIVE_GUIDE.md](./REACT_NATIVE_GUIDE.md)** - Mobile development patterns
2. **[SWIFT_GUIDE.md](./SWIFT_GUIDE.md)** - Mac app development
3. **[MCP_INTEGRATION.md](./MCP_INTEGRATION.md)** - Using MCP servers
4. **[SECURITY.md](./SECURITY.md)** - Security scanning guide
5. **[TESTING_GUIDE.md](./TESTING_GUIDE.md)** - Testing procedures

---

## Development Workflow

### Working on Mobile Features

```bash
# Start mobile dev server (hot reload enabled)
pnpm mobile

# Make changes to files in apps/mobile/src/
# Changes automatically reload on device

# Add new dependency
pnpm --filter mobile add <package>

# Type check
pnpm --filter mobile typecheck
```

### Working on Mac Features

1. Open Xcode project
2. Edit Swift files in `apps/macos/Agent-Deck/`
3. Build & run (⌘R)
4. Check logs in Console.app

### Working on Shared Types

```bash
# Edit files in packages/shared-types/src/

# Build types
pnpm --filter @agent-deck/shared-types build

# Types automatically available in mobile app
```

---

## SpecKit Workflow

**Spec-driven development workflow:**

```bash
# 1. Define principles
/speckit.constitution

# 2. Create spec
/speckit.specify

# 3. Generate plan
/speckit.plan

# 4. Break into tasks
/speckit.tasks

# 5. Implement
/speckit.implement [task-name]
```

---

## Related Documentation

- **[CLAUDE.md](../../CLAUDE.md)** - Comprehensive project guide
- **[README.md](../../README.md)** - Project overview
- **[TEST_CHECKLIST.md](./TEST_CHECKLIST.md)** - Manual testing procedures
- **[RELEASE_NOTES.md](../release/RELEASE_NOTES.md)** - v0.1.0 MVP release notes

---

**Version**: 1.1
**Created**: 2025-01-24
**Updated**: 2025-12-10
**Estimated Setup Time**: 10-15 minutes
