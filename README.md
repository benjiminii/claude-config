# Claude Code config

Personal Claude Code configuration synced across devices: skills, hooks, settings, and project instructions.

## How it works

Claude Code stores config under a directory (default: `~/.claude`). The env var **`CLAUDE_CONFIG_DIR`** points it at a different folder — each folder is a fully separate profile:

| Isolated per profile | |
|---|---|
| Login / subscription | different Anthropic account |
| `settings.json` | hooks, plugins, model |
| `skills/`, `hooks/`, `CLAUDE.md` | custom setup |
| Chat history, plugin caches | local only (gitignored) |

This repo syncs the **portable config**. Runtime data stays on each machine.

## What's tracked

| Path | Purpose |
|------|---------|
| `CLAUDE.md` | Global instructions for Claude Code |
| `settings.json` | Model, hooks, plugins, status line |
| `hooks/` | Caveman mode hooks and status line |
| `skills/` | Custom and installed skills |
| `install.sh` | Fix hook paths after clone (supports named profiles) |

## First device — push to GitHub

1. Create an empty repo at [github.com/new](https://github.com/new) (e.g. `claude-config`, private recommended, no README).
2. Push:

```bash
cd ~/.claude
git remote add origin git@github.com:benjiminii/claude-config.git   # skip if already set
git push -u origin main
```

## New device — personal profile

```bash
git clone git@github.com:benjiminii/claude-config.git ~/.claude
cd ~/.claude
./install.sh
claude    # log in with your personal Anthropic account
```

Plugins listed in `settings.json` → `enabledPlugins` reinstall on first run. If any are missing:

```bash
claude plugin install superpowers@claude-plugins-official
```

### Already have a local `~/.claude`

Pull only the tracked config into your existing directory:

```bash
cd ~/.claude
git init
git remote add origin git@github.com:benjiminii/claude-config.git
git fetch origin
git checkout origin/main -- CLAUDE.md settings.json hooks skills README.md install.sh .gitignore
./install.sh
```

## Multiple profiles (work, school, etc.)

Use separate config directories for different Anthropic accounts. Clone this repo into each one:

```bash
# work
git clone git@github.com:benjiminii/claude-config.git ~/.claude-work
CLAUDE_DIR=~/.claude-work ~/.claude-work/install.sh
CLAUDE_CONFIG_DIR=~/.claude-work claude    # log in with work account

# school
git clone git@github.com:benjiminii/claude-config.git ~/.claude-school
CLAUDE_DIR=~/.claude-school ~/.claude-school/install.sh
CLAUDE_CONFIG_DIR=~/.claude-school claude  # log in with school account
```

Each profile keeps its own login in `~/.claude-work/.claude.json`, etc. Customize `settings.json` per profile independently (e.g. disable caveman at work, different plugins at school).

### Add git config to an existing profile dir

If you already have `~/.claude-work` but no skills/hooks from this repo:

```bash
cd ~/.claude-work
git init && git remote add origin git@github.com:benjiminii/claude-config.git
git fetch
# .gitignore first — without it, git shows every runtime file as untracked
git checkout origin/main -- .gitignore
git checkout origin/main -- skills hooks CLAUDE.md install.sh
CLAUDE_DIR=~/.claude-work ./install.sh
```

> **Don't `git add -A` before `.gitignore` is in place.** Your profile dir already has chat history, plugins, sessions, etc. The gitignore hides those. Only the config files (skills, hooks, CLAUDE.md) should be tracked.

Your local `settings.json` is intentionally **not** checked out — work/school profiles often differ from personal. Keep your existing one, or pull it explicitly if you want them identical:

```bash
git checkout origin/main -- settings.json   # only if you want to overwrite
```

## Shell setup (`~/.zshrc`)

Add profile commands so you don't have to set env vars manually:

```bash
# ── Claude Code profiles ──────────────────────────────────────

claude-personal() {
  CLAUDE_CONFIG_DIR="$HOME/.claude" command claude "$@"
}

claude-work() {
  CLAUDE_CONFIG_DIR="$HOME/.claude-work" command claude "$@"
}

claude-school() {
  CLAUDE_CONFIG_DIR="$HOME/.claude-school" command claude "$@"
}

alias claude='claude-personal'   # optional: default to personal
```

Reload and use:

```bash
source ~/.zshrc

claude              # personal
claude-work         # work account + ~/.claude-work
claude-school       # school account + ~/.claude-school
claude-work -p "fix this bug"   # args pass through
```

### Bootstrap helper (optional)

One-command setup for a new profile on a fresh machine:

```bash
claude-profile-init() {
  local name="$1"
  local dir="$HOME/.claude-${name}"
  local repo="${2:-git@github.com:benjiminii/claude-config.git}"

  if [[ -z "$name" ]]; then
    echo "Usage: claude-profile-init <name> [git-repo-url]"
    echo "Example: claude-profile-init work"
    return 1
  fi

  if [[ -d "$dir" ]]; then
    echo "Already exists: $dir"
    return 1
  fi

  git clone "$repo" "$dir"
  CLAUDE_DIR="$dir" "$dir/install.sh"
  echo "Done. Log in with: CLAUDE_CONFIG_DIR=$dir claude"
}
```

```bash
claude-profile-init work
claude-work
```

## Quick reference

| Command | Config dir | Account |
|---------|-----------|---------|
| `claude` / `claude-personal` | `~/.claude` | personal |
| `claude-work` | `~/.claude-work` | work |
| `claude-school` | `~/.claude-school` | school |

| Task | Command |
|------|---------|
| Pull config into a profile dir | see below — don't use `git pull` |
| Push config changes | `cd ~/.claude && git add -A && git commit -m "..." && git push` |
| Fix hook paths after clone | `CLAUDE_DIR=~/.claude-work ~/.claude-work/install.sh` |

### Sync updates into a profile dir (`~/.claude-work`, etc.)

Don't use `git pull` here — it fails when config files already exist as untracked files, and it would overwrite your local `settings.json`.

```bash
cd ~/.claude-work
git fetch origin
git checkout origin/main -- .gitignore skills hooks CLAUDE.md install.sh
CLAUDE_DIR=~/.claude-work ./install.sh
```

This updates shared config while keeping your work-specific `settings.json`.

## Day-to-day sync

**Personal profile** (`~/.claude`) — edit, commit, and push here:

```bash
cd ~/.claude
git pull
# edit skills, hooks, settings...
git add -A && git commit -m "update graphify skill" && git push
```

**Work/school profiles** — pull updates from the repo (don't commit from these dirs):

```bash
cd ~/.claude-work
git fetch origin
git checkout origin/main -- .gitignore skills hooks CLAUDE.md install.sh
CLAUDE_DIR=~/.claude-work ./install.sh
```

## Plugins

Plugin *enablement* is in `settings.json`. Plugin binaries are not in this repo — Claude Code reinstalls them on each machine from the official marketplace and `extraKnownMarketplaces`.

## Skills with external sources

Some skills were originally installed from GitHub (`caveman`, `find-skills`). Copies live in `skills/` for portability. To update from upstream, reinstall via the find-skills workflow or pull from the source repo.
