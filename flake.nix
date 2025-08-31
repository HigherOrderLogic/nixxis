{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {nixpkgs, ...}: let
    mkSystem = hostName:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs hostName;
        };
        modules = [
          ./modules
          ./hosts/${hostName}
        ];
      };
    hosts = ["wsl"];
  in {
    nixosConfigurations = nixpkgs.lib.genAttrs hosts mkSystem;
  };
}
