{
  inputs,
  lib,
  config,
  ...
}: let
  inherit (lib) mapAttrsToList;
  inherit (builtins) mapAttrs;
in {
  config = {
    nix = {
      channel.enable = false;
      registry = mapAttrs (_: flake: {inherit flake;}) inputs;
      nixPath = mapAttrsToList (n: _: "${n}=flake:${n}") inputs;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        allowed-users = ["@wheel"];
        trusted-users = ["@wheel"];
        build-dir = "/var/tmp";
        nix-path = mapAttrsToList (n: _: "${n}=flake:${n}") inputs;
        flake-registry = "";
      };
    };
    nixpkgs.config.allowUnfree = true;
    systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";
  };
}
