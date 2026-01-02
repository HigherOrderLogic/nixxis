{
  inputs,
  lib,
  lib',
  config,
  pkgs,
  hostname,
  ...
}: let
  cfg = config.cfg.profiles.wsl;
in {
  options.cfg.profiles.wsl = {
    enable = lib.mkEnableOption "wsl profile";
    vsCodeIntegration.enable = lib'.mkEnableTrueOption "VsCode integration";
  };
  imports = [inputs.nixos-wsl.nixosModules.default];
  config = lib.mkIf cfg.enable {
    wsl = {
      enable = true;
      defaultUser = config.cfg.core.username;
      wslConf.network = {inherit hostname;};
    };
    programs.nix-ld = {inherit (cfg.vsCodeIntegration) enable;};
    environment.systemPackages = lib.optional cfg.vsCodeIntegration.enable pkgs.wget;
  };
}
