{ lib, pkgs, ... }:
let
  zellijChooseTree = pkgs.fetchurl {
    name = "zellij-choose-tree-0.4.2.wasm";
    url = "https://github.com/laperlej/zellij-choose-tree/releases/download/v0.4.2/zellij-choose-tree.wasm";
    hash = "sha256-OGHLzCM9wg0CLm5SSr3bmElcciBIqamalQjgkTuzAeg=";
  };
in
{
  home = {
    username = "dev";
    # The account is created by lima-init rather than users.users, so override
    # the NixOS Home Manager module's /var/empty fallback.
    homeDirectory = lib.mkForce "/home/dev.guest";
    stateVersion = "26.05";

    packages = with pkgs; [
      fd
      nushell
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

    bash.enable = true;

    mise = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      shellAliases = {
        ec = "emacsclient -a '' -t";
        ll = "ls -alh";
        ze = "zellij";
      };
    };

    git = {
      enable = true;
      settings.init.defaultBranch = "main";
      settings.user = {
        name = "Nix Devbox";
        email = "user@devbox";
      };
    };

    zellij = {
      enable = true;
      extraConfig = builtins.readFile ./zellij.kdl;
    };
  };

  xdg.configFile = {
    "zellij/plugins/zellij-choose-tree.wasm".source = zellijChooseTree;
    "zellij/plugins/zjstatus.wasm".source = pkgs.zellijPlugins.zjstatus;
  };

  services.emacs = {
    enable = true;
    client.enable = true;
  };

  # Public Pi behavior can be versioned. Credentials, sessions, and provider
  # state remain mutable alongside this managed file in ~/.pi/agent.
  home.file.".pi/agent/AGENTS.md".source = ../pi/AGENTS.md;
}
