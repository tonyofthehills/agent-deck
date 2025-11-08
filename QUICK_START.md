# Agent Deck - Quick Start Guide

## 🚀 Start the App (Next Session)

### 1. Launch from Xcode
```bash
open Agent-Deck.xcodeproj
# Press Cmd+R to run
```

### 2. OR Launch Built App
```bash
open -a ~/Library/Developer/Xcode/DerivedData/Agent-Deck-*/Build/Products/Debug/Agent-Deck.app
```

### 3. Open PWA in Browser
```bash
open http://localhost:3000/
```

---

## ✅ What's Working

- **Mac App:** Menubar icon, monitoring, servers running
- **HTTP Server:** Port 3000 serving PWA
- **WebSocket Server:** Port 3001 connected
- **PWA:** Displays agent instances, connection status
- **Agent Detection:** Finding Claude Code processes

---

## 🔧 If Something Breaks

### Servers Not Starting
```bash
# Check entitlements are applied
codesign -d --entitlements :- ~/Library/Developer/Xcode/DerivedData/Agent-Deck-*/Build/Products/Debug/Agent-Deck.app

# Should show:
# com.apple.security.network.server = true
# com.apple.security.network.client = true
# com.apple.security.app-sandbox = false
```

### Rebuild from Clean
```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData/Agent-Deck-*

# Rebuild
xcodebuild -project Agent-Deck.xcodeproj -scheme Agent-Deck -configuration Debug build
```

### Check if Servers Running
```bash
lsof -iTCP:3000,3001 -sTCP:LISTEN
```

---

## 🧪 Test Checklist

- [ ] Menubar icon appears
- [ ] PWA loads at localhost:3000
- [ ] Connection shows "Connected" (green dot)
- [ ] Agent cards display with working directory
- [ ] Tapping card sends focus command
- [ ] Browser console shows no errors

---

## 📝 Next Tasks (Phase 6+)

1. Test window focusing (tap agent card)
2. Test on mobile device (iPhone/Android)
3. Add service worker for offline support
4. Implement ProcessMonitor update broadcasts
5. Add more agent types (Cursor, Windsurf)

---

## 📁 Important Files

```
Agent-Deck/Agent-Deck.entitlements        # Network permissions - DON'T DELETE
Agent-Deck/AppDelegate.swift              # Servers start here (line 125)
Agent-Deck/Services/WebSocketServer.swift # WebSocket logic
Agent-Deck/Resources/WebRoot/app.js       # PWA client
~/.agent-deck/config.yaml                 # Runtime config
```

---

## 💡 Quick Reference

**View Logs:**
```bash
log show --predicate 'subsystem == "com.TheHillPack.Agent-Deck"' --last 1m
```

**Test HTTP:**
```bash
curl http://localhost:3000/ | head -10
```

**Test WebSocket:**
```bash
# Use browser console:
const ws = new WebSocket('ws://localhost:3001');
ws.onopen = () => console.log('Connected!');
ws.onmessage = (e) => console.log('Received:', JSON.parse(e.data));
```

**Kill App:**
```bash
pkill -9 -f "Agent-Deck.app"
```

---

**Status:** MVP COMPLETE AND WORKING ✅
**Last Session:** 2025-11-02
