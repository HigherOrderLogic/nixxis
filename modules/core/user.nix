{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types modules;
  inherit (config.cfg.core) username;
in {
  options.cfg.core.username = mkOption {
    type = types.str;
    default = false;
    description = "Set the username for your user.";
  };
  imports = [inputs.hjem.nixosModules.default (modules.mkAliasOptionModule ["hj"] ["hjem" "users" username])];
  config = {
    hjem = {
      linker = pkgs.smfh;
      clobberByDefault = true;
      users.${username} = {
        enable = true;
        user = username;
        packages = with pkgs; [bat eza msedit];
      };
    };
    users.users.${username} = {
      isNormalUser = true;
      initialPassword = "1234";
      extraGroups = ["wheel" "video" "input"];
      uid = 1000;
    };
  };
}
