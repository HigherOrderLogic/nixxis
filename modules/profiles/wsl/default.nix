{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.cfg.profiles.wsl;
in {
  options.cfg.profiles.wsl.enable = lib.mkEnableOption "wsl profile";
  imports = [inputs.nixos-wsl.nixosModules.default];
  config = lib.mkIf cfg.enable {
    wsl = {
      enable = true;
      defaultUser = config.cfg.core.username;
    };
    programs.nix-ld.enable = true;
    environment.systemPackages = [pkgs.wget];
  };
}
