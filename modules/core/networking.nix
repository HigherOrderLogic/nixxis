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
      type = lib.types.listOf lib.types.str;
      default = ["cloudflare" "quad9-dnscrypt-ip4-filter-ecs-pri"];
      description = "Upstream nameservers to use.";
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
        settings = {
          device."wifi.iwd.autoconnect" = lib.mkIf (cfg.wifiBackend == "iwd") false;
          connection."wifi.powersave" = 2;
        };
      };
    };
    services = {
      resolved.enable = false;
      dnscrypt-proxy = {
        enable = true;
        settings = {
          listen_addresses = ["[::]:53"];
          server_names = cfg.nameservers;
          http3 = true;
          http3_probe = true;
          dnscrypt_servers = true;
          doh_servers = true;
          odoh_servers = false;
          require_dnssec = true;
          require_nofilter = false;
          blocked_names.blocked_names_file = lib.mkIf cfg.stevenblack.enable (let
            inherit (cfg.stevenblack) whitelist whitelistRegex;
            pattern =
              if whitelist == [] && whitelistRegex == []
              then null
              else let
                escapedWhitelist = lib.map (w: "\\s" + (lib.escape ["."] w) + "$") whitelist;
                escapedWhitelistRegex = lib.map (r:
                  if lib.hasPrefix "^" r
                  then "\\s" + (lib.removePrefix "^" r)
                  else r)
                whitelistRegex;
              in
                lib.concatStringsSep "|" (escapedWhitelist ++ escapedWhitelistRegex);
            extract = "awk '$1 == \"0.0.0.0\" && $2 && $1 != $2 { print \"=\" $2 }'";
          in
            pkgs.runCommand "blocked-names" {} (lib.concatMapStringsSep "\n" (b: let
              hostsFile = "${lib.getOutput b pkgs.stevenblack-blocklist}/hosts";
            in
              if isNull pattern
              then "${extract} ${hostsFile} >> $out"
              else "sed -E '/${pattern}/d' ${hostsFile} | ${extract} >> $out")
            ["ads" "fakenews" "gambling" "porn"]));
        };
      };
    };
    users.users.${config.cfg.core.username} = {extraGroups = ["networkmanager"];};
  };
}
