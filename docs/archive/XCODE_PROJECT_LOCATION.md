# Xcode Project Location - IMPORTANT

## ⚠️ Use the CORRECT Xcode Project Location

After the monorepo migration, there are TWO Xcode project files. **You MUST use the one inside `apps/macos/`.**

### ✅ CORRECT Location (USE THIS ONE)

```bash
/Users/tonyofthehills/dev/apps/app-009-agent-deck/apps/macos/Agent-Deck/Agent-Deck.xcodeproj
```

**Open it with:**
```bash
cd /Users/tonyofthehills/dev/apps/app-009-agent-deck
open apps/macos/Agent-Deck/Agent-Deck.xcodeproj
```

### ❌ OLD Location (DO NOT USE)

```bash
/Users/tonyofthehills/dev/apps/app-009-agent-deck/Agent-Deck/Agent-Deck.xcodeproj
```

This is a leftover from before the monorepo migration. It will have path errors.

---

## Quick Start Commands

### macOS App (Swift)
```bash
# Open Xcode project
open apps/macos/Agent-Deck/Agent-Deck.xcodeproj

# Or build from command line
cd apps/macos
xcodebuild -project Agent-Deck/Agent-Deck.xcodeproj -scheme Agent-Deck
```

### Mobile App (React Native)
```bash
# Start Expo dev server
pnpm mobile

# Or with specific filter
pnpm -F @agent-deck/mobile start
```

---

## Monorepo Structure

```
app-009-agent-deck/
├── apps/
│   ├── macos/                    ← Swift menubar app
│   │   └── Agent-Deck/
│   │       ├── Agent-Deck.xcodeproj  ← ✅ USE THIS
│   │       ├── Agent-Deck.entitlements
│   │       └── ...
│   └── mobile/                   ← React Native mobile app
│       ├── App.tsx
│       └── package.json
├── packages/
│   └── shared-types/             ← Shared TypeScript types
├── Agent-Deck/                   ← ❌ OLD LOCATION (ignore)
│   └── Agent-Deck.xcodeproj      ← ❌ DO NOT USE
├── pnpm-workspace.yaml
└── package.json
```

---

## If You Accidentally Opened the Old Project

1. **Close Xcode completely** (Cmd+Q)
2. **Delete derived data** (optional but recommended):
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Agent-Deck-*
   ```
3. **Open the correct project**:
   ```bash
   open apps/macos/Agent-Deck/Agent-Deck.xcodeproj
   ```

---

## File Paths Inside Xcode

When you open the correct project at `apps/macos/Agent-Deck/Agent-Deck.xcodeproj`, all paths are relative to the `apps/macos/Agent-Deck/` directory:

- Entitlements: `Agent-Deck.entitlements` ✅
- Swift files: `Sources/` ✅
- Resources: `Resources/` ✅
- Info.plist: `Info.plist` ✅

All paths should work correctly without errors.

---

**Last Updated:** 2025-01-08
**Monorepo Migration:** Complete
