# fabi-cli

Public distribution repo for the Fabi CLI.

This repo does not contain the CLI source code. The source stays in Fabi's
private backend repository. Public GitHub releases here contain only installable
artifacts built from that private source.

## Install

```bash
curl -fsSL https://github.com/fabi-ai/fabi-cli/releases/latest/download/installer.sh | bash
```

This installs `fabi` into `~/.local/bin/fabi`.

## Release assets

Expected release assets:

- `installer.sh`
- `fabi_cli-py3-none-any.whl`

`installer.sh` downloads the latest published wheel from this repo's Releases
page and installs it into `~/.fabi/venv`.
