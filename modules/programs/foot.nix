{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.cfg.programs.foot;

  ini = pkgs.formats.ini {};
in {
  options.cfg.programs.foot.enable = lib.mkEnableOption "foot";
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
  };
}
