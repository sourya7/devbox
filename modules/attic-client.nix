{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devbox.attic.client;
in
{
  options.devbox.attic.client = {
    enable = lib.mkEnableOption "the Attic binary-cache client";

    endpoint = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Full substituter URL, including the cache name";
      example = "https://attic.example.net/dev";
    };

    publicKey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Attic cache public signing key";
    };

    serverName = lib.mkOption {
      type = lib.types.str;
      default = "devbox";
    };

    serverEndpoint = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Attic API endpoint without the cache-name suffix";
      example = "https://attic.example.net";
    };

    cacheName = lib.mkOption {
      type = lib.types.str;
      default = "dev";
    };

    fallback = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Build locally when the optional cache cannot substitute a path";
    };

    push = {
      enable = lib.mkEnableOption "automatic upload of newly-built store paths";

      tokenFile = lib.mkOption {
        type = lib.types.str;
        default = "/run/secrets/attic-token";
        description = "Runtime path containing an Attic push token";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.endpoint != "";
        message = "devbox.attic.client.endpoint must be set when the Attic client is enabled";
      }
      {
        assertion = cfg.publicKey != "";
        message = "devbox.attic.client.publicKey must be set when the Attic client is enabled";
      }
      {
        assertion = !cfg.push.enable || cfg.serverEndpoint != "";
        message = "devbox.attic.client.serverEndpoint must be set when Attic pushing is enabled";
      }
    ];

    environment.systemPackages = [ pkgs.attic-client ];

    nix.settings = {
      extra-substituters = [ cfg.endpoint ];
      extra-trusted-public-keys = [ cfg.publicKey ];
      fallback = cfg.fallback;
      connect-timeout = 3;
      stalled-download-timeout = 15;
    };

    environment.etc."attic-watch/attic/config.toml" = lib.mkIf cfg.push.enable {
      mode = "0600";
      text = ''
        default-server = "${cfg.serverName}"

        [servers.${cfg.serverName}]
        endpoint = "${cfg.serverEndpoint}"
        token-file = "${cfg.push.tokenFile}"
      '';
    };

    systemd.services.attic-watch-store = lib.mkIf cfg.push.enable {
      description = "Upload new Nix store paths to Attic";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      environment.XDG_CONFIG_HOME = "/etc/attic-watch";
      serviceConfig = {
        ExecStart = "${pkgs.attic-client}/bin/attic watch-store ${cfg.serverName}:${cfg.cacheName}";
        Restart = "on-failure";
        RestartSec = 10;
      };
    };
  };
}
