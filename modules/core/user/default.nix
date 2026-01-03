{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.cfg.core) username;
in {
  options.cfg.core.username = lib.mkOption {
    type = lib.types.str;
    description = "Set the username for your user.";
  };
  imports = [inputs.hjem.nixosModules.default (lib.mkAliasOptionModule ["hj"] ["hjem" "users" username])];
  config = {
    hjem = {
      extraModules = [./hjemModules];
      linker = pkgs.smfh;
      clobberByDefault = true;
      users.${username} = {
        enable = true;
        user = username;
        packages = builtins.attrValues {
          inherit (pkgs) bat eza msedit;
          inherit (inputs.nix-index-db.packages.${pkgs.stdenv.hostPlatform.system}) comma-with-db;
        };
        environment.sessionVariables = {
          EDITOR = lib.mkDefault "edit";
        };
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
