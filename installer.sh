#!/usr/bin/env bash
set -euo pipefail

REPO="fabi-ai/fabi-cli"
RELEASE_DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download"

resolve_bin_dir() {
  if [[ -d "/usr/local/bin" && -w "/usr/local/bin" ]]; then
    echo "/usr/local/bin"
    return
  fi

  if [[ ! -e "/usr/local/bin" ]]; then
    local parent_dir
    parent_dir="$(dirname "/usr/local/bin")"
    if [[ -w "${parent_dir}" ]]; then
      mkdir -p "/usr/local/bin"
      echo "/usr/local/bin"
      return
    fi
  fi

  echo "${HOME}/.local/bin"
}

resolve_asset_name() {
  local os
  local arch

  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m)"

  case "${os}" in
    linux)
      os="linux"
      ;;
    darwin)
      os="darwin"
      ;;
    *)
      echo "Unsupported operating system: ${os}" >&2
      exit 1
      ;;
  esac

  case "${arch}" in
    x86_64|amd64)
      arch="amd64"
      ;;
    arm64|aarch64)
      arch="arm64"
      ;;
    *)
      echo "Unsupported architecture: ${arch}" >&2
      exit 1
      ;;
  esac

  echo "fabi-${os}-${arch}"
}

BIN_DIR="$(resolve_bin_dir)"
mkdir -p "${BIN_DIR}"

ASSET_NAME="$(resolve_asset_name)"
ASSET_URL="${RELEASE_DOWNLOAD_URL}/${ASSET_NAME}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

curl -fsSL "${ASSET_URL}" -o "${TMP_DIR}/fabi"
chmod +x "${TMP_DIR}/fabi"
mv "${TMP_DIR}/fabi" "${BIN_DIR}/fabi"

if [[ "${BIN_DIR}" == "/usr/local/bin" ]]; then
  cat <<EOF
Installed fabi to ${BIN_DIR}/fabi
EOF
else
  cat <<EOF
Installed fabi to ${BIN_DIR}/fabi

If ${BIN_DIR} is not on your PATH, add:
  export PATH="${BIN_DIR}:\$PATH"
EOF
fi
