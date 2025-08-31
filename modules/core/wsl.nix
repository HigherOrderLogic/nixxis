{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.cfg.core.wsl;
in {
  options.cfg.core.wsl.enable = mkEnableOption "wsl";
  imports = [inputs.nixos-wsl.nixosModules.default];
  config = mkIf cfg.enable {
    wsl = {
      enable = true;
      defaultUser = config.cfg.core.username;
    };
    programs.nix-ld.enable = true;
    environment.systemPackages = [pkgs.wget];
  };
}
