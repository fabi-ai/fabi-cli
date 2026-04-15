# Fabi CLI

Command-line interface for [Fabi](https://fabi.ai) — chat with your data, build React dashboards, preview them, and publish them.

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
fabi smartbook new --title "Sales Analysis"
fabi chat "What tables do I have?"
```

## Commands

| Command | Description |
|---------|-------------|
| `fabi login` | Authenticate with Fabi (opens browser) |
| `fabi context` | Download data source semantics and instructions as Markdown |
| `fabi api GET /api/v2/...` | Proxy a Fabi API request with the current CLI session |
| `fabi logout` | Log out of Fabi |
| `fabi smartbook list -n 10` | List recent Smartbooks |
| `fabi smartbook current` | Show the current Smartbook and local workspace |
| `fabi smartbook new --title "name"` | Create a new Smartbook and local workspace |
| `fabi smartbook resume --notebook-uuid <uuid>` | Switch to a Smartbook and download its deployed app into `dist/` locally |
| `fabi chat "prompt"` | Conversational data analysis in the current Smartbook |
| `fabi app build` | Write the current Smartbook app manifest to the local workspace |
| `fabi app preview ./dist` | Upload a built local app as the current Smartbook preview |
| `fabi app publish` | Publish the current app preview as a report |
| `fabi install-skill` | Install the /fabi skill for Claude Code and Codex |

## Examples

```bash
# Understand your data first
fabi context -o fabi-context.md

# Create or resume a Smartbook first
fabi smartbook new --title "Revenue Trends"
fabi smartbook list
fabi smartbook current
fabi smartbook resume --notebook-uuid <notebook_uuid>

# Data analysis
fabi chat "What tables do I have?"
fabi chat "Show me revenue by month"

# Call Fabi backend APIs without managing auth headers manually
fabi api GET /api/v2/notebooks/<notebook_uuid>
fabi api POST /api/v2/notebooks/<notebook_uuid>/query --data '{"sql":"SELECT * FROM dataframe_name"}'

# Log out
fabi logout

# Build and preview a dashboard
fabi app build
# ... create your app files in the current workspace (for example `./my-app`) ...
bun run build
fabi app preview ./dist

# Publish the current app preview as a report
fabi app publish

# Target a different Smartbook explicitly
fabi app build --notebook-uuid <notebook_uuid> -o manifest.json
fabi app preview ./dist --notebook-uuid <notebook_uuid>
```

## Configuration

Config is stored at `~/.fabi/cli.json`.

`fabi api` automatically injects the proper authorization header for authenticated Fabi API calls.

Smartbook-local files live under:

```bash
~/.fabi/notebooks/<notebook_uuid>
```

Typical local files:

- `manifest.md` from `fabi app build`
- your app source files directly in that Smartbook directory
- downloaded deployed app files in `dist/` from `fabi smartbook resume`

`fabi smartbook new` and `fabi smartbook resume` select the current Smartbook workspace. `fabi app build`, `fabi app preview`, and `fabi app publish` use that workspace by default.

Recommended convention:

- keep your app source files directly under `~/.fabi/notebooks/<notebook_uuid>/`
- keep build output like `dist/` there too

Passing `--notebook-uuid` to `fabi app build`, `fabi app preview`, or `fabi app publish` is a one-off override. It does not switch the current Smartbook workspace.

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
