#!/usr/bin/env bash
# Sync portable Claude Code config from GitHub into any profile directory.
#
# Usage:
#   ./sync-profile.sh                    # sync into ~/.claude-work (default)
#   ./sync-profile.sh ~/.claude-school   # sync into another profile
#   ./sync-profile.sh --with-settings    # also overwrite settings.json (plugins, hooks config)
#
set -euo pipefail

REPO="${CLAUDE_CONFIG_REPO:-git@github.com:benjiminii/claude-config.git}"
BRANCH="${CLAUDE_CONFIG_BRANCH:-main}"
WITH_SETTINGS=false
TARGET=""

for arg in "$@"; do
  case "$arg" in
    --with-settings) WITH_SETTINGS=true ;;
    -h|--help)
      sed -n '2,8p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *) TARGET="$arg" ;;
  esac
done

TARGET="${TARGET:-$HOME/.claude-work}"
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

SYNC_PATHS=(.gitignore CLAUDE.md hooks skills install.sh sync-profile.sh)
$WITH_SETTINGS && SYNC_PATHS+=(settings.json)

cd "$TARGET"

if [[ ! -d .git ]]; then
  git init -q
  git remote add origin "$REPO" 2>/dev/null || git remote set-url origin "$REPO"
fi

git fetch origin "$BRANCH" --quiet
git checkout "origin/$BRANCH" -- "${SYNC_PATHS[@]}"
git checkout "origin/$BRANCH" -- rules 2>/dev/null || true

CLAUDE_DIR="$TARGET" "$TARGET/install.sh"

echo ""
echo "Synced into $TARGET"
echo "  skills/     → /graphify, /caveman, find-skills, etc."
echo "  hooks/      → caveman auto-activation scripts"
echo "  CLAUDE.md   → global instructions"
if $WITH_SETTINGS; then
  echo "  settings.json → plugins list + hook wiring (paths fixed by install.sh)"
else
  echo "  settings.json → kept your local copy (use --with-settings to overwrite)"
fi
echo ""
echo "Log in once per account: CLAUDE_CONFIG_DIR=$TARGET claude"
