{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.cfg.programs.foot;

  ini = pkgs.formats.ini {};
in {
  options.cfg.programs.foot = {
    enable = lib.mkEnableOption "foot";
    defaultTerminal = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set Foot as the default terminal";
    };
  };
  config = lib.mkIf cfg.enable {
    hj = {
      packages = [pkgs.foot];
      xdg.config.files."foot/foot.ini".source = ini.generate "foot-config" {
        main = {
          font = "monospace:size=10";
          pad = "10x10 center";
        };
      };
    };
    cfg.programs.xdg-terminal-exec = lib.mkIf cfg.defaultTerminal {
      enable = true;
      settings.default = ["foot.desktop"];
    };
  };
}
