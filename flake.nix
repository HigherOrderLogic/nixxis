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

    forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    nixpkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});

    mkSystem = hostName:
      lib.nixosSystem {
        specialArgs = {inherit inputs hostName;};
        modules = [./modules ./hosts/${hostName}];
      };
    hosts = lib.pipe (builtins.readDir ./hosts) [(lib.filterAttrs (_: value: value == "directory")) builtins.attrNames];
  in {
    formatter = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in
      pkgs.writeShellApplication {
        name = "aljd";
        runtimeInputs = with pkgs; [alejandra fd];
        text = ''
          fd "$@" -t f -e nix -x alejandra -q '{}'
        '';
      });
    nixosConfigurations = nixpkgs.lib.genAttrs hosts mkSystem;
  };
}
