{
  inputs,
  lib,
  ...
}: {
  config = {
    nix = {
      channel.enable = false;
      registry = builtins.mapAttrs (_: flake: {inherit flake;}) inputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") inputs;
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
