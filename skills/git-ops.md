---
name: git-ops
description: Atomic git operations skill. Covers branching strategy, commit discipline, conflict resolution, history management, and PR workflows. Use whenever performing version control operations. Reusable by dev-agent and ops-agent.
---

# Git Operations — Shared Skill

## Branching Strategy
- `main` / `master` — production-only, protected
- `dev` — integration branch for active work
- `feature/<name>` — scoped feature work
- `fix/<name>` — bug fixes
- `sec/<name>` — security patches (expedited review)
- `ops/<name>` — infrastructure changes

## Commit Standards

**Format: `<type>: <short description>`**

```
feat: add JWT authentication middleware

- Implement token validation with expiry, issuer, and audience checks
- Add constant-time comparison to prevent timing attacks
- Wire rate limiting to all auth endpoints
- Closes #42
```

### Types
| Type | Use |
|------|-----|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `sec` | Security fix (expedited review) |
| `refactor` | Code change that doesn't add features or fix bugs |
| `perf` | Performance improvement |
| `test` | Adding or fixing tests |
| `ci` | CI/CD pipeline changes |
| `ops` | Infrastructure or deployment changes |
| `docs` | Documentation only |
| `chore` | Dependency bumps, tooling, config |
| `revert` | Reverts a previous commit |

### Rules
- First line: `<type>: <description>` — ≤ 72 chars, lowercase description
- Body: bullet points explaining WHAT changed and WHY — one bullet per logical change
- Reference ticket/issue when available: `- Closes #123`
- Never commit: secrets, credentials, large binaries, .env files

## Workflow
1. Check status before any operation: `git status && git diff`
2. Stage explicitly by filename — never `git add .` without review
3. Run tests before commit
4. Push to feature branch; never force-push shared branches
5. PR targets `dev` branch; `dev` → `main` requires review gate

## Safety Rules
- Confirm before: `reset --hard`, `push --force`, `branch -D`, `clean -f`
- Never skip hooks (`--no-verify`) unless explicitly authorized
- Merge conflicts → resolve root cause, never `checkout --theirs` blindly

## Common Operations
```bash
# Safe staged commit
git add <specific-files> && git commit -m "$(cat <<'EOF'
<message>
EOF
)"

# Check what diverges from main
git log main..HEAD --oneline

# Undo last commit safely (keep changes staged)
git reset --soft HEAD~1
```
