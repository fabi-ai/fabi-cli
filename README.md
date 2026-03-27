# fabi-cli

CLI for Fabi.

## Install

```bash
curl -fsSL https://github.com/fabi-ai/fabi-cli/releases/latest/download/installer.sh | bash
```

This downloads a standalone `fabi` executable into `~/.local/bin/fabi`.

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
- `fabi-linux-amd64`
- `fabi-linux-arm64`
- `fabi-darwin-amd64`
- `fabi-darwin-arm64`

`installer.sh` downloads the platform-specific executable from the latest
release and installs it into `~/.local/bin/fabi`.
