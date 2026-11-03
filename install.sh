#!/usr/bin/env bash
# Copies the PBR agents and skills into ~/.claude (Claude Code user scope).
set -e
here="$(cd "$(dirname "$0")" && pwd)"; dest="${CLAUDE_HOME:-$HOME/.claude}"
mkdir -p "$dest/agents" "$dest/skills"
for f in "$here"/agents/*.md; do cp -i "$f" "$dest/agents/"; done
for d in "$here"/skills/*/; do mkdir -p "$dest/skills/$(basename "$d")"; cp -i "$d"SKILL.md "$dest/skills/$(basename "$d")/"; done
echo "Installed to $dest. Restart Claude Code."
