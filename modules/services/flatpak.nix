{
  pins,
  lib,
  config,
  ...
}: let
  inherit (pins) nix-flatpak;

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
  imports = ["${nix-flatpak}/modules/nixos.nix"];
  config = lib.mkIf cfg.enable {
    services.flatpak =
      commonOpts
      // {
        remotes = [];
        uninstallUnmanaged = true;
      };
    hjem.extraModules = [
      (args: let
        helpers = import "${nix-flatpak}/modules/common.nix" {inherit (args) lib config;};
        cfg' = helpers.warnDeprecated args.config.services.flatpak;
      in {
        options.services.flatpak = (import "${nix-flatpak}/modules/options.nix" {inherit (args) config lib pkgs;}) // {enable = args.lib.mkEnableOption "nix-flatpak";};
        config = args.lib.mkIf cfg'.enable {
          systemd = {
            services."flatpak-managed-install" = {
              after = ["multi-user.target"];
              wantedBy = ["default.target"];
              serviceConfig =
                helpers.mkCommonServiceConfig {
                  inherit (args) pkgs lib;
                  cfg = cfg';
                  installation = "user";
                  executionContext = "service-start";
                }
                // helpers.mkRestartOptions cfg';
            };
            timers."flatpak-managed-install-timer" = lib.mkIf cfg'.update.auto.enable {
              wantedBy = ["timers.target"];
              timerConfig = helpers.mkCommonTimerConfig cfg';
            };
          };
        };
      })
    ];
    hj.services.flatpak =
      commonOpts
      // {
        packages = ["com.github.tchx84.Flatseal"] ++ cfg.packages;
        overrides.global.Context.filesystems = ["xdg-config:ro"];
      };
  };
}
