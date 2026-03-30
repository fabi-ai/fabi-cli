# Fabi CLI

Command-line interface for [Fabi](https://fabi.ai) — chat with your data, build React dashboards, and deploy them.

## Install

```bash
curl -fsSL https://github.com/fabi-ai/fabi-cli/releases/latest/download/installer.sh | bash
```

## Quick Start

```bash
fabi login
fabi chat "What tables do I have?"
```

## AI Coding Setup

Use `/fabi` in Claude Code or Codex to get AI-assisted dashboard building.

### Claude Code / Codex

```
Install the Fabi skill: run `fabi install-skill` to register the /fabi skill,
then run `fabi login` to authenticate.
```

## Commands

| Command | Description |
|---------|-------------|
| `fabi login` | Authenticate with Fabi (opens browser) |
| `fabi chat "prompt"` | Conversational data analysis |
| `fabi build-app <uuid>` | Fetch notebook manifest for dashboard building |
| `fabi deploy ./dist` | Deploy a built React app to Fabi |
| `fabi install-skill` | Install the /fabi skill for Claude Code and Codex |

## Examples

```bash
# Data analysis
fabi chat "What tables do I have?"
fabi chat "Show me revenue by month"
fabi chat -n "Start a fresh session"

# Build and deploy a dashboard
fabi build-app <notebook_uuid> -o manifest.json
# ... build your React app ...
bun run build
fabi deploy ./dist
```

## Configuration

Config is stored at `~/.config/fabi/cli.json`.

## Release Assets

Expected release assets:

- `installer.sh`
- `SKILL.md`
- `fabi-linux-amd64`
- `fabi-linux-arm64`
- `fabi-darwin-amd64`
- `fabi-darwin-arm64`
