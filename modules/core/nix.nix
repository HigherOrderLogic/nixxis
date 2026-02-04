{
  inputs,
  lib,
  config,
  ...
}: let
  nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") config.nix.registry;
in {
  config = {
    nix = {
      inherit nixPath;
      channel.enable = false;
      registry =
        {
          hulse.to = {
            type = "github";
            owner = "higherorderlogic";
            repo = "hulse";
          };
        }
        // builtins.mapAttrs (_: flake: {inherit flake;}) inputs;
      settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
        accept-flake-config = true;
        allowed-users = ["@wheel"];
        trusted-users = ["@wheel"];
        nix-path = nixPath;
        flake-registry = "";
        warn-dirty = false;
      };
    };
    nixpkgs.config.allowUnfree = true;
    systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";
  };
}
