{ pkgs, ... }:
{
  networking.hostName = "devbox";

  # lima-init creates this account with the host UID before NixOS activation.
  # Declaring its role/group satisfies the Home Manager NixOS module while
  # leaving the UID unset so Lima remains authoritative for it.
  users.groups.dev = { };
  users.users.dev = {
    isNormalUser = true;
    group = "dev";
    home = "/home/dev.guest";
    extraGroups = [
      "users"
      "wheel"
    ];
    shell = pkgs.fish;
  };

  # Register Fish as a login shell and install its system integration.
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    bubblewrap
    socat
    python3
    jujutsu
    bashInteractive
    bat
    coreutils
    curl
    emacs
    fd
    gcc
    ghostty.terminfo
    gnumake
    jq
    just
    kitty.terminfo
    nodejs
    pkg-config
    ripgrep
    tmux
    tree
    unzip
    wget
  ];

  # The Lima user is created imperatively before this activation. Home Manager
  # can then manage its environment as part of the same NixOS generation.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users.dev = import ../home/dev.nix;
  };
}
