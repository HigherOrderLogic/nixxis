{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.cfg.desktops.niri;

  niri = pkgs.localPackages.niri-git;
in {
  imports = [./services.nix];
  options.cfg.desktops.niri = {
    enable = lib.mkEnableOption "Niri";
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Set extra Niri config.";
    };
  };
  config = lib.mkIf cfg.enable {
    services.displayManager.sessionPackages = [niri];
    hj = {
      packages = lib.flatten [niri (with pkgs; [fuzzel phinger-cursors])];
      xdg.config.files."niri/config.kdl".text = let
        xwaylandCfg = pkgs.writeText "xwayland.kdl" ''
          xwayland-satellite {
            path "${lib.getExe pkgs.xwayland-satellite}"
          }
        '';
        extraCfg = pkgs.writeText "extra.kdl" cfg.extraConfig;
      in
        lib.pipe ./config [
          builtins.readDir
          (lib.filterAttrs (_: v: v == "regular"))
          lib.attrNames
          (lib.map (v: "${./config}/${v}"))
          (v: v ++ [xwaylandCfg] ++ lib.optional (cfg.extraConfig != "") extraCfg)
          (lib.concatMapStrings (v: ''
            include "${v}"
          ''))
        ];
    };
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [kdePackages.xdg-desktop-portal-kde xdg-desktop-portal-gnome xdg-desktop-portal-gtk];
      config = {
        niri = {
          default = ["kde" "gtk"];
          "org.freedesktop.impl.portal.ScreenCast" = "gnome";
          "org.freedesktop.impl.portal.Screenshot" = "gnome";
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        };
      };
    };
  };
}
