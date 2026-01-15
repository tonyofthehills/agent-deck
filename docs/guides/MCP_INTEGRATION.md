# MCP Server Integration Guide

**Agent Deck - Model Context Protocol (MCP) Integration**

This project uses multiple MCP servers to enhance development capabilities. Each server has specific strengths - use them strategically.

**Last Updated**: 2025-01-24

---

## Table of Contents

1. [Available MCP Servers](#available-mcp-servers)
2. [When to Use Which Server](#when-to-use-which-mcp-server)
3. [Best Practices](#best-practices)
4. [Typical Workflow Examples](#typical-workflow-examples)

---

## Available MCP Servers

### 1. **Exa Search** (`@modelcontextprotocol/server-exa`)

**Purpose:** Web research, current information, troubleshooting

**Use for:**
- Researching new technologies, libraries, or frameworks
- Finding current best practices and tutorials
- Troubleshooting errors and issues
- Discovering architectural patterns
- General web research

**Tools:**
- `web_search_exa` - Neural web search with quality rankings
- `get_code_context_exa` - Search for programming-specific context

**Example usage:**
```
"Research the latest React Native performance optimization techniques"
"Find best practices for Swift Concurrency with @MainActor"
"How to implement WebSocket reconnection in React Native"
```

---

### 2. **Ref** (`ref-tools-mcp`)

**Purpose:** Agentic documentation search, exploratory learning

**Use for:**
- Exploratory "how to do X" questions
- Discovering best practices within specific libraries
- Finding code examples and patterns
- When you don't know exactly which docs you need
- Token-efficient documentation retrieval

**Strengths:**
- Agentic search-and-read pattern (LLM refines queries)
- Covers 1000s of public repos and documentation sites
- Minimal token usage compared to full doc dumps
- Great for discovering APIs you didn't know existed

**Example usage:**
```
"How do I implement navigation with React Navigation v6?"
"Show me best practices for SwiftUI navigation in macOS apps"
"What's the proper way to use expo-keep-awake?"
```

---

### 3. **Context7** (`@upstash/context7-mcp`)

**Purpose:** Comprehensive library documentation retrieval

**Use for:**
- Getting detailed API reference for a specific known library
- When you need comprehensive documentation about one library
- Targeted documentation with high token counts (up to 50k tokens)

**Strengths:**
- Deep, comprehensive documentation
- Two-step process: resolve library ID, then fetch docs
- Good for detailed API exploration of a single library

**Tools:**
- `resolve-library-id` - Find Context7-compatible library ID
- `get-library-docs` - Fetch comprehensive documentation

**Example usage:**
```
"Get comprehensive React Native documentation for hooks (use context7)"
"Fetch detailed SwiftUI documentation for @Observable macro (use context7)"
```

---

### 4. **Pieces** (`pieces`)

**Purpose:** Historical and contextual memory from user's environment

**Use for:**
- Understanding what the user has been working on recently
- Retrieving past interactions and code snippets
- Accessing project-specific context and history
- Creating long-term memories of important breakthroughs

**Tools:**
- `ask_pieces_ltm` - Query historical/contextual information
- `create_pieces_memory` - Save important context for future reference

**Important:** Always provide `chat_llm` parameter (e.g., "claude-sonnet-4-5-20250929")

**Example usage:**
```
"What was I working on in React Native yesterday?" (use pieces)
"Show me the approach I used for authentication in the last session" (use pieces)
```

**Creating Memories:**
Create Pieces memories for:
- Major breakthroughs or bug fixes
- Important architectural decisions
- Complex problem solutions
- Topic/goal changes
- Pre-commit documentation

---

### 5. **Semgrep** (`semgrep`)

**Purpose:** Security vulnerability scanning and code quality analysis

**Use for:**
- Scanning AI-generated Swift and TypeScript/JavaScript code before committing
- Finding macOS security issues (Keychain, file permissions, URL schemes)
- Checking React Native security (XSS, insecure storage, API exposure)
- Validating authentication and session handling
- OWASP Top 10 vulnerability detection

**Tools:**
- `semgrep_scan` - Scan files for security vulnerabilities
- `semgrep_scan_with_custom_rule` - Run custom security rules
- `semgrep_scan_supply_chain` - Check dependency vulnerabilities
- `get_supported_languages` - List supported languages (Swift, TypeScript, JavaScript, etc.)

**CRITICAL - Always scan before committing:**
- AI-generated code (Swift menubar app OR React Native mobile)
- Authentication/authorization changes
- WebSocket communication code
- Session management
- File operations
- API endpoint implementations
- AsyncStorage usage (React Native)

**Example usage:**
```
"Scan the Swift authentication code for security issues"
"Check the React Native TypeScript for insecure storage"
"Run supply chain scan after pnpm install"
```

**For comprehensive security guidance, see [SECURITY.md](./SECURITY.md)**

---

## When to Use Which MCP Server

| Scenario | Use This | Why |
|----------|----------|-----|
| "How do I implement X with Y library?" | **Ref** | Exploratory documentation search |
| "What are the latest best practices for X?" | **Exa Search** | Current web research |
| "Get comprehensive docs for Library X" | **Context7** | Deep, targeted documentation |
| "What was I working on yesterday?" | **Pieces** | Historical context |
| "Find tutorials for X technology" | **Exa Search** | Web research |
| "Show me the API for specific function in Library X" | **Ref** → **Context7** | Start with Ref, deep dive with Context7 |
| "Troubleshoot this error message" | **Exa Search** | Current solutions and discussions |
| "How did I solve problem X last week?" | **Pieces** | Historical memory |

---

## Best Practices

### 1. Start Broad, Then Focus
- Start with **Ref** for exploratory questions
- Use **Exa Search** for broader research
- Deep dive with **Context7** when you know exactly what you need

### 2. Be Specific
- Include library names and version numbers when known
- Mention the specific technology stack (React Native, Swift, etc.)
- Reference error messages verbatim for troubleshooting

### 3. Don't Overuse
- Don't use MCP servers for basic programming knowledge
- Don't use them for project-specific code (use codebase search instead)
- Don't use them when the answer is in recent context

### 4. Create Memories
- Use Pieces to save important breakthroughs
- Document complex solutions for future reference
- Create memories before major commits or pivots

### 5. Privacy Considerations
- Exa Search queries may be logged - avoid API keys/secrets
- Pieces stores data locally - safe for sensitive information
- Context7 and Ref access public documentation only

---

## Typical Workflow Examples

### Starting a new feature
1. Use **Exa Search** to research current best practices
2. Use **Ref** to explore relevant library documentation
3. Use **Context7** for deep dive into specific APIs
4. Create a **Pieces memory** when complete

### Troubleshooting an error
1. Use **Pieces** to check if you've seen this error before
2. Use **Exa Search** to find recent solutions
3. Use **Ref** to understand the underlying library behavior

### Learning a new library
1. Use **Exa Search** for tutorials and getting started guides
2. Use **Ref** for exploratory API discovery
3. Use **Context7** for comprehensive API reference
4. Create **Pieces memories** for important patterns learned

---

## Related Documentation

- **[SECURITY.md](./SECURITY.md)** - Security scanning with Semgrep MCP
- **[CLAUDE.md](../../CLAUDE.md)** - Main project guide with MCP overview
- **Workspace CLAUDE.md** - Comprehensive MCP documentation for all workspace projects

---

**Version**: 1.0
**Extracted from**: CLAUDE.md (Agent Deck project)
**Last Updated**: 2025-01-24
