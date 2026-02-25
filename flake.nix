{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hjem = {
      url = "github:feel-co/hjem";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-darwin.follows = "";
        smfh.follows = "";
      };
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nix-index-db = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
      };
    };
  };

  outputs = inputs @ {
    nixpkgs,
    nix-flatpak,
    ...
  }: let
    pins = import ./pins;

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

    devShells = forAllSystems (system: pkgs: {default = pkgs.callPackage ./shell.nix {};});

    nixosConfigurations = lib.genAttrs hosts (hostname: let
      lib' = import ./lib {inherit lib;};
    in
      lib.nixosSystem {
        specialArgs = {inherit inputs pins lib' hostname;};
        modules = [./hosts/${hostname} ./modules ./pkgs nix-flatpak.nixosModules.nix-flatpak];
      });
  };
}
