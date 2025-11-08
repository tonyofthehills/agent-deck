# Show HN: Agent Deck – Stream Deck for AI Coding Agents

**[Demo GIF goes here - see DEMO_GIF_INSTRUCTIONS.md]**

## The Problem

When you're running agentic coding tools like Claude Code or Cursor, you're stuck at your desk constantly checking: Has my agent finished? Did it hit an error? What task is it working on now? You can't grab coffee without wondering if you've missed something important.

And if you're running multiple agents across different projects? Forget about it. You need eyes on three different terminal windows.

## The Solution

**Agent Deck** is like a Stream Deck for AI coding agents. It's a Mac menubar app that monitors your running agents (Claude Code, Cursor, etc.) and streams real-time status to your phone via a Progressive Web App.

One tap switches focus between agent windows. No more Alt-Tabbing through 20 windows to find the right terminal.

**Key features:**
- 🔍 **Real-time monitoring** - See what your agents are doing (current task, todos, git branch, model)
- 📱 **Phone control** - Tap an agent card to instantly switch to that window on your Mac
- 🌐 **Progressive Web App** - Works on any phone (iOS, Android, iPad) - no app store needed
- 🔒 **Fully local** - Everything stays on your WiFi network, zero cloud dependencies
- ⚡ **60-second setup** - Scan QR code, add to home screen, done

## How It Works

**Mac App (Swift/SwiftUI):**
- Menubar app runs in the background (< 2% CPU, < 100MB RAM)
- Monitors running Claude Code instances using FSEvents (watches transcript files)
- Parses agent output in real-time (current task, todos, git branch, model name, subagents)
- Embedded WebSocket server broadcasts updates to your phone
- AppleScript integration for instant window switching

**Mobile PWA (Vanilla JS):**
- Connects to Mac via local WebSocket (ws://your-mac-ip:3000)
- Dark mode, touch-optimized interface
- Expandable sections for detailed agent info
- Tap any agent card → Mac switches to that window instantly
- Installable on home screen (looks/feels like a native app)

**Why Local-First:**
- No cloud means no subscription, no privacy concerns, no latency
- Your code never leaves your machine
- Works offline (as long as you're on same WiFi)

## Built With

- **Mac**: Swift 5.7+, SwiftUI, FSEvents, Combine, Network.framework
- **Mobile**: Progressive Web App (vanilla JavaScript - no framework bloat)
- **Architecture**: Local network only, WebSocket protocol, zero dependencies for end users

## Current Status

**MVP is complete** - monitoring works, window switching works, PWA installs on mobile.

**Limitations:**
- macOS only (Mac app required to run the server)
- Claude Code support only (Cursor/Windsurf coming in Phase 2)
- Local network only (same WiFi required)
- No authentication (assumes trusted local network)

## Try It

**Download:** [GitHub Releases] (Coming in next 48 hours)

**Requirements:**
- macOS 12+ (Monterey or later)
- WiFi network
- Claude Code installed and running
- iPhone/Android with modern browser

**Installation:**
1. Download Agent-Deck.app
2. Move to Applications folder
3. Launch Agent Deck (grant accessibility permissions when prompted)
4. Scan QR code from menubar with your phone
5. Tap "Add to Home Screen" in Safari/Chrome
6. Done!

## Roadmap

**Phase 1 (MVP) - ✅ Complete:**
- Real-time monitoring with rich data parsing
- Window switching from mobile
- PWA mobile interface

**Phase 2 (Next 2-4 weeks):**
- Cursor and Windsurf support
- Custom actions (run bash scripts, open apps)
- Multiple agent instance support

**Phase 3 (Month 2-3):**
- Native iOS app (if 100+ users demand it)
- Enhanced parsing (approval prompts, file diffs)
- Configuration UI

**Future Ideas:**
- Mobile approval/rejection of agent actions
- Agent interaction (pause, resume, send commands)
- Integrations (Slack notifications, webhooks)

## Why I Built This

I kept finding myself glued to my desk, babysitting Claude Code sessions. I wanted to grab coffee without losing track of what my agents were doing. Stream Deck seemed like the perfect UX analogy - a dashboard of actions at your fingertips.

I started with a native iOS app, then realized: why force users to wait for App Store approval when a PWA works on every device instantly? Ship fast, validate, then polish.

## Feedback Welcome

This is an MVP built in 2 weeks. I'm shipping early to learn what developers actually want.

**Questions I'm curious about:**
- Would you use this? What's missing?
- What agents do you want to monitor? (Cursor, Windsurf, Aider, others?)
- What actions would you want on your "Stream Deck"? (Open Figma, run tests, open docs?)
- Should I prioritize native iOS app or focus on more features?

**Report bugs/request features:**
https://github.com/tonyofthehills/agent-deck/issues

**GitHub:**
https://github.com/tonyofthehills/agent-deck

---

**Open Source:** MIT License
**Built by:** [@tonyofthehills](https://github.com/tonyofthehills)
