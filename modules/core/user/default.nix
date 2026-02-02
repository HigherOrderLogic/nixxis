{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.cfg.core) username;

  inherit (pkgs) comma;
  commaWrapped = pkgs.symlinkJoin {
    name = "${lib.getName comma}-wrapped";
    paths = [comma];
    nativeBuildInputs = [pkgs.makeBinaryWrapper];
    postBuild = ''
      for cmd in "," "comma"; do
        wrapProgram "$out/bin/$cmd" --set NIX_INDEX_DATABASE ${inputs.nbi.packages.${pkgs.stdenv.hostPlatform.system}.unstable}
      done
    '';
  };
in {
  options.cfg.core.username = lib.mkOption {
    type = lib.types.str;
    description = "Set the username for your user.";
  };
  imports = [inputs.hjem.nixosModules.default (lib.mkAliasOptionModule ["hj"] ["hjem" "users" username])];
  config = {
    programs.less.enable = lib.mkForce false;
    hjem = {
      extraModules = [./hjemModules];
      linker = pkgs.smfh;
      clobberByDefault = true;
      users.${username} = {
        enable = true;
        user = username;
        packages = builtins.attrValues {
          inherit commaWrapped;
          inherit (pkgs) bat eza msedit;
        };
        environment.sessionVariables = {
          EDITOR = lib.mkDefault "edit";
          PAGER = "bat";
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
