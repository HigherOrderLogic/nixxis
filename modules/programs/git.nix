{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.cfg.programs.git;

  gitIni = pkgs.formats.gitIni {};
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
    hj = {
      packages = with pkgs; [git gh codeberg-cli];
      xdg.config.files."git/config".source = gitIni.generate "git-config" {
        user = {inherit (cfg) name email;};
        signing.format = "https";
        init.defaultBranch = "main";
        url = {
          "https://github.com/".insteadOf = ["gh:" "github:"];
          "https://codeberg.org/".insteadOf = ["cb:" "codeberg:"];
        };
      };
    };
    environment.shellAliases = {
      gaa = "git add --all";
      gcm = "git commit --message";
      gca = "git commit --amend";
      gcan = "git commit --amend --no-edit";
      gp = "git push";
      gpf = "git push --force-with-lease";
    };
  };
}
