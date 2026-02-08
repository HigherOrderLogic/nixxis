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
    documentation.man.generateCaches = false;
    programs.fish = {
      enable = true;
      useBabelfish = true;
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
    hj.xdg.config.files =
      {
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
            (name: val: "alias -- ${name} ${lib.escapeShellArg (toString val)}")
            config.hjem.users.${config.cfg.core.username}.environment.shellAliases;
        };
      }
      // lib.mapAttrs' (
        name: p: let
          pluginPath = f: "${p.src}/${f}";
          testPluginDir = d: let dirPath = pluginPath d; in (builtins.pathExists dirPath) && (lib.readFileType dirPath == "directory");
          testPluginFile = f: let filePath = pluginPath f; in (builtins.pathExists filePath) && (lib.readFileType filePath == "regular");
        in
          lib.nameValuePair "fish/conf.d/plugin-${name}-${lib.getVersion p}.fish" {
            text = lib.concatStringsSep "\n" [
              (lib.optionalString (testPluginDir "functions") ''
                set fish_function_path $fish_function_path[1] ${pluginPath "functions"} $fish_function_path[2..]
              '')
              (lib.optionalString (testPluginDir "completions") ''
                set fish_complete_path $fish_complete_path[1] ${pluginPath "completions"} $fish_complete_path[2..]
              '')
              ''
                for f in ${pluginPath "conf.d"}/*.fish
                  source $f
                end
              ''
              (lib.optionalString (testPluginFile "key_bindings.fish") ''
                source ${pluginPath "key_bindings.fish"}
              '')
              (lib.optionalString (testPluginFile "init.fish") ''
                source ${pluginPath "init.fish"}
              '')
            ];
          }
      ) {inherit (pkgs.fishPlugins) hydro pisces;};
  };
}
