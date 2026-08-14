{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.devbox.attic.server;
in
{
  options.devbox.attic.server = {
    enable = lib.mkEnableOption "a persistent Attic binary-cache server";

    listen = lib.mkOption {
      type = lib.types.str;
      default = "[::]:8080";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
    };

    environmentFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/atticd/atticd.env";
      description = "Persistent root-only secret containing ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64";
    };

    databaseUrl = lib.mkOption {
      type = lib.types.str;
      default = "sqlite:///var/lib/atticd/server.db?mode=rwc";
    };

    storagePath = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/atticd/storage";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.attic-client ];

    services.atticd = {
      enable = true;
      environmentFile = cfg.environmentFile;
      settings = {
        listen = cfg.listen;
        database.url = cfg.databaseUrl;
        storage = {
          type = "local";
          path = cfg.storagePath;
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
