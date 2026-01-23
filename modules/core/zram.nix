{
  lib,
  config,
  ...
}: let
  cfg = config.cfg.core.zram;
in {
  options.cfg.core.zram.enable = lib.mkEnableOption "zram";
  config = lib.mkIf cfg.enable {
    boot.kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };
    zramSwap.enable = true;
  };
}
