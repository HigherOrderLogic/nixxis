{
  lib,
  config,
  ...
}: let
  cfg = config.cfg.services.ly;
in {
  options.cfg.services.ly.enable = lib.mkEnableOption "ly";
  config = lib.mkIf cfg.enable {
    services.displayManager.ly = {
      enable = true;
      x11Support = false;
      settings = {
        clock = "%a, %b %d, %Y - %I:%M %p";
        show_password_key = "F3";
        brightness_up_cmd = null;
        brightness_up_key = null;
        brightness_down_cmd = null;
        brightness_down_key = null;
      };
    };
  };
}
