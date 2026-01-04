{
  lib,
  config,
  ...
}: let
  cfg = config.cfg.services.flatpak;
in {
  options.cfg.services.flatpak = {
    enable = lib.mkEnableOption "flatpak";
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Packages to install.";
    };
  };
  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      packages = ["com.github.tchx84.Flatseal"] ++ cfg.packages;
      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };
      uninstallUnused = true;
    };
  };
}
