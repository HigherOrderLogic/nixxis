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
      loginShellInit = ''
        switch $USER
          ${lib.concatMapAttrsStringSep
          "\n"
          (u: c: ''
            case ${u}
              ${lib.concatMapAttrsStringSep
              "\n"
              (name: value: "set -gx ${name} '${lib.escapeShellArg value}'")
              c.environment.sessionVariables}
          '')
          config.hjem.users}
          case '*'
            echo "Unknown user $USER."
        end
      '';
    };
    users.users.${config.cfg.core.username}.shell = pkgs.fish;
    hj.xdg.config.files = {
      "fish/conf.d/binds.fish".text = ''
        if status is-interactive
          bind up history-prefix-search-backward
          bind down history-prefix-search-forward
          bind shift-up history-search-backward
          bind shift-down history-search-forward
        end
      '';
      "fish/conf.d/aliases.fish" = lib.mkIf (config.hjem.users.${config.cfg.core.username}.environment.shellAliases != {}) {
        text =
          lib.concatMapAttrsStringSep
          "\n"
          (name: val: "alias -- ${name} ${lib.escapeShellArg (builtins.toString val)}")
          config.hjem.users.${config.cfg.core.username}.environment.shellAliases;
      };
    };
    environment.systemPackages = [pkgs.fishPlugins.hydro];
  };
}
