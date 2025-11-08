# Demo GIF/Video Creation Guide

This guide walks you through creating a compelling demo GIF or video for Agent Deck that showcases the key features and "wow" moments.

---

## Tools Needed

### Recording
- **QuickTime Player** (Mac screen recording) - Built-in
- **iPhone/Android** (mobile capture) - Your phone
- **Optional:** External camera to show both Mac and phone simultaneously

### Post-Processing
- **Gifski** (best GIF converter for Mac) - https://gif.ski/
  ```bash
  brew install --cask gifski
  ```
- **Alternative:** FFmpeg (command line)
  ```bash
  brew install ffmpeg
  ```
- **Video editing:** iMovie (basic cuts) or DaVinci Resolve (advanced)

---

## Target Specs

**For Show HN Post:**
- **Duration:** 20-30 seconds (maximum attention span)
- **Format:** GIF or MP4
- **Size:** < 10MB for GIF, < 25MB for video
- **Resolution:** 1080p (1920x1080) or 720p (1280x720)
- **Frame rate:** 15-30 fps (15 fps is fine for GIFs)

**For GitHub README:**
- Same as above, but can be 2-3 separate GIFs showing different features
- Each GIF: 5-15 seconds, < 5MB

---

## Scenes to Capture

### Scene 1: Mac Setup (5 seconds)
**What to show:**
- Clean desktop (close unnecessary windows)
- Agent Deck icon in menubar (top right)
- Click menubar icon → dropdown appears
- Show QR code prominently

**Recording tips:**
- Use QuickTime: File → New Screen Recording
- Record full screen or just menubar area
- Keep mouse movements smooth and deliberate
- Highlight cursor (System Preferences → Accessibility → Display → Cursor → Shake to locate)

**Voiceover/Text overlay:** "Install Agent Deck on Mac"

---

### Scene 2: Mobile Connection (10 seconds)
**What to show:**
- iPhone/Android opens camera
- Scan QR code from menubar
- Safari/Chrome opens Agent Deck PWA
- Show mobile interface loading
- Tap "Add to Home Screen"
- Show home screen with Agent Deck icon

**Recording tips:**
- Use iPhone screen recording: Settings → Control Center → Screen Recording
- OR use external camera to show phone scanning QR
- Show both Mac and phone in frame (if using external camera)

**Voiceover/Text overlay:** "Scan QR code → Add to home screen"

---

### Scene 3: Window Switching (5 seconds)
**What to show:**
- Split screen: Mac on left, phone on right (picture-in-picture)
- Mac has multiple windows open (Code editor, Terminal with Claude Code, Browser, etc.)
- Phone shows Agent Deck with multiple agent cards
- Finger taps an agent card on phone
- **Instant cut:** Mac switches to that Claude Code window (show focus change)

**Recording tips:**
- This is the "wow" moment - make it snappy
- Use picture-in-picture or side-by-side layout
- Emphasize the instant response (< 500ms)
- Show Mac window changing focus clearly

**Voiceover/Text overlay:** "Tap to switch windows instantly"

---

### Scene 4: Real-Time Monitoring (10 seconds)
**What to show:**
- Phone screen showing Agent Deck PWA
- Claude Code working in background (Mac visible in corner)
- Agent card shows:
  - Status changing (idle → working → done)
  - Current task text updating
  - Todo list items getting checked off
  - Git branch displayed
  - Model name visible
- Expand sections to show rich data

**Recording tips:**
- Use iPhone screen recording for mobile focus
- Show smooth animations as data updates
- Tap expandable sections to reveal todos, model info, etc.

**Voiceover/Text overlay:** "Monitor agents in real-time from anywhere"

---

## Optional Scenes (Extended Demo)

### Scene 5: Multiple Agents (5 seconds)
- Show 2-3 Claude Code instances running different tasks
- Mobile shows all agents in list
- Quickly tap between different agents
- Mac windows switch accordingly

### Scene 6: Settings/QR Code (3 seconds)
- Click menubar → Settings
- Show clean settings UI
- Click "Show QR Code" button

---

## Recording Workflow

### Step 1: Prepare Environment

**Mac:**
- Clean desktop (hide desktop icons, close unnecessary apps)
- Set desktop wallpaper to solid color or minimal pattern
- Turn off notifications (Do Not Disturb mode)
- Set menubar to show Agent Deck icon prominently
- Open relevant apps: Xcode/Terminal with Claude Code, VS Code, Browser

**Phone:**
- Clear notifications
- Set brightness to max
- Portrait mode
- Clean home screen (move Agent Deck icon to prominent position)

---

### Step 2: Record Individual Scenes

**Mac Screen Recording (QuickTime):**
```bash
# Open QuickTime Player
# File → New Screen Recording
# Click to record full screen or drag to select area
# Click menubar icon, perform actions
# Click stop recording in menubar
# File → Save
```

**iPhone Screen Recording:**
- Control Center → Screen Recording button
- 3-second countdown
- Perform actions on Agent Deck PWA
- Stop recording from status bar

**External Camera (Optional):**
- Use iPhone/DSLR to record both Mac and phone
- Position camera overhead or at angle showing both screens
- Ensure good lighting (natural light or ring light)

---

### Step 3: Edit and Combine

**Using iMovie (Simple):**
1. Import all clips
2. Arrange in timeline: Setup → Connect → Switch → Monitor
3. Trim to remove dead space
4. Add text overlays for each scene
5. Add smooth transitions (fade, cut)
6. Export as 1080p MP4

**Using FFmpeg (Advanced):**
```bash
# Convert video to GIF with Gifski (best quality)
gifski --fps 15 --quality 90 --width 1080 input.mp4 -o output.gif

# Alternative: FFmpeg conversion
ffmpeg -i input.mp4 -vf "fps=15,scale=1080:-1:flags=lanczos" -c:v gif output.gif

# Optimize GIF size
ffmpeg -i output.gif -vf "scale=720:-1:flags=lanczos" -c:v gif output-small.gif
```

---

### Step 4: Add Finishing Touches

**Text Overlays (Optional but Recommended):**
- Scene 1: "1. Install Mac app"
- Scene 2: "2. Scan QR code"
- Scene 3: "3. Tap to switch windows"
- Scene 4: "4. Monitor in real-time"

**Sound:**
- For GIF: No sound needed
- For MP4: Add background music (royalty-free from YouTube Audio Library)
- Keep music subtle, instrumental preferred

**Branding:**
- Add "Agent Deck" text in corner (subtle, not distracting)
- Optional: Add URL "agent-deck.dev" at end

---

## Alternative: Side-by-Side Layout

**Best for showing Mac + Phone simultaneously:**

1. Record Mac screen (1920x1080)
2. Record iPhone screen (1170x2532)
3. Edit in iMovie/DaVinci:
   - Mac video on left (75% width)
   - iPhone video on right (25% width, portrait)
   - Sync actions (tap on phone → window switch on Mac)

**FFmpeg command for side-by-side:**
```bash
ffmpeg -i mac.mp4 -i iphone.mp4 -filter_complex \
  "[0:v]scale=1440:1080[left]; \
   [1:v]scale=480:1080[right]; \
   [left][right]hstack=inputs=2" \
  -c:v libx264 -crf 23 output.mp4
```

---

## Quick Version (30-Second All-in-One)

**Timeline:**
- 0:00-0:05 - Open Agent Deck menubar, show QR code
- 0:05-0:10 - Phone scans QR, PWA loads
- 0:10-0:15 - Tap agent card on phone
- 0:15-0:20 - Mac window switches instantly
- 0:20-0:30 - Show real-time updates on mobile (expanded sections)

**Text overlays:**
- "Agent Deck - Stream Deck for AI Agents"
- "Monitor Claude Code from your phone"
- "One-tap window switching"
- "github.com/tonyofthehills/agent-deck"

---

## Example GIF Specifications

### Hero GIF (README/Show HN)
- **Duration:** 25 seconds
- **Resolution:** 1080x720 (wide format)
- **Size:** < 8MB
- **Content:** All 4 scenes in sequence

### Feature GIF 1 (Window Switching)
- **Duration:** 5 seconds (loop)
- **Resolution:** 800x600
- **Size:** < 3MB
- **Content:** Just Scene 3 (tap → switch)

### Feature GIF 2 (Real-Time Updates)
- **Duration:** 10 seconds (loop)
- **Resolution:** 600x1200 (portrait, mobile-focused)
- **Size:** < 5MB
- **Content:** Just Scene 4 (mobile monitoring)

---

## Tips for Best Results

**✅ DO:**
- Use natural, smooth mouse movements
- Pause briefly (1 second) between actions
- Keep UI elements visible and in focus
- Show real Claude Code output (demonstrates actual use)
- Use dark mode (looks professional, easier on eyes)
- Loop key actions (GIF loops automatically)

**❌ DON'T:**
- Rush through steps (viewers need time to process)
- Include dead time (trim loading screens if > 2 seconds)
- Show personal information (code, file paths, etc.)
- Use shaky external camera footage (use tripod)
- Over-compress GIF (aim for quality, not smallest size)

---

## Example Scripts

### Script 1: External Camera (Showing Both Devices)

**Setup:**
- Camera overhead or at 45° angle
- Both Mac and phone in frame
- Good lighting

**Actions:**
1. Point at Mac menubar → click Agent Deck icon
2. Zoom in on QR code
3. Hand picks up phone → scans QR
4. Zoom in on phone screen → PWA loads
5. Finger taps agent card
6. Zoom out → show Mac window switching
7. Zoom back to phone → show real-time updates

**Duration:** 30 seconds

---

### Script 2: Split Screen (Screen Recordings Only)

**Setup:**
- Record Mac screen separately
- Record iPhone screen separately
- Combine in post with side-by-side layout

**Actions:**
1. Mac: Show Agent Deck menubar and QR code (5s)
2. iPhone: Open camera, scan QR, PWA loads (10s)
3. Side-by-side: Tap on iPhone → Mac switches window (5s)
4. iPhone: Show expanded agent details updating (10s)

**Duration:** 30 seconds

---

## Hosting and Distribution

**For GitHub README:**
- Upload GIF to GitHub repo: `docs/demo.gif`
- Reference in README: `![Demo](docs/demo.gif)`
- GitHub automatically serves and displays

**For Show HN:**
- Upload to Imgur: https://imgur.com/upload
- Use direct link in HN post
- Imgur GIFs autoplay on HN

**For Twitter/Social Media:**
- Twitter supports GIF/MP4 directly (drag and drop)
- LinkedIn prefers MP4 over GIF
- Keep under platform limits (Twitter: 512MB, 2:20 duration)

---

## Testing Your GIF

**Before publishing, test:**
- [ ] Loads quickly (< 3 seconds to first frame)
- [ ] Loops smoothly (no jarring cuts at loop point)
- [ ] Text overlays are readable (not too fast, not too small)
- [ ] Actions are clear (viewers understand what's happening)
- [ ] File size reasonable (< 10MB for upload speed)
- [ ] Displays correctly on mobile (test on phone browser)

**Test platforms:**
- GitHub (preview in README)
- Imgur (upload and view)
- Show HN (preview before posting)

---

## Example Timeline (QuickTime + iMovie)

**Total time to create:** ~1-2 hours

1. **Prepare environment** (10 min)
   - Clean desktop, open apps, test Agent Deck
2. **Record scenes** (30 min)
   - 3-5 takes per scene to get smooth actions
3. **Import and edit** (20 min)
   - Trim clips, arrange in iMovie, add transitions
4. **Add overlays** (10 min)
   - Text overlays, titles, optional music
5. **Export and convert** (10 min)
   - Export MP4 from iMovie → convert to GIF with Gifski
6. **Optimize and test** (10 min)
   - Check file size, test loop, upload to Imgur for preview

---

## Quick Start (Minimal Version)

**If you're short on time, do this:**

1. Record full 30-second walkthrough in one take (Mac screen only)
2. Use QuickTime screen recording
3. Convert to GIF with Gifski (drag and drop)
4. Done!

**Command:**
```bash
# Install Gifski
brew install --cask gifski

# Drag your QuickTime .mov file into Gifski
# Select quality: 90%
# Select dimensions: 1080px width
# Save as demo.gif
```

**Result:** One GIF ready for Show HN in < 30 minutes.

---

## Resources

**Recording:**
- QuickTime Player (built-in)
- iPhone Screen Recording (Settings → Control Center)

**GIF Conversion:**
- Gifski: https://gif.ski/ (best quality)
- FFmpeg: https://ffmpeg.org/ (command line)

**Video Editing:**
- iMovie (built-in, easy)
- DaVinci Resolve (free, advanced): https://www.blackmagicdesign.com/products/davinciresolve

**Royalty-Free Music:**
- YouTube Audio Library: https://www.youtube.com/audiolibrary/music
- Incompetech: https://incompetech.com/music/royalty-free/music.html

**Hosting:**
- Imgur: https://imgur.com/upload (GIFs)
- GitHub: `docs/` folder in repo (version control)

---

**Good luck! Remember: Keep it simple, focus on the "wow" moments, and ship it. You can always create a better version later.**
