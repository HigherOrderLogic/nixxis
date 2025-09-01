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
    mkSystem = hostName:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs hostName;};
        modules = [./modules ./hosts/${hostName}];
      };
    hostsDir = builtins.readDir ./hosts;
    hosts = (entries: builtins.filter (entry: hostsDir.${entry} == "directory") (builtins.attrNames entries)) hostsDir;
  in {
    nixosConfigurations = nixpkgs.lib.genAttrs hosts mkSystem;
  };
}
