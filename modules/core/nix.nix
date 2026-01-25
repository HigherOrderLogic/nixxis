{
  inputs,
  lib,
  config,
  ...
}: {
  config = {
    nix = {
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
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") config.nix.registry;
      settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
        allowed-users = ["@wheel"];
        trusted-users = ["@wheel"];
        nix-path = lib.mapAttrsToList (n: _: "${n}=flake:${n}") inputs;
        flake-registry = "";
        warn-dirty = false;
      };
    };
    nixpkgs.config.allowUnfree = true;
    systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";
  };
}
