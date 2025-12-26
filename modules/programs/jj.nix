{
  config,
  pkgs,
  lib,
  lib',
  ...
}: let
  cfg = config.cfg.programs.jj;

  toml = pkgs.formats.toml {};
in {
  options.cfg.programs.jj = {
    enable = lib.mkEnableOption "jj";
    name = lib.mkOption {
      type = lib.types.str;
      description = "Set your username for Jujutsu.";
    };
    email = lib.mkOption {
      type = lib.types.str;
      description = "Set your email for Jujutsu.";
    };
    integrations = {
      difftastic.enable = lib'.mkEnableTrueOption "difftastic integration";
    };
  };
  config = lib.mkIf cfg.enable {
    hj = {
      packages = with pkgs; [jujutsu];
      xdg.config.files."jj/config.toml".source = toml.generate "jj-config" ({
          user = {inherit (cfg) name email;};
        }
        // (lib.optionalAttrs cfg.integrations.difftastic.enable {
          ui = {
            diff-formatter = [(lib.getExe pkgs.difftastic) "--display=side-by-side" "--color=always" "$left" "$right"];
          };
        }));
    };
  };
}
