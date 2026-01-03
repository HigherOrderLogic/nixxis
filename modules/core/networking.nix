{
  lib,
  lib',
  hostname,
  config,
  ...
}: let
  cfg = config.cfg.core.networking;

  nameserversIp = map (n: builtins.elemAt n 0) cfg.nameservers;
  nameservers = map (n: builtins.concatStringsSep "#" n) cfg.nameservers;
in {
  options.cfg.core.networking = {
    enable = lib.mkEnableOption "networking";
    nameservers = lib.mkOption {
      type = lib.types.listOf (lib'.types.listOfLength lib.types.str 2);
      default = [["1.1.1.1" "one.one.one.one"] ["1.0.0.1" "one.one.one.one"]];
      description = "Set the nameservers to use.";
    };
    stevenblack = {
      enable = lib.mkEnableOption "stevenblack blocklist";
      whitelist = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Domains to exclude from blocking.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    networking = {
      hostName = hostname;
      inherit nameservers;
      timeServers = lib.mkBefore ["time.cloudflare.com"];
      networkmanager = {
        enable = true;
        insertNameservers = nameserversIp;
      };
      stevenblack = {
        inherit (cfg.stevenblack) enable whitelist;
        block = ["fakenews" "gambling" "porn"];
      };
    };
    services.resolved = {
      enable = true;
      dnssec = "true";
      dnsovertls = "true";
      domains = ["~."];
      fallbackDns = nameservers;
    };
    users.users.${config.cfg.core.username} = {extraGroups = ["networkmanager"];};
  };
}
