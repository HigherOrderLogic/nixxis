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
    nvidiaSupport.enable = lib.mkEnableOption "Nvidia support";
  };
  imports = [inputs.nixos-wsl.nixosModules.default];
  config = lib.mkIf cfg.enable {
    wsl = {
      enable = true;
      defaultUser = config.cfg.core.username;
      wslConf.network = {inherit hostname;};
      useWindowsDriver = cfg.nvidiaSupport.enable;
    };
    programs.nix-ld = lib.mkIf (cfg.vsCodeIntegration.enable || cfg.nvidiaSupport.enable) {
      enable = true;
      libraries = lib.mkIf cfg.nvidiaSupport.enable [config.wsl.wslLib];
    };
    environment.systemPackages = lib.optional cfg.vsCodeIntegration.enable pkgs.wget;
  };
}
