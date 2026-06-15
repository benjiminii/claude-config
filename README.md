# Claude Code config

Personal Claude Code configuration synced across devices: skills, hooks, settings, and project instructions.

## What's tracked

| Path | Purpose |
|------|---------|
| `CLAUDE.md` | Global instructions for Claude Code |
| `settings.json` | Model, hooks, plugins, status line |
| `hooks/` | Caveman mode hooks and status line |
| `skills/` | Custom and installed skills |

Runtime data (chat history, plugin caches, sessions) stays local and is gitignored.

## Setup on a new device

### Option A — use this repo as `~/.claude` (recommended)

If `~/.claude` doesn't exist yet or you're fine merging:

```bash
git clone git@github.com:YOUR_USER/claude-config.git ~/.claude
cd ~/.claude
./install.sh
```

Then open Claude Code and install plugins listed in `settings.json` → `enabledPlugins` (Claude will prompt or use `/plugin`).

### Option B — already have a local `~/.claude`

Pull only the tracked config into your existing directory:

```bash
cd ~/.claude
git init
git remote add origin git@github.com:YOUR_USER/claude-config.git
git fetch origin
git checkout origin/main -- CLAUDE.md settings.json hooks skills README.md install.sh .gitignore
./install.sh
```

## Day-to-day sync

```bash
cd ~/.claude
git pull    # get changes from other devices
# ... edit skills, hooks, settings ...
git add -A && git commit -m "update graphify skill" && git push
```

## Plugins

Plugin *enablement* is in `settings.json`. Plugin binaries are not in this repo — Claude Code reinstalls them on each machine from the official marketplace and `extraKnownMarketplaces`.

After cloning on a new device, run Claude Code once; it should restore enabled plugins automatically. If not:

```bash
claude plugin install skill-creator@claude-plugins-official
# etc.
```

## Skills with external sources

Some skills were originally installed from GitHub (`caveman`, `find-skills`). Copies live in `skills/` for portability. To update from upstream, reinstall via the find-skills workflow or pull from the source repo.
