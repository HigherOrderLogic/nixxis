{
  lib,
  config,
  ...
}: let
  cfg = config.cfg.core.zswap;
in {
  options.cfg.core.zswap.enable = lib.mkEnableOption "zswap";
  imports = [(lib.mkAliasOptionModule ["cfg" "core" "zswap" "maxPoolPercent"] ["boot" "zswap" "maxPoolPercent"])];
  config = lib.mkIf cfg.enable {
    boot = {
      zswap.enable = true;
      kernel.sysctl = {
        "vm.swappiness" = 30;
        "vm.watermark_boost_factor" = 0;
        "vm.watermark_scale_factor" = 125;
        "vm.page-cluster" = 0;
        "vm.dirty_background_ratio" = 5;
        "vm.dirty_ratio" = 10;
      };
    };
  };
}
