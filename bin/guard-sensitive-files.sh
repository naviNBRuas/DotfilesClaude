#!/usr/bin/env bash
# PreToolUse hook: enforces file-edit safety rules
# - Hard blocks: lock files (must only change via package manager)
# - Soft warn: .env files (allowed but flagged)

input=$(cat)
file_path=$(echo "$input" | jq -r '.file_path // empty' 2>/dev/null)

[ -z "$file_path" ] && exit 0

basename=$(basename "$file_path")

case "$basename" in
  package-lock.json|yarn.lock|pnpm-lock.yaml|Cargo.lock|poetry.lock|Pipfile.lock|go.sum)
    echo "BLOCKED: $basename must only change via package manager, not direct edits." >&2
    exit 1
    ;;
esac

case "$basename" in
  .env|.env.local|.env.production|.env.staging|.env.development|.env.*)
    echo "WARNING: Editing env file $file_path — verify no secrets are committed." >&2
    ;;
  credentials.json|credentials.yaml|secrets.yaml|secrets.json|*.pem|*.key|id_rsa|id_ed25519)
    echo "WARNING: Editing credential/key file $file_path — handle with care." >&2
    ;;
esac

exit 0
