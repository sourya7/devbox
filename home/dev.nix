{ lib, pkgs, ... }:
{
  home = {
    username = "dev";
    # The account is created by lima-init rather than users.users, so override
    # the NixOS Home Manager module's /var/empty fallback.
    homeDirectory = lib.mkForce "/home/dev.guest";
    stateVersion = "26.05";

    packages = with pkgs; [
      fd
      pi-coding-agent
      ripgrep
    ];

    sessionVariables = {
      EDITOR = "emacsclient -t";
      VISUAL = "emacsclient -t";
    };
  };

  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
      shellAliases = {
        e = "emacsclient -t";
        ll = "ls -alh";
      };
    };

    git = {
      enable = true;
      settings.init.defaultBranch = "main";
    };
  };

  services.emacs = {
    enable = true;
    client.enable = true;
  };

  # Public Pi behavior can be versioned. Credentials, sessions, and provider
  # state remain mutable alongside this managed file in ~/.pi/agent.
  home.file.".pi/agent/AGENTS.md".source = ../pi/AGENTS.md;
}
