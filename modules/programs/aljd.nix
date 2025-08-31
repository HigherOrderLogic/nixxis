{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.cfg.programs.aljd;
in {
  options.cfg.programs.aljd.enable = mkEnableOption "aljd";
  config = mkIf cfg.enable {
    environment = let
      aljd = pkgs.writeShellApplication {
        name = "aljd";

        runtimeInputs = with pkgs; [alejandra fd];

        text = ''
          fd "$@" -t f -e nix -x alejandra -q '{}'
        '';
      };
    in {systemPackages = [aljd];};
  };
}
