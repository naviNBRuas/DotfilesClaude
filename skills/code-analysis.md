---
name: code-analysis
description: Codebase exploration and analysis skill. Use before implementing features or performing reviews to understand existing patterns, architecture, and conventions. Reusable by dev-agent, sec-agent, and review-agent.
---

# Code Analysis — Shared Skill

## Exploration Order
1. **Entry points** — find main(), index, CLI entrypoints, route definitions
2. **Configuration** — read config files, env schema, feature flags
3. **Data models** — schema files, type definitions, database models
4. **Core logic** — business logic modules, service layer
5. **Tests** — understand what's tested and how
6. **Dependencies** — package manifests for ecosystem context

## Key Commands
```bash
# Find entry points
find . -name "main.*" -o -name "index.*" -o -name "app.*" | grep -v node_modules | grep -v .git

# Map architecture (top-level structure)
find . -maxdepth 2 -type d | grep -v node_modules | grep -v .git | sort

# Find where a symbol is defined
grep -rn "function <name>\|class <name>\|def <name>\|fn <name>" --include="*.{ts,js,py,go,rs}" .

# Find all callers of a function
grep -rn "<function_name>" --include="*.{ts,js,py,go,rs}" . | grep -v "def \|function "

# Count lines by file type
find . -name "*.ts" | xargs wc -l | sort -rn | head -20
```

## Pattern Recognition
- Look for repeated structures → identify the abstraction in use
- Read tests before reading implementation (tests document expected behavior)
- Check git log for recent changes: `git log --oneline -20`
- Look for TODOs and FIXMEs: `grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.{ts,js,py,go,rs}" .`

## Reporting Format
When reporting analysis findings:
```
Architecture: <pattern name — MVC, hexagonal, flat, etc.>
Language/Runtime: <ecosystem>
Entry Points: <file:line>
Key Modules: <list with purpose>
Conventions: <naming, error handling, testing patterns>
Concerns: <anything unusual or risky>
```
