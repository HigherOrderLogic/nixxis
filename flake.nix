{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    hjem = {
      url = "github:feel-co/hjem";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        ndg.follows = "";
      };
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
      };
    };
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {nixpkgs, ...}: let
    inherit (nixpkgs) lib;

    forAllSystems = fn: lib.genAttrs lib.systems.flakeExposed (system: fn system nixpkgs.legacyPackages.${system});

    hosts = lib.pipe ./hosts [builtins.readDir (lib.filterAttrs (_: value: value == "directory")) builtins.attrNames];
  in {
    formatter = forAllSystems (system: pkgs:
      pkgs.writeShellApplication {
        name = "aljd";
        runtimeInputs = with pkgs; [alejandra fd];
        text = ''
          fd "$@" -t f -e nix -X alejandra -q '{}'
        '';
      });

    nixosConfigurations = lib.genAttrs hosts (hostname: let
      lib' = import ./lib {inherit lib;};
    in
      lib.nixosSystem {
        specialArgs = {inherit inputs lib' hostname;};
        modules = [./hosts/${hostname} ./modules];
      });
  };
}
