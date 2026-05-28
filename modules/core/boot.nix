{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.cfg.core.boot;
in {
  options.cfg.core.boot.enable = lib.mkEnableOption "boot";
  imports = [inputs.nixos-core.nixosModules.default (lib.mkAliasOptionModule ["cfg" "core" "boot" "nixos-core"] ["system" "nixos-core"])];
  config = lib.mkIf cfg.enable {
    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        editor = false;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
    };
  };
}
