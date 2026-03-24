#!/usr/bin/env bash
set -euo pipefail

REPO="fabi-ai/fabi-cli"
INSTALL_ROOT="${HOME}/.fabi"
BIN_DIR="${HOME}/.local/bin"
VENV_DIR="${INSTALL_ROOT}/venv"
RELEASE_API_URL="https://api.github.com/repos/${REPO}/releases/latest"

resolve_wheel_url() {
  local release_json
  local wheel_url

  release_json="$(curl -fsSL "${RELEASE_API_URL}")"
  wheel_url="$(
    RELEASE_JSON="${release_json}" python3 - <<'PY'
import json
import os

release = json.loads(os.environ["RELEASE_JSON"])
for asset in release.get("assets", []):
    url = asset.get("browser_download_url", "")
    name = asset.get("name", "")
    if name.endswith(".whl") and "py3-none-any" in name:
        print(url)
        break
PY
  )"

  if [ -z "${wheel_url}" ]; then
    echo "Could not find a wheel asset in the latest release." >&2
    exit 1
  fi

  echo "${wheel_url}"
}

mkdir -p "${INSTALL_ROOT}" "${BIN_DIR}"

if [ ! -d "${VENV_DIR}" ]; then
  python3 -m venv "${VENV_DIR}"
fi

WHEEL_URL="$(resolve_wheel_url)"

"${VENV_DIR}/bin/python" -m pip install --upgrade pip >/dev/null
"${VENV_DIR}/bin/python" -m pip install --upgrade "${WHEEL_URL}"

ln -sf "${VENV_DIR}/bin/fabi" "${BIN_DIR}/fabi"

cat <<EOF
Installed fabi to ${BIN_DIR}/fabi

If ${BIN_DIR} is not on your PATH, add:
  export PATH="${BIN_DIR}:\$PATH"
EOF
