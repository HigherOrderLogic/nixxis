{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.cfg.services.flatpak;

  commonOpts = {
    enable = true;
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
    uninstallUnused = true;
  };
in {
  options.cfg.services.flatpak = {
    enable = lib.mkEnableOption "flatpak";
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Packages to install.";
    };
  };
  imports = [inputs.nix-flatpak.nixosModules.nix-flatpak];
  config = lib.mkIf cfg.enable {
    services.flatpak =
      commonOpts
      // {
        remotes = [];
        uninstallUnmanaged = true;
      };
    hjem.extraModules = [inputs.nix-flatpak.hjemModules.nix-flatpak];
    hj.services.flatpak =
      commonOpts
      // {
        packages = ["com.github.tchx84.Flatseal"] ++ cfg.packages;
        overrides.global.Context.filesystems = ["xdg-config:ro"];
      };
  };
}
