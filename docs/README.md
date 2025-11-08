# Agent Deck Documentation Assets

This directory contains screenshots, demo GIFs, and other visual assets for documentation.

## Contents

### Demo Materials
- `demo.gif` - Hero demo GIF (Mac + mobile, 20-30s)
- `demo-window-switching.gif` - Window switching feature demo
- `demo-monitoring.gif` - Real-time monitoring feature demo

### Screenshots

**Mac App:**
- `screenshot-menubar.png` - Agent Deck menubar icon and dropdown
- `screenshot-qr-code.png` - QR code display for mobile pairing
- `screenshot-settings.png` - Settings window (when implemented)

**Mobile PWA:**
- `screenshot-mobile-home.png` - PWA home screen with agent cards
- `screenshot-mobile-expanded.png` - Agent card with expanded sections
- `screenshot-mobile-installing.png` - "Add to Home Screen" dialog

**Cross-Platform:**
- `screenshot-side-by-side.png` - Mac and mobile side by side

### Icons
- `icon-agent-deck.png` - App icon (various sizes)
- `icon-menubar.png` - Menubar icon (monochrome)

## Creating Assets

**Follow:** `../DEMO_GIF_INSTRUCTIONS.md` for detailed recording instructions

**Recommended Tools:**
- QuickTime Player (Mac screen recording)
- iPhone Screen Recording (mobile capture)
- Gifski (GIF conversion) - https://gif.ski/

**Specs:**
- **GIF:** < 10MB, 1080px width, 15-30 fps
- **Screenshots:** 2x resolution (Retina), PNG format
- **Naming:** Lowercase with hyphens, descriptive

## Usage in Documentation

**README.md:**
```markdown
![Demo](docs/demo.gif)
![Screenshot](docs/screenshot-mobile-home.png)
```

**Show HN Post:**
```markdown
![Demo](https://github.com/tonyofthehills/agent-deck/raw/main/docs/demo.gif)
```

**GitHub Release:**
- Upload `demo.gif` as release asset
- Reference in release notes

---

**Status:** Assets not yet created - see `../DEMO_GIF_INSTRUCTIONS.md` to create
