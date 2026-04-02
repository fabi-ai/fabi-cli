# Fabi CLI

Command-line interface for [Fabi](https://fabi.ai) — chat with your data, build React dashboards, and deploy them.

## Install fabi-cli + skill in Claude Code or Codex

Open Claude Code or Codex and paste this. The agent does the rest.

```
Install fabi-cli: run `curl -fsSL https://github.com/fabi-ai/fabi-cli/releases/latest/download/installer.sh | bash` to install the CLI, then run `fabi install-skill` to register the /fabi skill, and finally run `fabi login` to authenticate.
```

You are good to go! The sections below are for reference only.

---

### What `install-skill` does

`fabi install-skill` downloads `SKILL.md` from the latest `fabi-cli` release and installs it to:

- `~/.claude/skills/fabi/SKILL.md` (Claude Code)
- `~/.codex/skills/fabi/SKILL.md` (Codex)

### Install fabi-cli

```bash
curl -fsSL https://github.com/fabi-ai/fabi-cli/releases/latest/download/installer.sh | bash
```

## Quick Start

```bash
fabi login
fabi smartbook new
fabi chat "What tables do I have?"
```

## Commands

| Command | Description |
|---------|-------------|
| `fabi login` | Authenticate with Fabi (opens browser) |
| `fabi context` | Download data source semantics and instructions as Markdown |
| `fabi api GET /api/v2/...` | Proxy a Fabi API request with the current CLI session |
| `fabi smartbook list -n 10` | List recent Smartbooks |
| `fabi smartbook current` | Show the current Smartbook and local workspace |
| `fabi smartbook new` | Create a new Smartbook and local workspace |
| `fabi smartbook resume --notebook-uuid <uuid>` | Switch to a Smartbook and download its deployed app into `dist/` locally |
| `fabi chat "prompt"` | Conversational data analysis in the current Smartbook |
| `fabi build-app` | Write the current Smartbook manifest to the local workspace |
| `fabi deploy ./dist` | Deploy a built local app to the current Smartbook |
| `fabi install-skill` | Install the /fabi skill for Claude Code and Codex |

## Examples

```bash
# Understand your data first
fabi context -o fabi-context.md

# Create or resume a Smartbook first
fabi smartbook new
fabi smartbook list
fabi smartbook current
fabi smartbook resume --notebook-uuid <notebook_uuid>

# Data analysis
fabi chat "What tables do I have?"
fabi chat "Show me revenue by month"

# Call Fabi backend APIs without managing auth headers manually
fabi api GET /api/v2/notebooks/<notebook_uuid>
fabi api POST /api/v2/notebooks/<notebook_uuid>/query --data '{"sql":"SELECT * FROM dataframe_name"}'

# Build and deploy a dashboard
fabi build-app
# ... create your app files directly under ~/.fabi/notebooks/<notebook_uuid>/ ...
bun run build
fabi deploy ./dist

# Target a different Smartbook explicitly
fabi build-app --notebook-uuid <notebook_uuid> -o manifest.json
fabi deploy ./dist --notebook-uuid <notebook_uuid>
```

## Configuration

Config is stored at `~/.fabi/cli.json`.

`fabi api` automatically injects the proper authorization header for authenticated Fabi API calls.

Smartbook-local files live under:

```bash
~/.fabi/notebooks/<notebook_uuid>
```

Typical local files:

- `manifest.json` from `fabi build-app`
- your app source files directly in that Smartbook directory
- downloaded deployed app files in `dist/` from `fabi smartbook resume`

`fabi smartbook new` and `fabi smartbook resume` select the current Smartbook workspace. `fabi build-app` and `fabi deploy` use that workspace by default.

Recommended convention:

- keep your app source files directly under `~/.fabi/notebooks/<notebook_uuid>/`
- keep build output like `dist/` there too

Passing `--notebook-uuid` to `fabi build-app` or `fabi deploy` is a one-off override. It does not switch the current Smartbook workspace.

## Uninstall

Remove the CLI binary:

```bash
rm -f /usr/local/bin/fabi
rm -f ~/.local/bin/fabi
```

Remove local CLI config:

```bash
rm -f ~/.fabi/cli.json
rm -rf ~/.fabi/notebooks
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
