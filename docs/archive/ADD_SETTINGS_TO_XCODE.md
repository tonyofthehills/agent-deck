# Add SettingsView.swift to Xcode Project

**IMPORTANT:** Follow these steps to complete the Settings window integration

---

## Quick Steps

1. **Open Xcode project:**
   ```bash
   open /Users/tonyofthehills/dev/apps/app-009-agent-deck/Agent-Deck/Agent-Deck.xcodeproj
   ```

2. **Add SettingsView.swift to project:**
   - Right-click "Views" folder in Project Navigator
   - Select "Add Files to 'Agent-Deck'..."
   - Navigate to: `Agent-Deck/Agent-Deck/Views/SettingsView.swift`
   - **UNCHECK** "Copy items if needed" (file already in place)
   - **CHECK** "Agent-Deck" target
   - Click "Add"

3. **Build the project:**
   - Press Cmd+B or Product → Build
   - Should compile with no errors

4. **Run the app:**
   - Press Cmd+R or Product → Run
   - Click menubar icon → Settings
   - Verify Settings window opens

---

## Verification Checklist

### Build
- [ ] Project builds without errors
- [ ] No Yams import errors (dependency already configured)
- [ ] All 4 tabs compile correctly

### Runtime
- [ ] Settings button in menubar opens Settings window
- [ ] Settings window shows 4 tabs (General, Agents, Mobile, About)
- [ ] General tab: port field and auto-start toggle visible
- [ ] Agents tab: agent list loads and displays
- [ ] Mobile tab: QR code displays
- [ ] About tab: version number displays

---

## Alternative: Automatic Detection

Xcode may auto-detect the file. If so:
1. Simply build the project (Cmd+B)
2. Xcode will discover SettingsView.swift
3. Check Project Navigator to confirm file appears under Views/

---

## Troubleshooting

### "Cannot find 'SettingsView' in scope"
- SettingsView.swift not added to Xcode project
- Follow "Add SettingsView.swift" steps above

### "No such module 'Yams'"
- Should NOT happen (Yams already in Package Dependencies)
- If it does: File → Add Packages → Search "Yams" → Add Package

### Settings window doesn't open
- Check MenuBarView.swift has `@State private var showSettings = false`
- Check button action is `showSettings = true`
- Check `.sheet(isPresented: $showSettings) { SettingsView() }` present

---

## Files Affected

**Created:**
- `/Agent-Deck/Agent-Deck/Views/SettingsView.swift` (451 lines)

**Modified:**
- `/Agent-Deck/Agent-Deck/Views/MenuBarView.swift` (+3 lines)
- `/Agent-Deck/Agent-Deck/Agent_DeckApp.swift` (+2 lines)

---

**Ready to build and test!** 🚀
