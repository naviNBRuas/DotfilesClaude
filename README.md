# DotfilesClaude

**NBR. Company — Claude Code configuration.**
Multi-agent architecture, 9 shared skills, custom status line, and MCP server wiring for a professional Claude Code setup.

---

## What's Inside

```
DotfilesClaude/
├── CLAUDE.md                    # Global Claude Code instructions (loaded every session)
├── settings.json                # Permissions, hooks, MCP servers, plugins, theme
├── statusline-command.sh        # Custom terminal status line (model · context · git · MCP · rate limits)
│
├── agents/                      # Specialized agent definitions
│   ├── orchestrator-agent.md    # Task router — dispatches to Gemini / OpenCode / Claude agents
│   ├── dev-agent.md             # Code, AI systems, debugging, refactoring
│   ├── sec-agent.md             # Security audits, OWASP, CVE triage, AI security, red-team
│   ├── ops-agent.md             # CI/CD, infra, containers, IaC, observability
│   └── review-agent.md          # PR review, architecture validation, quality gate
│
├── skills/                      # Shared skill documents (invoked by agents)
│   ├── ai-engineering.md        # LLM integration, RAG, agents, prompt engineering
│   ├── ai-security.md           # Prompt injection, OWASP LLM Top 10, adversarial ML
│   ├── code-analysis.md         # Codebase exploration before implementation
│   ├── cicd-pipeline.md         # GitHub Actions, security gates, pipeline patterns
│   ├── dependency-mgmt.md       # npm / pip / Go / Rust — pinning, auditing, removal
│   ├── deployment-automation.md # Blue/green, canary, rollback, environment promotion
│   ├── git-ops.md               # Branching, conventional commits, PR workflow
│   ├── logging-observability.md # Structured logs, RED metrics, alerting, tracing
│   └── vulnerability-scan.md    # Secrets detection, SAST, OWASP scan, infra scan
│
├── bin/
│   ├── mcp-github               # GitHub MCP wrapper (token from gh CLI, never plaintext)
│   └── guard-sensitive-files.sh # PreToolUse hook — blocks lock file edits, warns on .env
│
└── mcp/
    └── registry.yaml            # MCP server catalog (standalone + plugin-sourced)
```

---

## Agent Architecture

All tasks route through the **orchestrator-agent** first. It classifies intent, scores complexity, and dispatches:

```
orchestrator-agent
  ├── Score 1 (trivial)     → gemini -p "..."          (summarize, explain, research)
  ├── Score 2 (simple code) → opencode run "..."        (file reads, small edits)
  └── Score 3 (complex)     → Claude sub-agents
        ├── dev-agent        (code, AI systems, debugging)
        ├── sec-agent        (security, audits, red-team)
        ├── ops-agent        (infra, CI/CD, deployment)
        └── review-agent     (validation, quality gate)
```

Independent subtasks in each complexity tier run in **parallel waves** — the orchestrator never serializes work that can be concurrent.

---

## Skills System

Skills are markdown documents that agents invoke by name. They contain:
- Decision frameworks and checklists
- Code patterns and templates
- Domain-specific standards
- Routing rules for handoffs

Agents don't reprint skill content — they invoke by name. This keeps context windows lean.

---

## Status Line

The `statusline-command.sh` renders a dense, color-coded terminal dashboard:

```
C SNT 4.6 | ctx: 42% (18k/200k) | main | mcp: 3 | age: 12m30s | think | 5h: 23% 7d: 8%
```

| Segment | Content |
|---------|---------|
| Model | Shortened model name (C SNT = Claude Sonnet) |
| Context | Used % with token counts; color-coded green→yellow→red |
| Branch | Current git branch |
| MCP | Count of active MCP servers |
| Age | Session duration |
| Think | Shows when extended thinking is enabled |
| Rate limits | 5h and 7d usage percentages |

---

## MCP Servers

### Standalone (wired in `settings.json`)
| Server | Purpose |
|--------|---------|
| `token-optimizer` | Enforces token efficiency across sessions |
| `github` | GitHub API — repo ops, PRs, issues, code search |
| `memory` | In-session knowledge graph (entities + relations) |

### Plugin-sourced (auto-managed)
`chrome-devtools` · `playwright` · `context7` · `desktop-commander` · `exa` · `linear` · `cloudflare`

The GitHub MCP server uses a wrapper (`bin/mcp-github`) that sources the token from `gh auth` at runtime — **no tokens stored in plaintext**.

---

## Hooks

| Hook | Trigger | Action |
|------|---------|--------|
| `guard-sensitive-files.sh` | Any `Edit` or `Write` tool call | Blocks lock file edits; warns on `.env` and credential files |
| Desktop notification | `idle_prompt` | `notify-send` when Claude is waiting for input |
| Desktop notification | `permission_prompt` | Critical urgency alert when permission is requested |

---

## Install

```bash
git clone https://github.com/naviNBRuas/DotfilesClaude.git
cd DotfilesClaude
chmod +x install.sh
./install.sh
```

The script:
1. Checks for required dependencies (`claude`, `gh`, `jq`, `node`, MCP server binaries)
2. Creates `~/.claude/agents/`, `~/.claude/skills/`, `~/.claude/bin/`, `~/.claude/mcp/`
3. Installs all files with timestamped backups of any existing files
4. Skips `settings.json` if one already exists (merge manually)
5. Sets executable permissions on `bin/` scripts

### Manual install (selective)

```bash
# Just the agents
cp agents/*.md ~/.claude/agents/

# Just the skills
cp skills/*.md ~/.claude/skills/

# Global instructions only
cp CLAUDE.md ~/.claude/CLAUDE.md

# Status line
cp statusline-command.sh ~/.claude/statusline-command.sh
```

### MCP server dependencies

```bash
npm install -g @modelcontextprotocol/server-github
npm install -g @modelcontextprotocol/server-memory
npm install -g @ooples/token-optimizer-mcp
```

---

## Requirements

- **Claude Code** (`claude` CLI) — [claude.ai/download](https://claude.ai/download)
- **GitHub CLI** (`gh`) — for the GitHub MCP wrapper
- **Node.js** — for MCP servers
- **jq** — for the status line script
- **notify-send** (Linux) — for desktop notifications (optional)

---

## Plugins Referenced in `settings.json`

26 Claude Code plugins are wired. Core ones that shape agent behavior:

| Plugin | Role |
|--------|------|
| `superpowers` | Skills system, brainstorming, plan/execute workflows |
| `code-review` | PR review with inline comments |
| `feature-dev` | Guided feature implementation with codebase analysis |
| `security-guidance` | Security-first development patterns |
| `context7` | Live library documentation via MCP |
| `typescript-lsp` | LSP integration for TS/JS projects |
| `commit-commands` | Commit, push, and PR automation |
| `ralph-loop` | Iterative agentic loop for long-running tasks |

---

## License

MIT — [Navin B. Ruas](https://github.com/naviNBRuas)
