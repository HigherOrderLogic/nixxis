{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.cfg.desktops.niri;
in {
  config = lib.mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = true;
    security.polkit.enable = true;
    hj.systemd.services = let
      makeWantedByNiriService = description: serviceConfig: {
        inherit description serviceConfig;
        wantedBy = ["niri.service"];
        partOf = ["niri.service"];
        after = ["niri.service"];
      };
      makeWlPasteWatcherService = type: {
        "wl-paste-${type}-watcher" = makeWantedByNiriService "Wl-paste watcher for type ${type}" {
          ExecStart = let
            wlPaste = lib.getExe' pkgs.wl-clipboard "wl-paste";
            cliphist = lib.getExe pkgs.cliphist;
          in "${wlPaste} --type ${type} --watch ${cliphist} store";
          Restart = "on-failure";
          RestartSec = 1;
        };
      };
    in
      lib.mkMerge [
        {
          waybar = makeWantedByNiriService "Waybar" {
            ExecStart = lib.getExe pkgs.waybar;
            Restart = "on-failure";
          };
          mako = makeWantedByNiriService "Mako" {
            ExecStart = lib.getExe pkgs.mako;
            Restart = "on-failure";
          };
          nm-applet = makeWantedByNiriService "Nm-applet" {
            ExecStart= lib.getExe pkgs.networkmanagerapplet;
            Restart = "on-failure";
          };
          soteria = makeWantedByNiriService "Soteria" {
            ExecStart = lib.getExe pkgs.soteria;
            Restart = "on-failure";
          };
        }
        (makeWlPasteWatcherService "image")
        (makeWlPasteWatcherService "text")
      ];
  };
}
