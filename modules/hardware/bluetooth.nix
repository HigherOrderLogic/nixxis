{
  lib,
  config,
  ...
}: let
  cfg = config.cfg.hardware.bluetooth;
in {
  options.cfg.hardware.bluetooth.enable = lib.mkEnableOption "bluetooth";
  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      settings.General = {
        PairableTimeout = 30;
        DiscoverableTimeout = 30;
      };
    };
  };
}
