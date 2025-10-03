{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.cfg.programs.git;
in {
  options.cfg.programs.git = {
    enable = lib.mkEnableOption "git";
    name = lib.mkOption {
      type = lib.types.str;
      description = "Set your username for git.";
    };
    email = lib.mkOption {
      type = lib.types.str;
      description = "Set your email for git.";
    };
  };
  config = lib.mkIf cfg.enable {
    hj.packages = with pkgs; [gh codeberg-cli];
    environment.shellAliases = {
      gaa = "git add --all";
      gcm = "git commit --message";
      gca = "git commit --amend";
      gcan = "git commit --amend --no-edit";
      gp = "git push";
      gpf = "git push --force";
    };
    programs.git = {
      enable = true;
      config = {
        user = {inherit (cfg) name email;};
        signing.format = "https";
        init.defaultBranch = "main";
        # TODO: remove once hjem's sessionVariables works
        core.editor =
          if config.cfg.programs.helix.enable
          then "hx"
          else "edit";
        url = {
          "https://github.com/".insteadOf = ["gh:" "github:"];
          "https://codeberg.org/".insteadOf = ["cb:" "codeberg:"];
        };
      };
    };
  };
}
