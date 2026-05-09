{
  lib,
  pkgs,
  hostname,
  config,
  ...
}: let
  cfg = config.cfg.core.networking;
in {
  options.cfg.core.networking = {
    enable = lib.mkEnableOption "networking";
    nameservers = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          ipv4 = lib.mkOption {
            type = lib.types.str;
            description = "Set the nameserver's IP.";
          };
          hostname = lib.mkOption {
            type = lib.types.str;
            description = "Set the nameserver's hostname";
          };
          httpsUrl = lib.mkOption {
            type = lib.types.str;
            description = "Set the nameserver's HTTPS URL.";
          };
        };
      });
      default = [
        {
          ipv4 = "1.1.1.1";
          hostname = "one.one.one.one";
          httpsUrl = "cloudflare-dns.com/dns-query";
        }
        {
          ipv4 = "9.9.9.9";
          hostname = "dns.quad9.net";
          httpsUrl = "dns.quad9.net/dns-query";
        }
      ];
      description = "Set the nameservers to use.";
    };
    stevenblack = {
      enable = lib.mkEnableOption "stevenblack blocklist";
      whitelist = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Domains to exclude from blocking.";
      };
      whitelistRegex = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Domains regex to exclude from blocking.";
      };
    };
  };
  imports = [(lib.mkAliasOptionModule ["cfg" "core" "networking" "wifiBackend"] ["networking" "networkmanager" "wifi" "backend"])];
  config = lib.mkIf cfg.enable {
    networking = {
      hostName = hostname;
      nameservers = ["127.0.0.1" "::1"];
      timeServers = ["time.cloudflare.com"];
      networkmanager = {
        enable = true;
        dns = "none";
      };
    };
    services = {
      resolved.enable = false;
      blocky = {
        enable = true;
        settings = {
          dnssec.validate = true;
          upstreams = {
            init.strategy = "fast";
            strategy = "strict";
            groups.default = lib.map (n: "https://${n.httpsUrl}") cfg.nameservers;
          };
          bootstrapDns = ["tcp+udp:1.1.1.1"];
          caching = {
            minTime = "1m";
            maxTime = "1h";
            prefetching = true;
          };
          blocking = {
            denylists.default = lib.map (b: let
              inherit (cfg.stevenblack) whitelist whitelistRegex;
              hostsFile = "${lib.getOutput b pkgs.stevenblack-blocklist}/hosts";
            in
              if whitelist == [] && whitelistRegex == []
              then hostsFile
              else let
                escapedWhitelist = lib.map (w: "\\s" + (lib.escape ["."] w) + "$") whitelist;
                escapedWhitelistRegex = lib.map (r:
                  if lib.hasPrefix "^" r
                  then "\\s" + (lib.removePrefix "^" r)
                  else r)
                whitelistRegex;
                pattern = lib.concatStringsSep "|" (escapedWhitelist ++ escapedWhitelistRegex);
              in
                pkgs.runCommand "blocky-denylist-${b}" {} ''
                  sed -E '/${pattern}/d' ${hostsFile} > $out
                '')
            ["ads" "fakenews" "gambling" "porn"];
            clientGroupsBlock.default = ["default"];
          };
          hostsFile = {
            sources = ["/etc/hosts"];
            loading.strategy = "fast";
          };
        };
      };
    };
    users.users.${config.cfg.core.username} = {extraGroups = ["networkmanager"];};
  };
}
