set shell := ["bash", "-euo", "pipefail", "-c"]

instance := env_var_or_default("DEVBOX_INSTANCE", "devbox")
attic_instance := env_var_or_default("ATTIC_INSTANCE", "attic-cache")

# Show available recipes.
default:
    @just --list

# Create/start the development VM and apply its NixOS configuration.
bootstrap:
    DEVBOX_INSTANCE={{instance}} ./scripts/bootstrap

# Apply the current NixOS configuration to the development VM.
rebuild:
    DEVBOX_INSTANCE={{instance}} ./scripts/rebuild

# Open an interactive Fish shell at the repository mount in the development VM.
shell:
    source ./scripts/lib.sh; limactl shell --shell /run/current-system/sw/bin/fish --workdir "$GUEST_ROOT" "$INSTANCE"

# Run a command in the development VM, e.g. `just exec git status`.
exec *args:
    limactl shell {{instance}} -- {{args}}

# Start an existing development VM without rebuilding it.
start:
    limactl start {{instance}}

# Stop the development VM while preserving its disk.
stop:
    limactl stop {{instance}}

# Show Lima instances.
list:
    limactl list

# Evaluate all flake outputs inside the development VM without building them.
check:
    source ./scripts/lib.sh; limactl shell "$INSTANCE" -- nix flake check "path:$GUEST_ROOT" --no-build

# Update flake.lock inside the development VM.
update:
    source ./scripts/lib.sh; limactl shell "$INSTANCE" -- bash -lc 'cd "$1" && nix flake update "path:$1"' _ "$GUEST_ROOT"

# Format Nix files inside the development VM.
fmt:
    source ./scripts/lib.sh; limactl shell "$INSTANCE" -- bash -lc 'cd "$1" && nix fmt' _ "$GUEST_ROOT"

# Create/start the optional dedicated Attic cache VM.
cache-bootstrap:
    ATTIC_INSTANCE={{attic_instance}} ./scripts/bootstrap-cache

# Open an interactive shell in the Attic cache VM.
cache-shell:
    limactl shell {{attic_instance}}

# Start the Attic cache VM.
cache-start:
    limactl start {{attic_instance}}

# Stop the Attic cache VM while preserving its cache data.
cache-stop:
    limactl stop {{attic_instance}}
