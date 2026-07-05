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
    documentation.man.cache.enable = false;
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
    hj.xdg.config.files = lib.mkMerge [
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
        "fish/conf.d/integrations.fish".text = let
          runFishCommand = name: script: let
            fishScript = pkgs.writers.writeFish "${name}-script" script;
          in
            pkgs.runCommand name {} ''
              ${fishScript}
            '';
          nixYourIntegration = runFishCommand "nix-your-integration" ''
            ${lib.getExe pkgs.nix-your-shell} ${lib.getExe config.programs.fish.package} >> $out
          '';
          zoxideExe = lib.getExe pkgs.zoxide;
          zoxideIntegration = runFishCommand "zoxide-integration" ''
            string replace --regex -- '(?<=\s)zoxide(?=\s)' '${zoxideExe}' (${zoxideExe} init fish) >> $out
          '';
        in ''
          if status is-interactive
            source ${nixYourIntegration}
            source ${zoxideIntegration}
          end
        '';
      }
      (lib.mapAttrs' (
        name: p: let
          pluginDir = f: "${p}/share/fish/vendor_${f}.d";
          testDir = d: (builtins.pathExists d) && (lib.readFileType d == "directory");
        in
          lib.nameValuePair "fish/conf.d/plugin-${name}-${lib.getVersion p}.fish" {
            text = lib.concatStringsSep "\n" [
              (let
                dir = pluginDir "functions";
              in
                lib.optionalString (testDir dir) ''
                  set fish_function_path $fish_function_path[1] ${dir} $fish_function_path[2..]
                '')
              (let
                dir = pluginDir "completions";
              in
                lib.optionalString (testDir dir) ''
                  set fish_complete_path $fish_complete_path[1] ${dir} $fish_complete_path[2..]
                '')
              ''
                for f in ${pluginDir "conf"}/*.fish
                  source $f
                end
              ''
            ];
          }
      ) {inherit (pkgs.fishPlugins) hydro autopair;})
    ];
  };
}
