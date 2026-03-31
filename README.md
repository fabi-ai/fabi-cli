# Fabi CLI

Command-line interface for [Fabi](https://fabi.ai) — chat with your data, build React dashboards, and deploy them.

## Install fabi-cli + skill in Claude Code or Codex

Open Claude Code or Codex and paste this. The agent does the rest.

```
Install fabi-cli: run `curl -fsSL https://github.com/fabi-ai/fabi-cli/releases/latest/download/installer.sh | bash` to install the CLI, then run `fabi install-skill` to register the /fabi skill, and finally run `fabi login` to authenticate.
```

### What `install-skill` does

`fabi install-skill` downloads `SKILL.md` from the latest `fabi-cli` release and installs it to:

- `~/.claude/skills/fabi/SKILL.md` (Claude Code)
- `~/.codex/skills/fabi/SKILL.md` (Codex)

### Install fabi-cli

```bash
curl -fsSL https://github.com/fabi-ai/fabi-cli/releases/latest/download/installer.sh | bash
```

You are good to go!

---

## Quick Start

```bash
fabi login
fabi chat "What tables do I have?"
```

## Commands

| Command | Description |
|---------|-------------|
| `fabi login` | Authenticate with Fabi (opens browser) |
| `fabi chat "prompt"` | Conversational data analysis |
| `fabi build-app` | Fetch the current Smartbook manifest for dashboard building |
| `fabi deploy ./dist` | Deploy a built local app to the current Smartbook |
| `fabi install-skill` | Install the /fabi skill for Claude Code and Codex |

## Examples

```bash
# Data analysis
fabi chat "What tables do I have?"
fabi chat "Show me revenue by month"
fabi chat -n "Start a fresh session"

# Build and deploy a dashboard
fabi build-app -o manifest.json
# ... build your React app ...
bun run build
fabi deploy ./dist

# Target a different Smartbook explicitly
fabi build-app --notebook-uuid <notebook_uuid> -o manifest.json
fabi deploy ./dist --notebook-uuid <notebook_uuid>
```

## Configuration

Config is stored at `~/.config/fabi/cli.json`.

## Uninstall

Remove the CLI binary:

```bash
rm -f /usr/local/bin/fabi
rm -f ~/.local/bin/fabi
```

Remove local CLI config:

```bash
rm -f ~/.config/fabi/cli.json
```

Remove the installed skill files:

```bash
rm -rf ~/.claude/skills/fabi
rm -rf ~/.codex/skills/fabi
```

## Release Assets

Expected release assets:

- `installer.sh`
- `SKILL.md`
- `fabi-linux-amd64`
- `fabi-linux-arm64`
- `fabi-darwin-amd64`
- `fabi-darwin-arm64`
