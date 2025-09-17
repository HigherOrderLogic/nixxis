{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.cfg.programs.fish;
in {
  options.cfg.programs.fish.enable = lib.mkEnableOption "fish";
  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        bind up history-prefix-search-backward
        bind down history-prefix-search-forward
        bind shift-up history-search-backward
        bind shift-down history-search-forward
      '';
    };
    users.users.${config.cfg.core.username}.shell = pkgs.fish;
    environment.systemPackages = [pkgs.fishPlugins.hydro];
  };
}
