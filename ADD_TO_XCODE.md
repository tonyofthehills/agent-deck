# Add WindowManager.swift to Xcode Project

**IMPORTANT**: Before building, you must add the newly created WindowManager.swift file to the Xcode project.

---

## Quick Steps

1. Open Xcode project:
   ```bash
   open /Users/tonyofthehills/dev/apps/app-009-agent-deck/Agent-Deck/Agent-Deck.xcodeproj
   ```

2. In Xcode Project Navigator (left sidebar):
   - Expand **Agent-Deck** group
   - Find **Services** folder
   - Right-click on **Services**
   - Choose **"Add Files to 'Agent-Deck'..."**

3. In the file picker:
   - Navigate to: `Agent-Deck/Agent-Deck/Services/`
   - Select **WindowManager.swift**
   - **UNCHECK** "Copy items if needed" (file is already in the right location)
   - **CHECK** your app target under "Add to targets"
   - Click **"Add"**

4. Verify:
   - WindowManager.swift should now appear in the Services folder in Xcode
   - Build the project (Command+B) - should compile without errors

---

## Alternative: Command Line (if using xcodebuild)

If you prefer command line, you can manually edit the project.pbxproj file, but it's easier to use Xcode GUI for a single file.

---

## After Adding

Build and run the app:
1. Press **Command+R** in Xcode
2. Grant Accessibility permissions when prompted (or manually via System Preferences)
3. Test window switching from mobile PWA

---

## Troubleshooting

**"WindowManager.swift not found"**
- Ensure file exists at: `Agent-Deck/Agent-Deck/Services/WindowManager.swift`
- Re-add using steps above

**"Duplicate symbol errors"**
- File may be added twice - remove one reference in Xcode

**"Target membership not set"**
- Select WindowManager.swift in Xcode
- Open File Inspector (right sidebar)
- Check the box next to your app target under "Target Membership"
