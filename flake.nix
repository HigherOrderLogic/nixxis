{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-core = {
      url = "github:manic-systems/nixos-core";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
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

    forEachSystem = fn:
      lib.genAttrs (lib.intersectLists lib.systems.doubles.linux lib.systems.flakeExposed) (system:
        fn {
          inherit system;
          pkgs = nixpkgs.legacyPackages.${system};
        });
  in {
    formatter = forEachSystem ({pkgs, ...}:
      pkgs.writeShellApplication {
        name = "fmt";
        runtimeInputs = with pkgs; [alejandra kdlfmt nufmt fd];
        text = ''
          fd "$@" -t f -e nix -X alejandra -q '{}'
          fd "$@" -t f -e kdl -X kdlfmt format --kdl-version v1 --log-level off '{}'
          fd "$@" -t f -e nu -X nufmt '{}'
        '';
      });

    packages = forEachSystem ({pkgs, ...}: let
      callPackage = lib.callPackageWith (pkgs // {inherit pins callPackage;});
    in
      import ./pkgs {inherit lib callPackage;});

    devShells = forEachSystem ({pkgs, ...}: {default = pkgs.callPackage ./shell.nix {};});

    nixosConfigurations = lib.pipe ./hosts [
      builtins.readDir
      (lib.filterAttrs (_: value: value == "directory"))
      builtins.attrNames
      (lib.flip lib.genAttrs (hostname: let
        lib' = import ./lib {inherit lib;};
      in
        lib.nixosSystem {
          specialArgs = {inherit inputs pins lib' hostname;};
          modules = [
            (args: {
              nixpkgs.overlays = [
                (final: _: let
                  callPackage = args.lib.callPackageWith (final
                    // {
                      inherit (args) pins;
                      inherit callPackage;
                    });
                in {
                  localPackages = import ./pkgs {
                    inherit (args) lib;
                    inherit callPackage;
                  };
                })
              ];
            })
            ./hosts/${hostname}
            ./modules
          ];
        }))
    ];
  };
}
