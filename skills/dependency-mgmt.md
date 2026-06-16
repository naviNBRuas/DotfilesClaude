---
name: dependency-mgmt
description: Dependency management skill for Node.js, Python, Go, and Rust projects. Covers installation, version pinning, audit, and removal. Reusable by dev-agent and ops-agent. Always run audit after installs.
---

# Dependency Management — Shared Skill

## Universal Rules
- Pin versions in production (exact or ~minor); use ranges only in libraries
- Never install unvetted packages without checking npm/PyPI/crates.io audit score
- Always run security audit post-install
- Keep dependency count minimal — prefer stdlib where feasible

## Node.js / npm
```bash
# Install with exact version
npm install --save-exact <package>@<version>

# Audit immediately after install
npm audit --audit-level=high

# Check outdated
npm outdated

# Remove unused
npm prune
```

## Python / pip
```bash
# Use virtual environments always
python -m venv .venv && source .venv/bin/activate

# Pin in requirements.txt
pip install <package>==<version> && pip freeze > requirements.txt

# Audit
pip audit  # requires pip-audit

# Check for known CVEs
safety check
```

## Go
```bash
# Add dependency
go get <module>@<version>

# Verify module integrity
go mod verify

# Remove unused
go mod tidy
```

## Rust
```bash
# Add with exact version
cargo add <crate>@=<version>

# Audit
cargo audit
```

## After Any Dependency Change
1. Run `audit` for the ecosystem
2. Run tests
3. Review diff of lock file before committing
4. Document WHY the dependency was added (in PR description, not code)
