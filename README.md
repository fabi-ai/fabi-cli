# fabi-cli

CLI for Fabi.

## Install

```bash
curl -fsSL https://github.com/fabi-ai/fabi-cli/releases/latest/download/installer.sh | bash
```

This installs `fabi` into `~/.local/bin/fabi`.

## Usage

Log in:

```bash
fabi login
```

Start a chat:

```bash
fabi chat "can you build me a dashboard"
```

Another example:

```bash
fabi chat "what data do you have access to"
```

`fabi` stores local session state in `~/.config/fabi/cli.json`.

## Release Assets

Expected release assets:

- `installer.sh`
- `fabi_cli-<version>-py3-none-any.whl`

`installer.sh` downloads the latest published wheel from this repo's Releases
page and installs it into `~/.fabi/venv`.
