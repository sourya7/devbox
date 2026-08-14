#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
INSTANCE=${DEVBOX_INSTANCE:-devbox}

if [[ "$ROOT" != "$HOME/Dev/"* ]]; then
  echo "devbox must be checked out below $HOME/Dev because lima.yaml mounts ~/Dev" >&2
  exit 1
fi

# Lima's default mount point mirrors the expanded host path in the guest.
GUEST_ROOT="$ROOT"
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
