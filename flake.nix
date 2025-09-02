{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {nixpkgs, ...}: let
    inherit (nixpkgs) lib;

    mkSystem = hostName:
      lib.nixosSystem {
        specialArgs = {inherit inputs hostName;};
        modules = [./modules ./hosts/${hostName}];
      };
    hosts = lib.trivial.pipe (builtins.readDir ./hosts) [(lib.filterAttrs (_: value: value == "directory")) builtins.attrNames];
  in {
    nixosConfigurations = nixpkgs.lib.genAttrs hosts mkSystem;
  };
}
