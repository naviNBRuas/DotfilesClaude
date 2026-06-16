#!/usr/bin/env bash
# NBR. Company-style Claude Code status line for Navin
# Dense professional terminal dashboard

input=$(cat)

# ── Model ────────────────────────────────────────────────────────────────────
model_name=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')

# Shorten common model names for compactness
model_short=$(echo "$model_name" | sed \
  -e 's/Claude /C/g' \
  -e 's/Sonnet/SNT/g' \
  -e 's/Opus/OPS/g' \
  -e 's/Haiku/HKU/g')

# ── Token / Context Window ────────────────────────────────────────────────────
used_pct=$(echo "$input"    | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
ctx_size=$(echo "$input"    | jq -r '.context_window.context_window_size // 0')

# Format token count (e.g. 42k, 1.2M)
format_tokens() {
  local n=$1
  if [ "$n" -ge 1000000 ] 2>/dev/null; then
    printf "%.1fM" "$(echo "scale=1; $n / 1000000" | bc)"
  elif [ "$n" -ge 1000 ] 2>/dev/null; then
    printf "%.0fk" "$(echo "scale=0; $n / 1000" | bc)"
  else
    printf "%d" "$n"
  fi
}

tokens_used=$(format_tokens "$total_input")
tokens_max=$(format_tokens "$ctx_size")

# Color-code context usage
ctx_color=""
ctx_reset="\033[0m"
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  if   [ "$used_int" -ge 85 ]; then ctx_color="\033[0;31m"   # red
  elif [ "$used_int" -ge 60 ]; then ctx_color="\033[0;33m"   # yellow
  else                               ctx_color="\033[0;32m"   # green
  fi
  ctx_bar="${ctx_color}${used_int}%${ctx_reset}"
else
  ctx_bar="--%"
fi

# ── Git branch ───────────────────────────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
git_branch=""
if [ -n "$cwd" ]; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$git_branch" ]; then
    git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi
fi

# ── MCP Servers ──────────────────────────────────────────────────────────────
# Count configured MCP servers from settings.json
settings_file="$HOME/.claude/settings.json"
mcp_count=0
if [ -f "$settings_file" ]; then
  mcp_count=$(jq '.mcpServers | length' "$settings_file" 2>/dev/null || echo 0)
fi

# ── Session timing ───────────────────────────────────────────────────────────
transcript=$(echo "$input" | jq -r '.transcript_path // empty')
session_age=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  mod_epoch=$(stat -c %Y "$transcript" 2>/dev/null || echo "")
  if [ -n "$mod_epoch" ]; then
    now_epoch=$(date +%s)
    delta=$(( now_epoch - mod_epoch ))
    if   [ "$delta" -ge 3600 ]; then
      session_age=$(printf "%dh%02dm" $(( delta / 3600 )) $(( (delta % 3600) / 60 )))
    elif [ "$delta" -ge 60 ]; then
      session_age=$(printf "%dm%02ds" $(( delta / 60 )) $(( delta % 60 )))
    else
      session_age="${delta}s"
    fi
  fi
fi

# ── Thinking / Effort ────────────────────────────────────────────────────────
thinking=$(echo "$input" | jq -r '.thinking.enabled // false')
effort_level=$(echo "$input" | jq -r '.effort.level // empty')

# ── Rate limits ──────────────────────────────────────────────────────────────
five_hr=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# ── Session name / vim mode ──────────────────────────────────────────────────
session_name=$(echo "$input" | jq -r '.session_name // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

# ── ANSI palette (dimmed-terminal friendly) ───────────────────────────────────
R="\033[0m"         # reset
BOLD="\033[1m"
DIM="\033[2m"
CYAN="\033[0;36m"
BCYAN="\033[1;36m"
WHITE="\033[0;37m"
BWHITE="\033[1;37m"
BLUE="\033[0;34m"
BBLUE="\033[1;34m"
MAGENTA="\033[0;35m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
GRAY="\033[0;90m"

SEP="${GRAY} | ${R}"

# ── Assemble segments ────────────────────────────────────────────────────────
line=""

# [MODEL]
line+="${BCYAN}${model_short}${R}"

# [CONTEXT]
line+="${SEP}${GRAY}ctx:${R}${ctx_bar} ${GRAY}(${tokens_used}/${tokens_max})${R}"

# [GIT BRANCH]
if [ -n "$git_branch" ]; then
  line+="${SEP}${BBLUE}${git_branch}${R}"
fi

# [MCP]
if [ "$mcp_count" -gt 0 ]; then
  line+="${SEP}${GRAY}mcp:${R}${GREEN}${mcp_count}${R}"
fi

# [SESSION TIME]
if [ -n "$session_age" ]; then
  line+="${SEP}${GRAY}age:${R}${WHITE}${session_age}${R}"
fi

# [THINKING / EFFORT]
if [ "$thinking" = "true" ]; then
  line+="${SEP}${MAGENTA}think${R}"
fi
if [ -n "$effort_level" ]; then
  line+="${SEP}${GRAY}eff:${R}${YELLOW}${effort_level}${R}"
fi

# [SESSION NAME]
if [ -n "$session_name" ]; then
  line+="${SEP}${GRAY}[${session_name}]${R}"
fi

# [VIM MODE]
if [ -n "$vim_mode" ]; then
  line+="${SEP}${YELLOW}${vim_mode}${R}"
fi

# [RATE LIMITS]
rates=""
if [ -n "$five_hr" ]; then
  rates+="5h:$(printf '%.0f' "$five_hr")%"
fi
if [ -n "$seven_d" ]; then
  [ -n "$rates" ] && rates+=" "
  rates+="7d:$(printf '%.0f' "$seven_d")%"
fi
if [ -n "$rates" ]; then
  line+="${SEP}${RED}${rates}${R}"
fi

# ── Print ─────────────────────────────────────────────────────────────────────
printf '%b\n' "${line}"
