{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.cfg.services.scx;
in {
  options.cfg.services.scx = {
    enable = lib.mkEnableOption "scx";
    scheduler = lib.mkOption {
      type = lib.types.str;
      default = "scx_lavd";
      description = "Set the scheduler to use.";
    };
  };
  config = lib.mkIf cfg.enable {
    services.scx = {
      enable = true;
      package = pkgs.scx.rustscheds;
      inherit (cfg) scheduler;
    };
  };
}
