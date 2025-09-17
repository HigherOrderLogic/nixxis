{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.cfg.programs.git;
in {
  options.cfg.programs.git = {
    enable = mkEnableOption "git";
    name = mkOption {
      type = types.str;
      default = false;
      description = "Set your username for git.";
    };
    email = mkOption {
      type = types.str;
      default = false;
      description = "Set your email for git.";
    };
  };
  config = mkIf cfg.enable {
    hj.packages = with pkgs; [gh codeberg-cli];
    environment.shellAliases = {
      gaa = "git add --all";
      gcm = "git commit --message";
      gca = "git commit --amend";
      gpf = "git push --force";
    };
    programs.git = {
      enable = true;
      config = {
        user = {inherit (cfg) name email;};
        signing.format = "https";
        init.defaultBranch = "main";
        url = {
          "https://github.com/".insteadOf = ["gh:" "github:"];
          "https://codeberg.org/".insteadOf = ["cb:" "codeberg:"];
        };
      };
    };
  };
}
