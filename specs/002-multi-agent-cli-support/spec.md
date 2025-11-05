# Feature Specification: Multi-Agent CLI Support

**Feature Branch**: `002-multi-agent-cli-support`
**Created**: 2025-01-05
**Status**: Draft
**Input**: User description: "Add support for OpenAI Codex and Google Gemini CLIs"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Monitor OpenAI Codex Alongside Claude Code (Priority: P1)

A developer uses both Claude Code and OpenAI Codex CLI for different projects. They want to see all active coding agent sessions in one place and quickly switch between them from their mobile device.

**Why this priority**: OpenAI Codex is a widely-used coding assistant, and developers often use multiple AI coding tools depending on the task. This delivers immediate value by expanding Agent Deck's utility beyond a single tool.

**Independent Test**: Can be fully tested by running both Claude Code and OpenAI Codex CLI simultaneously, verifying both appear in the Agent Deck interface with correct labels, and successfully switching focus between them.

**Acceptance Scenarios**:

1. **Given** Claude Code and OpenAI Codex CLI are both running, **When** Agent Deck starts monitoring, **Then** both agent instances appear in the interface with distinct "Claude Code" and "OpenAI Codex" labels
2. **Given** two OpenAI Codex CLI sessions are running in different directories, **When** viewing Agent Deck, **Then** both instances appear as separate entries with their respective working directories
3. **Given** an OpenAI Codex session is active, **When** user taps the session card on mobile, **Then** the system brings that terminal window to focus

---

### User Story 2 - Monitor Google Gemini CLI Alongside Other Agents (Priority: P2)

A developer experiments with Google Gemini CLI and wants to monitor it using the same interface they use for Claude Code and OpenAI Codex, without switching tools.

**Why this priority**: Google Gemini represents the third major AI coding assistant ecosystem. Supporting it ensures Agent Deck works with the dominant AI coding tools, but it's P2 because it's less widely adopted than OpenAI Codex currently.

**Independent Test**: Can be fully tested by running Google Gemini CLI alongside other agents, verifying it appears correctly labeled, and confirming window switching works.

**Acceptance Scenarios**:

1. **Given** Claude Code, OpenAI Codex, and Google Gemini CLI are all running, **When** viewing Agent Deck, **Then** all three agent types are visible with distinct type indicators
2. **Given** a Google Gemini CLI session is running, **When** user taps its card on mobile, **Then** the system brings that terminal window to focus
3. **Given** only Google Gemini CLI is running (no Claude Code), **When** Agent Deck starts, **Then** the Gemini instance is detected and displayed correctly

---

### User Story 3 - Configure Which Agents to Monitor (Priority: P3)

A developer only uses Claude Code and OpenAI Codex, and wants to disable Google Gemini monitoring to reduce clutter and system overhead.

**Why this priority**: Configuration adds flexibility but isn't critical for core functionality. Users can simply ignore agent types they don't use. This is a quality-of-life enhancement.

**Independent Test**: Can be fully tested by toggling agent type settings in configuration and verifying the UI only shows enabled agent types.

**Acceptance Scenarios**:

1. **Given** configuration has Google Gemini disabled, **When** a Google Gemini CLI process starts, **Then** it does not appear in Agent Deck
2. **Given** configuration has all agent types enabled, **When** Agent Deck starts monitoring, **Then** processes from all three agent types are detected
3. **Given** user disables OpenAI Codex in settings, **When** existing Codex sessions are running, **Then** they disappear from the interface immediately

---

### Edge Cases

- What happens when multiple instances of the same agent type run in the same directory?
- How does the system handle agent CLIs that aren't installed on the user's machine?
- What if process names overlap or are ambiguous between different agent types?
- How does Agent Deck behave when an unknown/unrecognized agent CLI is running?
- What happens when an agent CLI updates and changes its process name pattern?
- How does the system distinguish between agent CLI processes and other unrelated processes with similar names?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST detect running OpenAI Codex CLI processes and display them as agent instances
- **FR-002**: System MUST detect running Google Gemini CLI processes and display them as agent instances
- **FR-003**: System MUST distinguish between agent types (Claude Code, OpenAI Codex, Google Gemini) and display appropriate type indicators in the UI
- **FR-004**: System MUST support window switching (focus) for all three agent types
- **FR-005**: System MUST handle multiple concurrent instances of each agent type
- **FR-006**: System MUST provide configuration to enable/disable monitoring for each agent type independently
- **FR-007**: System MUST identify the working directory (cwd) for each agent instance regardless of type
- **FR-008**: System MUST gracefully handle cases where an agent CLI is configured but not installed on the system
- **FR-009**: System MUST update the agent instance list in real-time when new agents start or stop
- **FR-010**: System MUST maintain separate state tracking for each agent type (idle, active, etc.) based on available detection mechanisms

### Key Entities *(include if feature involves data)*

- **Agent Type**: Represents a category of coding agent CLI (claude-code, openai-codex, google-gemini)
  - Attributes: type identifier, display name, process detection pattern, enabled status, icon/color

- **Agent Instance**: An individual running session of an agent CLI
  - Attributes: agent type, process ID, working directory, current status, window focus state
  - Relationships: Each instance belongs to exactly one Agent Type

- **Agent Configuration**: User preferences for monitoring behavior
  - Attributes: enabled agent types, monitoring interval, detection patterns
  - Relationships: One configuration per Agent Type

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can simultaneously monitor sessions from all three agent types (Claude Code, OpenAI Codex, Google Gemini) in a single interface
- **SC-002**: Agent type detection has 95%+ accuracy (correctly identifies agent type without false positives)
- **SC-003**: Window switching works for all three agent types with the same reliability as Claude Code (< 1 second latency)
- **SC-004**: Users can distinguish between agent types at a glance (within 2 seconds of viewing the interface)
- **SC-005**: Process detection overhead remains under 5% CPU regardless of how many agent types are enabled
- **SC-006**: Agent Deck continues to function correctly when monitoring 5+ concurrent agent instances across different types

## Dependencies *(include if relevant)*

### Prerequisites

- Claude Code monitoring implementation must be stable and working reliably before implementing multi-agent support
- Process detection mechanism must be extensible to support multiple agent type patterns
- Window switching mechanism must be generic enough to work with any terminal-based agent

### External Dependencies

- OpenAI Codex CLI must provide identifiable process names/patterns
- Google Gemini CLI must provide identifiable process names/patterns
- macOS process monitoring APIs (NSWorkspace) must support detection of all agent types

### Feature Dependencies

- This feature builds on the core monitoring infrastructure from 001-mvp
- This feature depends on the generic window management system from 001-mvp
- Configuration management system must be in place to store agent type preferences

## Assumptions *(mandatory)*

### Technical Assumptions

- OpenAI Codex and Google Gemini both have CLI tools available (or will have by implementation time)
- Each agent CLI has a distinctive process name or command-line pattern that can be detected
- All agent CLIs run as terminal-based processes that can be monitored via standard macOS APIs
- Window switching via AppleScript/NSWorkspace works similarly for all agent types
- Process detection patterns will be discovered through testing during implementation (exact patterns are not critical for spec)

### User Assumptions

- Developers using multiple AI coding tools want a unified monitoring interface
- Users understand that output parsing depth may vary between agent types initially (basic monitoring first, deep parsing later)
- Users are comfortable with basic monitoring (process detection, window switching) before advanced features like real-time output parsing

### Scope Assumptions

- Initial implementation focuses on basic monitoring (detection, status, window switching) rather than deep output parsing for new agent types
- Advanced output parsing (task tracking, status lines, etc.) for OpenAI Codex and Google Gemini will be implemented in future phases after basic monitoring proves stable
- Agent type detection patterns will be configurable via YAML to allow users to customize if needed

## Out of Scope *(include if relevant)*

### Explicitly Excluded

- Deep output parsing for OpenAI Codex and Google Gemini (parsing task lists, status updates, etc.) - deferred to future phases
- Custom action support specific to each agent type - Phase 5+
- Direct interaction with agent CLIs (sending commands, approval prompts) - Phase 5+
- Support for agent types beyond Claude Code, OpenAI Codex, and Google Gemini in this phase
- Automatic detection of new/unknown agent types - manual configuration required
- Integration with agent-specific APIs or SDKs - monitoring is purely process-based

### Future Considerations

- Auto-discovery of agent CLI installation paths
- Agent type plugins or extensions for community-contributed agent support
- Per-agent-type customization of monitoring behavior
- Deep integration with each agent's specific output format and capabilities

## Risks & Mitigations *(include if relevant)*

### Technical Risks

- **Risk**: OpenAI Codex or Google Gemini CLI process names may be ambiguous or change frequently
  - **Mitigation**: Use configurable detection patterns in YAML; allow users to customize patterns; monitor for process name changes

- **Risk**: Different agent CLIs may have incompatible output formats, making unified parsing difficult
  - **Mitigation**: Start with basic monitoring only (no output parsing); implement agent-specific parsers incrementally in future phases

- **Risk**: Window switching may not work reliably for all agent types if they use non-standard terminal configurations
  - **Mitigation**: Test with multiple terminal emulators; provide fallback mechanisms; document known limitations

### Product Risks

- **Risk**: Users may expect feature parity across all agent types immediately, but only Claude Code has deep integration
  - **Mitigation**: Clearly communicate that initial support is basic monitoring, with enhanced features coming later; document current capabilities per agent type

- **Risk**: Agent CLIs may not be available or may require separate installation/authentication
  - **Mitigation**: Provide clear documentation on agent CLI setup; gracefully handle missing CLIs with helpful error messages

## Notes *(optional - remove if not needed)*

### Implementation Guidance

- Refactor existing Claude Code monitoring to use a generic "AgentMonitor" abstraction that can be extended per agent type
- Create agent type registry pattern to allow easy addition of new agent types in the future
- Use strategy pattern for agent-specific detection and parsing logic
- Consider creating a plugin architecture for future extensibility

### User Experience Considerations

- Use distinct visual indicators (colors, icons) for each agent type to aid quick identification
- Consider grouping instances by agent type in the UI if many instances are running
- Provide clear feedback when an agent type is disabled or when no instances of a type are detected

### Testing Strategy

- Test with all three agent types running simultaneously
- Test with only one agent type running at a time
- Test agent type enable/disable configuration changes
- Test process detection across different terminal emulators
- Test window switching reliability for each agent type
