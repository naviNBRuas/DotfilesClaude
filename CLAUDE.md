# NBR. Company — Global Claude Code Configuration

## Identity
**Navin B. Ruas** | @naviNBRuas | github.com/naviNBRuas | Founder, NBR. Company

Primary domains: **software development · AI engineering · cybersecurity**

---

## Architecture (Single Source of Truth: `~/.claude/`)

| Path | Contents |
|------|----------|
| `~/.claude/agents/` | orchestrator, dev, sec, ops, review |
| `~/.claude/skills/` | git-ops, dependency-mgmt, code-analysis, vulnerability-scan, cicd-pipeline, logging-observability, deployment-automation, ai-engineering, ai-security |
| `~/.claude/mcp/registry.yaml` | token-optimizer + 7 plugin-sourced servers |
| `~/.claude/projects/-home-user--claude/memory/` | identity, architecture, workflow constraints |

NEVER create `.claude/` inside project directories. If found: migrate → remove → update references.

---

## Agent Routing

```
All tasks → orchestrator-agent (first)
  ├── Code / features / debugging / AI systems  → dev-agent
  ├── Security audits / threat modeling / CVEs / AI security  → sec-agent
  ├── Infra / CI/CD / deployment / reliability  → ops-agent
  └── Review / validation / quality gate  → review-agent
```

Multi-domain tasks (e.g., secure AI deployment): parallel dispatch via orchestrator-agent.

---

## Domain-Specific Defaults

**AI Engineering**
- Default model: `claude-sonnet-4-6`; use `claude-opus-4-8` for complex agents
- Invoke `ai-engineering` skill for LLM integration, RAG, agent patterns, prompt design
- Invoke `ai-security` skill when building or auditing any AI-powered system

**Cybersecurity**
- All offensive work requires explicit authorization context before proceeding
- Invoke `vulnerability-scan` + `ai-security` for AI system audits
- sec-agent owns: OWASP analysis, threat modeling, CVE triage, red-team support

**Software Development**
- Invoke `code-analysis` before implementing features in unfamiliar codebases
- Invoke `git-ops` for all VCS operations
- TypeScript LSP active for TS/JS projects via `typescript-lsp` plugin

---

## Code Standards

- No comments explaining WHAT — name things clearly
- Comment only non-obvious WHY (workarounds, hidden constraints, subtle invariants)
- No features beyond what the task requires
- No error handling for impossible scenarios
- No OWASP Top 10 vulnerabilities — ever
- Prefer editing existing files over creating new ones

---

## Active MCP Servers (wired in settings.json)

| Server | Binary | Purpose |
|--------|--------|---------|
| `token-optimizer` | `token-optimizer-mcp` | Token efficiency enforcement |
| `github` | `~/.claude/bin/mcp-github` | GitHub API — code search, PRs, issues, file ops |
| `memory` | `mcp-server-memory` | Session knowledge graph (entities + relations) |

GitHub token sourced at runtime via `gh auth token` — no plaintext stored. Wrapper at `~/.claude/bin/mcp-github`.

Plugin MCP servers (chrome-devtools, playwright, context7, exa, desktop-commander, linear, cloudflare) are managed by their plugins automatically.

## Token Optimization (Enforced)

- Reference things by name — do not reprint configs or full file contents
- Summarize intermediate reasoning; do not echo agent outputs verbatim
- No trailing summaries after task completion
- Shortest effective execution path always wins

---

## Active Plugins (26)
`superpowers` `code-review` `feature-dev` `security-guidance` `frontend-design` `context7`
`skill-creator` `code-simplifier` `github` `playwright` `claude-md-management` `typescript-lsp`
`ralph-loop` `claude-code-setup` `commit-commands` `chrome-devtools-mcp` `plugin-dev` `linear`
`learning-output-style` `remember` `mcp-server-dev` `cloudflare` `wordpress.com`
`desktop-commander` `exa` `knowledge-catalog`
