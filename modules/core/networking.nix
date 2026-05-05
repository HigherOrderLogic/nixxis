{
  lib,
  hostname,
  config,
  ...
}: let
  cfg = config.cfg.core.networking;

  nameservers = map (n: "${n.ipv4}#${n.hostname}") cfg.nameservers;
  useResolved = cfg.dnsResolver == "resolved";
  useBlocky = cfg.dnsResolver == "blocky";
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
      stevenblack = {
        inherit (cfg.stevenblack) enable whitelist;
        block = ["fakenews" "gambling" "porn"];
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
            hostsFile = {
              sources = ["/etc/hosts"];
              loading.strategy = "fast";
            };
          };
        };
      })
    ];
    users.users.${config.cfg.core.username} = {extraGroups = ["networkmanager"];};
  };
}
