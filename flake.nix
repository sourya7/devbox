{
  description = "Declarative NixOS development VM for Lima";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-lima = {
      url = "github:nixos-lima/nixos-lima/v0.2.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nixos-lima,
      home-manager,
      ...
    }:
    let
      mkDev =
        system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            nixos-lima.nixosModules.lima
            home-manager.nixosModules.home-manager
            ./modules/lima-guest.nix
            ./modules/dev-tools.nix
            ./modules/attic-client.nix
            ./config/attic-client.nix
          ];
        };

      mkCache =
        system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            nixos-lima.nixosModules.lima
            ./modules/lima-guest.nix
            ./modules/attic-server.nix
            {
              networking.hostName = "attic-cache";
              devbox.attic.server.enable = true;
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        dev-aarch64 = mkDev "aarch64-linux";
        dev-x86_64 = mkDev "x86_64-linux";
        attic-aarch64 = mkCache "aarch64-linux";
        attic-x86_64 = mkCache "x86_64-linux";
      };

      formatter = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ] (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
