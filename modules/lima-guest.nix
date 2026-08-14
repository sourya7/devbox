{
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  networking.hostName = lib.mkDefault "devbox";

  # nixos-lima creates the Lima-selected user during boot.
  users.mutableUsers = true;
  services.lima.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  fileSystems."/boot" = {
    device = lib.mkForce "/dev/vda1";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
      "discard"
    ];
  };

  environment.systemPackages = with pkgs; [
    gitMinimal
    vim
  ];

  system.stateVersion = "26.05";
}
