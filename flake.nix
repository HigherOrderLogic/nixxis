{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hjem = {
      url = "github:feel-co/hjem";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-darwin.follows = "";
      };
    };
    nix-flatpak.url = "github:higherorderlogic/nfp";
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
      };
    };
  };

  outputs = inputs @ {nixpkgs, ...}: let
    pins = import ./pins;

    inherit (nixpkgs) lib;

    forAllSystems = fn: lib.genAttrs lib.systems.flakeExposed (system: fn system nixpkgs.legacyPackages.${system});

    hosts = lib.pipe ./hosts [builtins.readDir (lib.filterAttrs (_: value: value == "directory")) builtins.attrNames];
  in {
    formatter = forAllSystems (_: pkgs:
      pkgs.writeShellApplication {
        name = "aljd";
        runtimeInputs = with pkgs; [alejandra kdlfmt fd];
        text = ''
          fd "$@" -t f -e nix -X alejandra -q '{}'
          fd "$@" -t f -e kdl -X kdlfmt format --kdl-version v1 --log-level off '{}'
        '';
      });

    packages = forAllSystems (_: pkgs: import ./pkgs {inherit pkgs pins lib;});

    devShells = forAllSystems (_: pkgs: {default = pkgs.callPackage ./shell.nix {};});

    nixosConfigurations = lib.genAttrs hosts (hostname: let
      lib' = import ./lib {inherit lib;};
    in
      lib.nixosSystem {
        specialArgs = {inherit inputs pins lib' hostname;};
        modules = [
          (args: {
            nixpkgs.overlays = [
              (final: _: {
                localPackages = import ./pkgs {
                  inherit (args) pins lib;
                  pkgs = final;
                };
              })
            ];
          })
          ./hosts/${hostname}
          ./modules
        ];
      });
  };
}
