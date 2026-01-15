# Feedback Collection Setup

This document explains how to set up GitHub Issue templates and collect user feedback for Agent Deck.

---

## Overview

Agent Deck uses GitHub Issues as the primary feedback mechanism. This provides:
- ✅ Public visibility (other users can +1 features they want)
- ✅ Discussion threads (users can collaborate on solutions)
- ✅ Prioritization (sort by reactions, comments)
- ✅ Integration with project board (track feature development)

---

## GitHub Issue Templates

Create two issue templates in `.github/ISSUE_TEMPLATE/`:

1. **Bug Report** - For reporting issues
2. **Feature Request** - For suggesting improvements

### How to Set Up

```bash
cd /Users/tonyofthehills/dev/apps/app-009-agent-deck

# Create .github directory structure
mkdir -p .github/ISSUE_TEMPLATE

# Templates will be created below
```

---

## Template 1: Bug Report

**File:** `.github/ISSUE_TEMPLATE/bug_report.md`

**Purpose:** Collect structured information about bugs to speed up diagnosis and fixing.

**Contents:** (See file creation below)

---

## Template 2: Feature Request

**File:** `.github/ISSUE_TEMPLATE/feature_request.md`

**Purpose:** Understand user needs and prioritize roadmap based on demand.

**Contents:** (See file creation below)

---

## Additional Feedback Channels

### GitHub Discussions (Optional but Recommended)

**Enable in repository settings:**
- Settings → Features → Discussions: ON

**Categories:**
- 💡 **Ideas** - Brainstorming and feature concepts
- 🙋 **Q&A** - User questions and support
- 📣 **Announcements** - Release notes, major updates
- 🐛 **Bugs** - Redirect to Issues, but allow initial discussion
- 🎨 **Show and Tell** - Users share their workflows/setups

**Benefits:**
- Less formal than Issues (encourages exploration)
- Good for open-ended questions ("What agents do you want supported?")
- Community can help each other (reduces maintainer burden)

---

## Feedback Collection Strategy

### Week 1-2 (Launch)
**Focus:** Validate core use case

**Key questions:**
1. Does monitoring work reliably?
2. Is window switching useful?
3. Is PWA acceptable or do users want native mobile?
4. What agents do users want to monitor?

**Feedback channels:**
- Show HN comments
- GitHub Issues
- Direct messages (Twitter, email)

**Metrics to track:**
- GitHub Stars (interest level)
- Issue creation rate (engagement)
- Common feature requests (prioritization)

---

### Week 3-4 (Post-Launch)
**Focus:** Prioritize Phase 2 features

**Key questions:**
1. Which agent support is most important? (Cursor, Windsurf, Aider)
2. What custom actions do users want? (Run tests, open apps, bash scripts)
3. Do users run multiple agent instances?
4. How do users want to authenticate? (password, API key, none)

**Feedback channels:**
- GitHub Discussions (poll users)
- Feature request issues (track votes via reactions)

**Metrics to track:**
- Most upvoted feature requests (+1 reactions)
- Most commented issues (controversial or high-interest)
- GitHub traffic (downloads, clones)

---

### Month 2-3 (Iteration)
**Focus:** Native mobile app decision

**Key questions:**
1. Is PWA sufficient or do users want native iOS?
2. What's missing from PWA experience?
3. Would users pay for native apps?
4. Android demand vs iOS demand?

**Feedback channels:**
- User interviews (reach out to active users)
- Feature request: "Native iOS app" (count reactions)
- Twitter poll (if following exists)

**Metrics to track:**
- PWA installation rate (how many "Add to Home Screen"?)
- Mobile browser diversity (iOS Safari vs Android Chrome)
- Feature request votes (native vs more features)

---

## Roadmap Transparency

### Public Roadmap

**Create:** `ROADMAP.md` in repository root

**Structure:**
```markdown
# Agent Deck Roadmap

**Last updated:** 2025-01-06

## Shipped ✅
- v0.1.0 (MVP) - Real-time monitoring, window switching, PWA

## In Progress 🚧
- Phase 2: Cursor/Windsurf support
- Custom actions (bash scripts, app launching)

## Planned 📋
- Phase 3: Native iOS app (if 100+ users request)
- Authentication layer
- Multiple agent instances

## Exploring 💡
- Mobile approval/rejection of agent actions
- Agent interaction (pause, resume, send input)
- Integrations (Slack, webhooks)

## Won't Do ❌
- Windows support (not enough demand)
- Cloud-hosted version (local-first is core principle)
```

**Benefits:**
- Sets expectations (users know what's coming)
- Reduces duplicate feature requests
- Shows active development
- Invites feedback on priorities

---

## User Interviews (Optional but Valuable)

**When:** After 10-20 active users

**Format:**
1. 30-minute video call (Zoom, Google Meet)
2. Screen share (watch them use Agent Deck)
3. Open-ended questions (see below)

**Questions to Ask:**
- What problem were you trying to solve when you found Agent Deck?
- How does Agent Deck fit into your workflow?
- What's the most valuable feature? What's least valuable?
- What's missing that would make you use it more?
- Would you recommend Agent Deck to a colleague? Why or why not?

**Incentive:**
- Feature their workflow in docs (if they consent)
- Early access to new features
- Or just: "Help shape the future of Agent Deck"

---

## Metrics Dashboard (Optional)

**If using analytics, track:**
- **GitHub:**
  - Stars per week
  - Forks (developers interested in contributing)
  - Issues opened/closed
  - Pull requests (community contributions)

- **App usage** (if instrumented):
  - Active users (unique IPs connecting to WebSocket)
  - Sessions per user (how often they use it)
  - Average session duration
  - Features used (window switching, custom actions)

- **PWA adoption:**
  - "Add to Home Screen" rate
  - Mobile OS breakdown (iOS vs Android)
  - Browser diversity

**Tools:**
- GitHub Insights (built-in)
- Simple server logs (WebSocket connection count)
- Google Analytics (for GitHub Pages docs site)

---

## Community Building (Future)

**If Agent Deck gains traction:**

### Discord Server (Month 3+)
- Faster feedback loop than GitHub
- Real-time support
- Community can help each other
- Beta testing channel

### Twitter/X Presence
- Share user workflows ("Look what @user built with Agent Deck")
- Release announcements
- Engage with AI coding community

### Blog/Newsletter (Month 6+)
- Deep dives on features
- User spotlights
- Roadmap updates
- Technical architecture posts

---

## Templates Ready to Create

The following files should be created in the repository:

1. `.github/ISSUE_TEMPLATE/bug_report.md`
2. `.github/ISSUE_TEMPLATE/feature_request.md`
3. `ROADMAP.md` (optional but recommended)

**Contents provided below.**

---

**End of guide. Now creating issue templates...**
