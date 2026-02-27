{
  lib,
  pkgs,
  hostname,
  config,
  ...
}: let
  cfg = config.cfg.services.greetd;

  toml = pkgs.formats.toml {};
in {
  options.cfg.services.greetd.enable = lib.mkEnableOption "greetd";
  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings.default_session = {
        user = "greeter";
        command = lib.getExe pkgs.localPackages.rafgreet;
      };
    };
    environment.etc."tuigreet/config.toml".source = toml.generate "tuigreet-config" {
      display = {
        greeting = "Descending into ${hostname}!";
        show_title = false;
        show_time = true;
      };
      secret = {
        mode = "characters";
        characters = "*";
      };
      session = {
        sessions_dirs = ["${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"];
        xsessions_dirs = [];
      };
      remember = {
        default_config = config.cfg.core.username;
        username = true;
        user_session = true;
      };
      power = {
        use_setsid = false;
        shutdown = "systemctl poweroff";
        reboot = "systemctl reboot";
      };
    };
  };
}
