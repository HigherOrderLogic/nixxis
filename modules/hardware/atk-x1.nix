{
  lib,
  config,
  ...
}: let
  cfg = config.cfg.hardware.atk-x1;
in {
  options.cfg.hardware.atk-x1.enable = lib.mkEnableOption "ATK X1 mouse series";
  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idVendor}=="373b", ATTRS{idProduct}=="11fe", MODE="0660", GROUP="users"
    '';
  };
}
