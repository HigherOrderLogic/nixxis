{lib, ...}: {
  config = {
    boot.tmp = {
      useTmpfs = true;
      tmpfsSize = "50%";
    };
    system.tools.nixos-generate-config.enable = lib.mkDefault false;
    programs.command-not-found.enable = false;
    services.journald = {
      storage = "volatile";
      extraConfig = ''
        MaxRetentionSec=1day
      '';
    };
    documentation = {
      info.enable = false;
      nixos.enable = false;
    };
    environment.defaultPackages = lib.mkDefault [];
  };
}
