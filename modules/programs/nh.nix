{
  lib,
  config,
  ...
}: let
  cfg = config.cfg.programs.nh;
in {
  options.cfg.programs.nh.enable = lib.mkEnableOption "nh";
  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 3";
      };
    };
  };
}
