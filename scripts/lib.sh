#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
INSTANCE=${DEVBOX_INSTANCE:-devbox}

if [[ "$ROOT" != "$HOME/Dev/"* ]]; then
  echo "devbox must be checked out below $HOME/Dev because lima.yaml mounts ~/Dev" >&2
  exit 1
fi

GUEST_ROOT="/home/dev.guest/Dev/${ROOT#"$HOME/Dev/"}"
export ROOT INSTANCE GUEST_ROOT

guest_configuration() {
  local machine
  machine=$(limactl shell "$INSTANCE" -- uname -m)
  case "$machine" in
    aarch64|arm64) printf '%s\n' dev-aarch64 ;;
    x86_64|amd64) printf '%s\n' dev-x86_64 ;;
    *)
      echo "Unsupported guest architecture: $machine" >&2
      return 1
      ;;
  esac
}
