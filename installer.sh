#!/usr/bin/env bash
set -euo pipefail

REPO="fabi-ai/fabi-cli"
INSTALL_ROOT="${HOME}/.fabi"
BIN_DIR="${HOME}/.local/bin"
VENV_DIR="${INSTALL_ROOT}/venv"
WHEEL_URL="https://github.com/${REPO}/releases/latest/download/fabi_cli-py3-none-any.whl"

mkdir -p "${INSTALL_ROOT}" "${BIN_DIR}"

if [ ! -d "${VENV_DIR}" ]; then
  python3 -m venv "${VENV_DIR}"
fi

"${VENV_DIR}/bin/python" -m pip install --upgrade pip >/dev/null
"${VENV_DIR}/bin/python" -m pip install --upgrade "${WHEEL_URL}"

ln -sf "${VENV_DIR}/bin/fabi" "${BIN_DIR}/fabi"

cat <<EOF
Installed fabi to ${BIN_DIR}/fabi

If ${BIN_DIR} is not on your PATH, add:
  export PATH="${BIN_DIR}:\$PATH"
EOF
