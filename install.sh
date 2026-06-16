#!/usr/bin/env bash
# DotfilesClaude — Install Script
# Installs NBR. Company Claude Code configuration to ~/.claude/
# Idempotent: safe to run multiple times.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
R='\033[0m'

info()    { echo -e "${CYAN}  →${R} $*"; }
success() { echo -e "${GREEN}  ✓${R} $*"; }
warn()    { echo -e "${YELLOW}  !${R} $*"; }
error()   { echo -e "${RED}  ✗${R} $*"; }

echo ""
echo -e "${CYAN}DotfilesClaude — NBR. Company${R}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
echo ""

# ── 1. Preflight checks ───────────────────────────────────────────────────────
echo "Checking dependencies..."

check_cmd() {
  if command -v "$1" &>/dev/null; then
    success "$1 found"
  else
    warn "$1 not found — $2"
  fi
}

check_cmd "claude"  "Install Claude Code: https://claude.ai/download"
check_cmd "gh"      "Required for GitHub MCP server: https://cli.github.com"
check_cmd "jq"      "Required for statusline: sudo apt install jq"
check_cmd "node"    "Required for MCP servers: https://nodejs.org"
check_cmd "mcp-server-memory"    "Install: npm install -g @modelcontextprotocol/server-memory"
check_cmd "mcp-server-github"    "Install: npm install -g @modelcontextprotocol/server-github"
check_cmd "token-optimizer-mcp"  "Install: npm install -g @ooples/token-optimizer-mcp"

echo ""

# ── 2. Ensure directories exist ───────────────────────────────────────────────
echo "Creating directories..."
mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/bin" "$CLAUDE_DIR/mcp"
success "Directories ready"
echo ""

# ── 3. Copy files ─────────────────────────────────────────────────────────────
echo "Installing configuration files..."

install_file() {
  local src="$1"
  local dst="$2"
  if [ -f "$dst" ]; then
    # Backup existing file
    cp "$dst" "${dst}.bak.$(date +%Y%m%d%H%M%S)"
  fi
  cp "$src" "$dst"
  info "$(basename "$dst")"
}

# Root config
install_file "$REPO_DIR/CLAUDE.md"               "$CLAUDE_DIR/CLAUDE.md"
install_file "$REPO_DIR/statusline-command.sh"   "$CLAUDE_DIR/statusline-command.sh"

# settings.json: only install if it doesn't exist (avoid clobbering live config)
if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
  install_file "$REPO_DIR/settings.json" "$CLAUDE_DIR/settings.json"
  info "settings.json (new install)"
else
  warn "settings.json already exists — skipping (merge manually if needed)"
fi

# Agents
for f in "$REPO_DIR/agents/"*.md; do
  install_file "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
done

# Skills
for f in "$REPO_DIR/skills/"*.md; do
  install_file "$f" "$CLAUDE_DIR/skills/$(basename "$f")"
done

# Bin scripts
install_file "$REPO_DIR/bin/mcp-github"              "$CLAUDE_DIR/bin/mcp-github"
install_file "$REPO_DIR/bin/guard-sensitive-files.sh" "$CLAUDE_DIR/bin/guard-sensitive-files.sh"
chmod +x "$CLAUDE_DIR/bin/mcp-github" "$CLAUDE_DIR/bin/guard-sensitive-files.sh"
success "bin/ scripts marked executable"

# MCP registry
install_file "$REPO_DIR/mcp/registry.yaml" "$CLAUDE_DIR/mcp/registry.yaml"

echo ""

# ── 4. Verify mcp-github wrapper ─────────────────────────────────────────────
echo "Verifying GitHub MCP wrapper..."
if gh auth status &>/dev/null; then
  success "gh CLI authenticated — mcp-github wrapper ready"
else
  warn "gh CLI not authenticated — run: gh auth login"
fi

# ── 5. Summary ────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}Installation complete.${R}"
echo ""
echo "  CLAUDE.md:        $CLAUDE_DIR/CLAUDE.md"
echo "  Agents:           $CLAUDE_DIR/agents/ (5 agents)"
echo "  Skills:           $CLAUDE_DIR/skills/ (9 skills)"
echo "  MCP registry:     $CLAUDE_DIR/mcp/registry.yaml"
echo "  Status line:      $CLAUDE_DIR/statusline-command.sh"
echo "  Bin:              $CLAUDE_DIR/bin/"
echo ""
echo "  Restart Claude Code to activate all changes."
echo ""
