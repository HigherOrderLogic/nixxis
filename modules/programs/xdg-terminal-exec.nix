{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.cfg.programs.xdg-terminal-exec;
in {
  options.cfg.programs.xdg-terminal-exec = {
    enable = lib.mkEnableOption "xdg-terminal-exec";
    settings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = {};
      description = "Settings for the Default Terminal Execution Specification.";
    };
  };
  config = lib.mkIf cfg.enable {
    hj = {
      packages = [pkgs.xdg-terminal-exec];
      xdg.config.files = lib.mapAttrs' (key: val:
        lib.nameValuePair "${
          if key == "default"
          then ""
          else "${lib.toLower key}-"
        }xdg-terminals.list" {text = lib.concatLines val;})
      cfg.settings;
    };
  };
}
