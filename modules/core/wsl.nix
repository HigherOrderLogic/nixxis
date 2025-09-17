{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.cfg.core.wsl;
in {
  options.cfg.core.wsl.enable = lib.mkEnableOption "wsl";
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
