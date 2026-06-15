#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

# Rewrite machine-specific paths in settings.json
if [[ -f "$CLAUDE_DIR/settings.json" ]]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s|/Users/[^/]*/.claude|$HOME/.claude|g" "$CLAUDE_DIR/settings.json"
  else
    sed -i "s|/Users/[^/]*/.claude|$HOME/.claude|g" "$CLAUDE_DIR/settings.json"
  fi
fi

chmod +x "$CLAUDE_DIR/hooks/caveman-statusline.sh" 2>/dev/null || true

echo "Configured Claude Code at $CLAUDE_DIR"
echo "Restart Claude Code to pick up hook and settings changes."
