{
  lib,
  config,
  options,
  pkgs,
  ...
}: let
  cfg = config.cfg.profiles.iso;
in {
  options.cfg.profiles.iso.enable = lib.mkEnableOption "iso profile";
  config = lib.mkIf cfg.enable {
    cfg = {
      core = {
        boot = {
          enable = true;
          nixos-core.enable = true;
        };
        kernel.type = "lts";
        networking.enable = true;
      };
      programs = {
        fish.enable = true;
        git = {
          enable = true;
          name = config.cfg.core.username;
          email = "mail@domain.com";
        };
        helix = {
          enable = true;
          defaultEditor = true;
          languages = lib.mkMerge [(builtins.mapAttrs (k: _: {enable = lib.mkDefault (k == "nix");}) options.cfg.programs.helix.languages)];
          integrations.jjui.enable = false;
        };
        nh.enable = true;
      };
    };
    hj.packages = with pkgs; [nixos-install-tools btrfs-progs];
    assertions = [
      {
        assertion = config.system.build ? isoImage;
        message = "No `isoImage` found";
      }
    ];
  };
}
