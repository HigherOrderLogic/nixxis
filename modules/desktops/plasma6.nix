{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.cfg.desktops.plasma6;
in {
  options.cfg.desktops.plasma6.enable = lib.mkEnableOption "Plasma 6";
  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6 = {
      enable = true;
      notoPackage = pkgs.nerd-fonts.noto;
    };
    environment.plasma6.excludePackages = with pkgs.kdePackages; [kwin-x11 ark konsole kate ktexteditor];
    hj.xdg.config.files."plasma-workspace/env/variables.sh".source = config.hj.environment.loadEnv;
  };
}
