{
  lib,
  pkgs,
  hostname,
  config,
  ...
}: let
  cfg = config.cfg.core.networking;

  nameservers = map (n: "${n.ipv4}#${n.hostname}") cfg.nameservers;
  useResolved = cfg.dnsResolver == "resolved";
  useBlocky = cfg.dnsResolver == "blocky";
  block = ["fakenews" "gambling" "porn"];
in {
  options.cfg.core.networking = {
    enable = lib.mkEnableOption "networking";
    dnsResolver = lib.mkOption {
      type = lib.types.enum ["resolved" "blocky"];
      default = "resolved";
      description = "Set the DNS resolver to use.";
    };
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
          httpsPath = lib.mkOption {
            type = lib.types.str;
            description = "Set the nameserver's HTTPS path.";
          };
        };
      });
      default = [
        {
          ipv4 = "1.1.1.1";
          hostname = "one.one.one.one";
          httpsPath = "cloudflare-dns.com/dns-query";
        }
        {
          ipv4 = "9.9.9.9";
          hostname = "dns.quad9.net";
          httpsPath = "dns.quad9.net/dns-query";
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
      nameservers =
        if useResolved
        then nameservers
        else ["127.0.0.1" "::1"];
      timeServers = lib.mkBefore ["time.cloudflare.com"];
      networkmanager = {
        enable = true;
        dns = lib.mkIf useBlocky "none";
      };
      stevenblack = lib.mkIf useResolved {
        inherit (cfg.stevenblack) enable whitelist;
        inherit block;
      };
    };
    services = lib.mkMerge [
      (lib.mkIf useResolved {
        resolved = {
          enable = true;
          settings.Resolve = {
            DNSSEC = "true";
            DNSOverTLS = "true";
            Domains = ["~."];
            FallbackDNS = nameservers;
          };
        };
      })
      (lib.mkIf useBlocky {
        resolved.enable = false;
        blocky = {
          enable = true;
          settings = {
            dnssec.validate = true;
            upstreams = {
              init.strategy = "fast";
              strategy = "strict";
              groups.default = lib.map (n: "https://${n.httpsPath}") cfg.nameservers;
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
                  pkgs.runCommand "blocky-denylist" {} ''
                    sed -E '/${pattern}/d' ${hostsFile} > $out
                  '')
              block;
              clientGroupsBlock.default = ["default"];
            };
          };
        };
      })
    ];
    users.users.${config.cfg.core.username} = {extraGroups = ["networkmanager"];};
  };
}
