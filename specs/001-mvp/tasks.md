# Tasks: Agent Deck MVP (Phases 1-2)

**Input**: Design documents from `/specs/001-mvp/`
**Prerequisites**: plan.md (required), spec.md (required), data-model.md, contracts/websocket-protocol.md

**Tests**: Manual testing only in Phase 1-2 (per constitution). No automated test tasks generated.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Project structure:
- **Mac app**: `AgentDeck-Mac/Sources/` and `AgentDeck-Mac/Resources/`
- **PWA**: `AgentDeck-Mac/Resources/WebRoot/`
- **Config**: `AgentDeck-Mac/Resources/default-config.yaml`

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Project initialization and basic structure

- [x] T001 Create Xcode project AgentDeck-Mac in repository root
- [x] T002 Configure project settings: Bundle ID com.agentdeck.mac, macOS 12+ deployment target
- [x] T003 Edit Info.plist to add LSUIElement=true and NSAllowsLocalNetworking=true
- [x] T004 [P] Add Swift Package dependency: Yams (https://github.com/jpsim/Yams.git, version 5.0+)
- [x] T005 [P] Create folder structure: Sources/{Models,Services,Views,Utilities}, Resources/WebRoot
- [x] T006 [P] Create Resources/Assets.xcassets for app icons
- [x] T007 Create default YAML configuration template in Resources/default-config.yaml

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T008 [P] Create AgentInstance model in Sources/Models/AgentInstance.swift
- [x] T009 [P] Create AgentStatus enum in Sources/Models/AgentStatus.swift with values: idle, working, done, error
- [x] T010 [P] Create StatusUpdate model in Sources/Models/StatusUpdate.swift
- [x] T011 [P] Create Configuration model in Sources/Models/Configuration.swift
- [x] T012 Implement ConfigManager service in Sources/Services/ConfigManager.swift with YAML loading
- [x] T013 Create default config file at runtime in ~/.agent-deck/config.yaml if missing
- [x] T014 Implement Logger utility in Sources/Utilities/Logger.swift using os.log
- [x] T015 Create AppDelegate in Sources/AppDelegate.swift for menubar app lifecycle
- [x] T016 Configure NSStatusBar menubar item with icon in AppDelegate
- [x] T017 Create AgentDeckApp.swift with @main entry point setting LSUIElement policy

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Monitor Running AI Agents from Mobile (Priority: P1) 🎯 MVP

**Goal**: Enable real-time monitoring of Claude Code instances from mobile device with status updates under 500ms and basic task parsing

**Independent Test**: Install Mac app, run Claude Code, open PWA on phone, verify real-time status and current task appear and update within 500ms

### Implementation for User Story 1

- [x] T018 [P] [US1] Implement ProcessMonitor service in Sources/Services/ProcessMonitor.swift using NSWorkspace
- [x] T019 [P] [US1] Implement polling timer (every 500ms) using Combine in ProcessMonitor
- [x] T020 [US1] Add process detection logic filtering by executable name pattern "claude.*code"
- [x] T021 [US1] Extract PID, working directory, and window ID for detected processes
- [x] T022 [US1] Create and update AgentInstance objects when process state changes
- [x] T023 [US1] Remove AgentInstance from list when process terminates
- [x] T024 [P] [US1] Implement WebSocketServer service in Sources/Services/WebSocketServer.swift using Network.framework
- [x] T025 [US1] Implement WebSocket handshake and connection management in WebSocketServer
- [x] T026 [US1] Implement initial_state message broadcast on client connect
- [x] T027 [US1] Implement update message broadcast on status change (within 500ms requirement)
- [x] T028 [US1] Implement instance_added and instance_removed message types
- [x] T029 [P] [US1] Implement HTTPServer service in Sources/Services/HTTPServer.swift for serving PWA files
- [x] T030 [US1] Configure HTTP server to serve static files from Resources/WebRoot/
- [x] T031 [P] [US1] Create MenuBarView in Sources/Views/MenuBarView.swift with agent list display
- [x] T032 [US1] Display detected agent instances in menubar dropdown with status indicators
- [x] T033 [P] [US1] Create PWA index.html in Resources/WebRoot/index.html with mobile-optimized layout
- [x] T034 [P] [US1] Create PWA JavaScript client in Resources/WebRoot/app.js with WebSocket connection
- [x] T035 [US1] Implement WebSocket connection logic with URL from QR code or manual entry
- [x] T036 [US1] Implement status update handling in PWA (display updates within 500ms)
- [x] T037 [US1] Create agent list UI with color-coded status indicators (idle:gray, working:blue, done:green, error:red)
- [x] T038 [US1] Display per-instance metadata: agent type, working directory, last activity timestamp
- [x] T039 [P] [US1] Create dark mode CSS in Resources/WebRoot/styles.css for mobile interface
- [x] T040 [US1] Implement connection status indicator showing "Connected" or "Disconnected"
- [x] T041 [US1] Implement automatic reconnection with exponential backoff (1s→2s→4s→8s→16s max)
- [x] T041.1 [P] [US1] Implement basic OutputParser service in Sources/Services/OutputParser.swift
- [x] T041.2 [US1] Implement regex pattern matching for "Currently:" prefix in Claude Code stdout
- [x] T041.3 [US1] Extract task description from matched line (max 200 chars, truncate if longer)
- [x] T041.4 [US1] Handle unparseable output gracefully (show "Unknown" or last known task)
- [x] T041.5 [US1] Store parsed currentTask in AgentInstance model
- [x] T041.6 [US1] Include currentTask in StatusUpdate WebSocket messages
- [x] T041.7 [US1] Display currentTask in PWA UI below agent status indicator

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently (monitoring + basic parsing)

### Rich Data Enhancement (Phase 3 Extension)

**Purpose**: Add enhanced parsing for model name, git branch, subagents, and todo list

- [x] T141 [P] [US1] Create SubagentInfo model in Sources/Models/SubagentInfo.swift
- [x] T142 [P] [US1] Create TodoItem model in Sources/Models/TodoItem.swift with TodoStatus enum
- [x] T143 [US1] Add rich data fields to AgentInstance: modelName, gitBranch, activeSubagents, todos, currentTaskDescription
- [x] T144 [P] [US1] Create TranscriptParser service in Sources/Services/TranscriptParser.swift
- [x] T145 [US1] Implement parseModelName() to extract model from transcript JSON
- [x] T146 [US1] Implement parseSubagents() to extract active subagents from Task tool invocations
- [x] T147 [US1] Implement parseTodos() to extract todo list with status from TodoWrite tool
- [x] T148 [US1] Implement parseActiveForm() to extract currentTaskDescription from in_progress todos
- [x] T149 [P] [US1] Implement git branch detection using git commands in working directory
- [x] T150 [US1] Integrate TranscriptParser into ProcessMonitor for real-time parsing
- [x] T151 [US1] Update WebSocket messages to include rich data fields
- [x] T152 [P] [US1] Update PWA UI to display model name and git branch
- [x] T153 [P] [US1] Create subagents display section in PWA showing active subagents
- [x] T154 [P] [US1] Create todos display section in PWA with color-coded status indicators
- [x] T155 [US1] Update PWA styles for rich data sections (expandable/collapsible)

**Checkpoint**: Rich data enhancement complete - User Story 1 now includes comprehensive context

---

## Phase 4: User Story 2 - Switch Windows from Mobile Device (Priority: P1) 🎯 MVP

**Goal**: Enable remote window switching from mobile tap to Mac window focus within 1 second

**Independent Test**: Open PWA on phone, tap agent instance card, verify Mac switches to that window within 1 second

### Implementation for User Story 2

- [x] T042 [P] [US2] Implement WindowManager service in Sources/Services/WindowManager.swift
- [x] T043 [US2] Implement AppleScript window focus by PID in WindowManager
- [x] T044 [US2] Handle cross-macOS Space window switching in AppleScript
- [x] T045 [US2] Return success/failure status after window switch attempt
- [x] T046 [US2] Check for accessibility permissions before window switch
- [x] T047 [US2] Add focus message handler in WebSocketServer receiving instanceId
- [x] T048 [US2] Call WindowManager.focusWindow on receiving focus message
- [x] T049 [US2] Send focus_success message to client within 1 second of receiving focus command
- [x] T050 [US2] Send focus_failure message with error code and actionable message on failure
- [x] T051 [US2] Implement tap event handler on agent cards in PWA app.js
- [x] T052 [US2] Send focus WebSocket message with instanceId on card tap
- [x] T053 [US2] Display success/failure feedback in PWA UI
- [x] T054 [US2] Show error message for missing accessibility permissions (FR-031 requirement)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Quick Mobile Setup via QR Code (Priority: P1) 🎯 MVP

**Goal**: Enable mobile setup in under 60 seconds via QR code pairing

**Independent Test**: Install Mac app, scan QR code from menubar dropdown, verify PWA loads and can be added to home screen

### Implementation for User Story 3

- [x] T055 [P] [US3] Implement QR code generation in Sources/Utilities/QRGenerator.swift using CoreImage
- [x] T056 [US3] Implement local IP address discovery using getifaddrs() filtering en0 interface
- [x] T057 [US3] Generate QR code containing local network URL (http://<ip>:3000)
- [x] T058 [US3] Create QRCodeView in Sources/Views/QRCodeView.swift displaying QR code
- [x] T059 [US3] Add "View Mobile Interface" menu item in MenuBarView showing QR code
- [x] T060 [US3] Display local network URL text alongside QR code for manual entry
- [x] T061 [US3] Add error handling for missing WiFi connection (no IP available)
- [x] T062 [US3] Add error handling for port 3000 already in use (suggest port change)
- [x] T063 [US3] Display error message in PWA when devices on different networks

**Checkpoint**: All P1 user stories (MVP core) should now be fully functional

---

## Phase 6: User Story 4 - Advanced Parsed Output (Todo List + Status Line) (Priority: P2)

**Goal**: Display advanced parsed output (todo list, status line) from Claude Code for comprehensive context

**Independent Test**: Run Claude Code with todo list output, verify PWA displays todo items and status line

**Note**: Basic parsing (current task) is part of User Story 1 (Phase 3). This phase adds todo list and status line parsing.

### Implementation for User Story 4

- [ ] T064 [P] [US4] Extend OutputParser service to parse todo list (markdown checkboxes)
- [ ] T065 [US4] Implement regex pattern matching for todo items (lines starting with `- [ ]` or `- [x]`)
- [ ] T066 [US4] Extract todo list with completion status (checked vs unchecked)
- [ ] T067 [US4] Handle multi-line todo items
- [ ] T068 [P] [US4] Implement status line extraction (last line of output or designated marker)
- [ ] T069 [US4] Store todo list and status line separately in AgentInstance model
- [ ] T070 [US4] Include todo list and status line in StatusUpdate WebSocket messages
- [ ] T071 [US4] Display todo list in PWA UI as expandable section
- [ ] T072 [US4] Display status line in PWA UI as footer
- [ ] T073 [US4] Implement toggle to show/hide todo list and status line sections independently
- [ ] T074 [US4] Persist show/hide settings to localStorage

**Checkpoint**: User Story 4 adds advanced parsing, enhancing basic monitoring from US1

---

## Phase 7: User Story 5 - Install and Run Mac App Without Configuration (Priority: P2)

**Goal**: Zero-config installation with automatic Claude Code detection

**Independent Test**: Install Mac app on clean macOS, verify it launches and detects Claude Code without configuration

### Implementation for User Story 5

- [ ] T074 [P] [US5] Implement first-launch detection in AppDelegate
- [ ] T075 [US5] Create default config file at ~/.agent-deck/config.yaml on first launch
- [ ] T076 [US5] Load default agent patterns (claude.*code) from Resources/default-config.yaml
- [ ] T077 [US5] Implement accessibility permissions check on first window switch attempt
- [ ] T078 [US5] Display macOS permission dialog prompt when accessibility needed
- [ ] T079 [US5] Implement clean shutdown in AppDelegate.applicationWillTerminate
- [ ] T080 [US5] Verify no background processes left after quit
- [ ] T081 [P] [US5] Create SettingsView in Sources/Views/SettingsView.swift with tabs
- [ ] T082 [US5] Implement General settings tab (port configuration, auto-start)
- [ ] T083 [US5] Implement Agents settings tab (enable/disable monitoring)
- [ ] T084 [US5] Implement Mobile settings tab (show QR code, connection status)
- [ ] T085 [US5] Implement About settings tab (version, credits)
- [ ] T086 [US5] Persist port and auto-start settings to UserDefaults
- [ ] T087 [US5] Reload configuration when settings change

**Checkpoint**: All user stories (P1 + P2) should now be independently functional

---

## Phase 8: PWA Polish & Offline Capability

**Purpose**: PWA installability and offline support

- [x] T088 [P] Create PWA manifest.json in Resources/WebRoot/manifest.json
- [x] T089 [P] Add app name, description, icons, display mode to manifest
- [x] T090 [P] Create 192x192 icon in Resources/WebRoot/icons/icon-192.png
- [x] T091 [P] Create 512x512 icon in Resources/WebRoot/icons/icon-512.png
- [x] T092 Create service worker in Resources/WebRoot/service-worker.js
- [x] T093 Implement network-first caching strategy in service worker
- [x] T094 Cache UI shell (index.html, app.js, styles.css, manifest.json, icons)
- [x] T095 Implement offline fallback displaying "Offline - Waiting for connection"
- [ ] T096 Test "Add to Home Screen" functionality on iOS Safari 14+
- [ ] T097 Test "Add to Home Screen" functionality on Chrome 90+ (Android)
- [ ] T098 Verify fullscreen launch without browser chrome

---

## Phase 9: Integration Testing & Bug Fixes

**Purpose**: End-to-end validation, smoke test scripts for latency validation, and critical bug fixes

- [ ] T099 Test Mac app launch and menubar icon appearance (target: <2s)
- [ ] T100 Test Claude Code process detection (multiple instances, different working directories)
- [ ] T101 Test status update latency Mac → mobile (target: <500ms)
- [ ] T102 Test window switching latency mobile tap → Mac focus (target: <1s)
- [ ] T103 Test cross-macOS Space window switching
- [ ] T104 Test QR code scanning and PWA connection
- [ ] T105 Test PWA on iOS Safari 14+ (real device)
- [ ] T106 Test PWA on Android Chrome 90+ (real device)
- [ ] T107 Test multiple concurrent Claude Code instances (3-10)
- [ ] T108 Test multiple concurrent mobile clients (1-5 connections)
- [ ] T109 Test network interruption and auto-reconnection (target: <5s)
- [ ] T110 Test Mac sleep/wake cycle with PWA connected
- [ ] T111 Test process termination while monitored
- [ ] T112 Test port 3000 already in use error handling
- [ ] T113 Test different WiFi networks error handling
- [ ] T114 Test accessibility permissions missing error message
- [ ] T115 Validate Mac app resource usage (<100MB RAM, <2% CPU idle, <5% CPU active)
- [ ] T116 Validate 24-hour stability test (no crashes, no memory leaks)
- [ ] T117 Fix critical bugs discovered during testing
- [ ] T118 Optimize performance bottlenecks if any criteria fail
- [ ] T118.1 [P] Create smoke test script test-latency.sh to validate <500ms status update SLA
- [ ] T118.2 [P] Create smoke test script test-window-switch.sh to validate <1s window focus SLA
- [ ] T118.3 [P] Create smoke test script test-stability.sh to monitor 24-hour resource usage
- [ ] T118.4 [P] Create smoke test script test-devices.sh to validate multi-browser compatibility

---

## Phase 10: Documentation & Deployment Preparation

**Purpose**: Final documentation and Show HN launch preparation

- [ ] T119 [P] Update README.md with installation instructions
- [ ] T120 [P] Create Show HN post draft with GIF demo
- [ ] T121 [P] Archive .app for distribution using Xcode
- [ ] T122 Test .app on clean macOS system (or VM)
- [ ] T123 Create GitHub release with .app download link
- [ ] T124 Prepare feedback collection mechanism (GitHub Issues)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational completion - No dependencies on other stories
- **User Story 2 (Phase 4)**: Depends on Foundational + US1 (requires WebSocketServer) - Can integrate with US1
- **User Story 3 (Phase 5)**: Depends on Foundational + US1 (requires HTTPServer, WebSocketServer)
- **User Story 4 (Phase 6)**: Depends on Foundational + US1 (enhances monitoring)
- **User Story 5 (Phase 7)**: Depends on Foundational + US1 + US2 (requires full app structure)
- **PWA Polish (Phase 8)**: Depends on US1 + US3 (PWA exists)
- **Integration Testing (Phase 9)**: Depends on all desired user stories being complete
- **Documentation (Phase 10)**: Depends on Integration Testing passing

### User Story Dependencies

**Independent Stories** (can develop in parallel after Foundational):
- User Story 1: No dependencies (core monitoring)

**Dependent Stories** (require User Story 1):
- User Story 2: Requires US1 (WebSocketServer, AgentInstance model)
- User Story 3: Requires US1 (HTTPServer, WebSocketServer)
- User Story 4: Requires US1 (OutputParser enhances monitoring)
- User Story 5: Requires US1 + US2 (full app infrastructure)

### Within Each User Story

**User Story 1** (Monitor from Mobile):
1. Foundational models complete (T008-T011)
2. ProcessMonitor (T018-T023) - can run parallel with WebSocketServer
3. WebSocketServer (T024-T028) - can run parallel with ProcessMonitor
4. HTTPServer (T029-T030) - can run parallel with above
5. MenuBarView (T031-T032) - can run parallel with PWA
6. PWA (T033-T041) - depends on WebSocketServer being ready

**User Story 2** (Window Switching):
1. WindowManager (T042-T046) - can run parallel with WebSocket handlers
2. WebSocket focus handlers (T047-T050) - depends on WindowManager
3. PWA tap handlers (T051-T054) - depends on WebSocket handlers

**User Story 3** (QR Code Setup):
1. QR code generation (T055-T057) - can run in parallel
2. QRCodeView (T058-T060) - depends on QR generation
3. Error handling (T061-T063) - can run in parallel with above

**User Story 4** (Parsed Output):
1. OutputParser (T064-T067) - can run in parallel
2. Integration with AgentInstance (T068-T069) - depends on OutputParser
3. PWA display (T070-T073) - depends on WebSocket integration

**User Story 5** (Zero Config):
1. First-launch logic (T074-T080) - depends on ConfigManager
2. SettingsView (T081-T087) - can develop in parallel with first-launch

### Parallel Opportunities

**Within Setup Phase** (all can run in parallel):
- T004: Add Yams dependency
- T005: Create folder structure
- T006: Create Assets.xcassets

**Within Foundational Phase** (all models can run in parallel):
- T008-T011: All 4 model files (AgentInstance, AgentStatus, StatusUpdate, Configuration)

**Within User Story 1**:
- T018-T019: ProcessMonitor (developer A)
- T024-T025: WebSocketServer (developer B)
- T029-T030: HTTPServer (developer C)
- T031-T032: MenuBarView (developer D)
- T033-T034: PWA HTML/JS (developer E)
- T039: PWA CSS (developer F)

**Within PWA Polish Phase** (all can run in parallel):
- T088-T089: manifest.json
- T090-T091: Icons
- T092-T095: Service worker

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 + 3 Only)

1. Complete Phase 1: Setup (T001-T007)
2. Complete Phase 2: Foundational (T008-T017) - CRITICAL blocking phase
3. Complete Phase 3: User Story 1 (T018-T041)
4. Complete Phase 4: User Story 2 (T042-T054)
5. Complete Phase 5: User Story 3 (T055-T063)
6. **STOP and VALIDATE**: Test P1 stories independently (Day 12-13)
7. If passing: Proceed to Phase 8-10 (PWA polish, integration testing, deploy)
8. If failing: Fix critical issues, re-test

**Timeline**: Week 1 (Phases 1-3), Week 2 (Phases 4-5, 8-10)

### Incremental Delivery

**Week 1 Milestone** (End of Day 7):
- Foundation + User Story 1 complete
- Can monitor Claude Code from Mac menubar
- Can see status updates on mobile (if PWA deployed)
- Demo: Mac app detecting agents, mobile showing real-time updates

**Week 2 Milestone** (End of Day 14):
- User Stories 2 + 3 complete
- Full MVP ready: monitoring + window switching + QR setup
- PWA installable on home screen
- Ready for Show HN launch

### Full Feature Set (Optional Post-MVP)

After MVP validation (Week 3+):
1. Add User Story 4 (parsed output) if users request context
2. Add User Story 5 (zero config) if installation friction reported
3. Iterate based on Show HN feedback

---

## Parallel Team Strategy

With multiple developers (or agents):

**Week 1: After Foundational Complete**
- Developer A: ProcessMonitor (T018-T023)
- Developer B: WebSocketServer (T024-T028)
- Developer C: HTTPServer + PWA backend (T029-T030)
- Developer D: MenuBarView (T031-T032)
- Developer E: PWA frontend (T033-T041)

**Week 2: After US1 Complete**
- Developer A: WindowManager + AppleScript (T042-T046)
- Developer B: WebSocket focus handlers (T047-T050)
- Developer C: PWA tap handlers (T051-T054)
- Developer D: QR code generation (T055-T060)
- Developer E: PWA polish (T088-T098)

**Week 2 End: Integration**
- All developers: Integration testing (T099-T118)
- Developer A: Documentation (T119-T120)
- Developer B: Deployment (T121-T124)

---

## Notes

- **[P]** tasks = different files, no dependencies (safe for parallel execution)
- **[Story]** label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Manual testing only (per constitution: automated tests in Phase 3+)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- Day 3 Decision Point: If Network.framework proves complex for HTTP serving, migrate to Vapor framework (add T004.1: Add Vapor dependency, T029.1: Replace HTTPServer with Vapor routes)

---

## Task Count Summary

- **Setup**: 7 tasks (T001-T007)
- **Foundational**: 10 tasks (T008-T017)
- **User Story 1**: 46 tasks (T018-T041, T041.1-T041.7, T141-T155) - **includes basic + rich data parsing**
- **User Story 2**: 13 tasks (T042-T054)
- **User Story 3**: 9 tasks (T055-T063)
- **User Story 4**: 11 tasks (T064-T074) - **advanced parsing only (status line, multi-line support)**
- **User Story 5**: 14 tasks (T075-T088) - renumbered from T074-T087
- **PWA Polish**: 11 tasks (T089-T099) - renumbered from T088-T098
- **Integration Testing**: 24 tasks (T100-T118, T118.1-T118.4) - **includes smoke tests**
- **Documentation**: 6 tasks (T119-T124)

**Total**: 151 tasks

**MVP Core** (P1 only): 7 + 10 + 46 + 13 + 9 + 11 + 24 + 6 = **126 tasks**
**Post-MVP** (P2): 11 + 14 = **25 tasks**

**Critical Updates**:
- Rich data enhancement (T141-T155) completed as part of User Story 1 (P1 MVP)
- Basic parsing (current task) moved to User Story 1 (P1 MVP)
- Advanced parsing (status line, multi-line) remains User Story 4 (P2)
- Polling interval updated to 500ms (from 1-2s) to meet <500ms latency SLA
- Smoke test scripts added for latency/stability validation
