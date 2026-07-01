{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.cfg.hardware.magic-trackpad-clone;
in {
  options.cfg.hardware.magic-trackpad-clone.enable = lib.mkEnableOption "Apple's Magic Trackpad clone";
  config = lib.mkIf cfg.enable {
    services.udev.extraRules = let
      switchDriver = pkgs.writeShellScript "switch-driver" ''
        echo -n $1 > /sys/bus/hid/drivers/magicmouse/unbind
        echo -n $1 > /sys/bus/hid/drivers/hid-multitouch/bind
      '';
    in ''
      SUBSYSTEM=="hid", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="0265", PROGRAM="${switchDriver} %k"
    '';
  };
}
