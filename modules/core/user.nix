{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (config.cfg.core) username;
in {
  options.cfg.core.username = mkOption {
    type = types.str;
    default = false;
    description = "Set the username for your user.";
  };
  config = {
    users.users.${username} = {
      isNormalUser = true;
      initialPassword = "1234";
      extraGroups = [
        "wheel"
        "video"
        "input"
      ];
      uid = 1000;
    };
  };
}
