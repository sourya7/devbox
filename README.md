# devbox

A reproducible NixOS development VM managed by Lima. NixOS defines system tools,
Home Manager defines the `dev` user's environment, and Attic support is optional.

## Included tools

- Emacs with a user systemd service
- Pi coding agent (`pkgs.pi-coding-agent`)
- ripgrep, fd, Git, tmux, jq, bat, Node.js, GCC, Make, and common CLI tools

Versions are pinned by `flake.lock`.

## Prerequisites

- Lima 2.x
- Git
- The repository checked out anywhere below `~/Dev`
- Nix is only required on the host for updating or checking the flake; the VM
  image already contains Nix.

The template assigns the fixed guest user `dev` and mounts host `~/Dev` writable
at `/home/dev.guest/Dev`. Source remains on the host, while the VM can be replaced.

## Start a development VM

```bash
./scripts/bootstrap
```

This creates/starts the `devbox` Lima instance, detects its architecture, and
applies either `dev-aarch64` or `dev-x86_64`.

Subsequent configuration changes can be applied with:

```bash
./scripts/rebuild
```

Enter the VM with:

```bash
limactl shell devbox
```

Override the instance name when needed:

```bash
DEVBOX_INSTANCE=work-devbox ./scripts/bootstrap
```

## Configuration layout

- `lima.yaml`: VM resources, image, identity, and host mounts
- `modules/lima-guest.nix`: NixOS/Lima boot integration
- `modules/dev-tools.nix`: system development tools and Home Manager wiring
- `home/dev.nix`: user tools, Emacs, shell, and Pi
- `pi/AGENTS.md`: public Pi instructions managed by Home Manager
- `config/attic-client.nix`: optional cache endpoint and public key
- `modules/attic-{client,server}.nix`: cache implementation

Pi credentials and sessions remain mutable under `~/.pi/agent`; they are not
stored in this repository.

## Enable an existing Attic cache

Get the endpoint and public key from:

```bash
attic cache info <cache>
```

Edit `config/attic-client.nix`:

```nix
{
  devbox.attic.client = {
    enable = true;
    endpoint = "https://attic.example.net/dev";
    publicKey = "dev:...";

    serverName = "devbox";
    serverEndpoint = "https://attic.example.net";
    cacheName = "dev";

    push.enable = false;
  };
}
```

Then run `./scripts/rebuild`. The optional substituter has short connection
timeouts and `fallback = true`, so Nix can build locally when it is unavailable.
`cache.nixos.org` remains enabled.

The endpoint and public key are safe to commit. Never put an Attic token in a
Nix file because it will be copied into the world-readable Nix store.

### Automatic push

After placing a restricted push token at `/run/secrets/attic-token`, set:

```nix
push.enable = true;
```

This enables `attic watch-store`. Prefer explicit pushes or CI initially:

```bash
attic push dev ./result
attic push dev /run/current-system
```

## Optional local Attic server

A separate persistent Lima instance is preferable to running `atticd` inside
the disposable development VM:

```bash
./scripts/bootstrap-cache
```

The script creates `attic-cache`, generates a root-only JWT secret at
`/var/lib/atticd/atticd.env`, and applies the architecture-appropriate
`attic-*` configuration. SQLite and cache data live below `/var/lib/atticd` on
the cache VM's persistent root disk.

The server is forwarded as:

- host: `http://localhost:18080`
- other Lima guests: `http://host.lima.internal:18080`

The forwarding rule binds all host interfaces so another guest can reach it.
Use the host firewall and do not expose this unencrypted endpoint to an
untrusted LAN. For sharing across physical machines, deploy Attic behind HTTPS
on a persistent server instead.

On first start, enter the cache VM and use `atticd-atticadm`/`attic` to create an
admin token and cache following the [Attic tutorial](https://docs.attic.rs/tutorial.html).
After creating a public-read cache named `dev`, configure the development VM
approximately as:

```nix
endpoint = "http://host.lima.internal:18080/dev";
serverEndpoint = "http://host.lima.internal:18080";
```

Do not delete the `attic-cache` instance unless losing the local cache is
acceptable. `limactl stop attic-cache` preserves it.

## Validate and update

```bash
nix flake check --no-build
nix flake update
nix fmt
```

Review `flake.lock` changes before rebuilding. Binary artifacts are architecture
specific, so shared caches should build both `aarch64-linux` and `x86_64-linux`
when both kinds of development machine are used.
