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
    shell = pkgs.bashInteractive;
  };

  environment.systemPackages = with pkgs; [
    bashInteractive
    bat
    coreutils
    curl
    fd
    gcc
    gnumake
    jq
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
