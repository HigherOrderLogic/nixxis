{lib, ...}: {
  config = {
    boot.tmp = {
      useTmpfs = true;
      tmpfsSize = "50%";
    };
    system.tools.nixos-generate-config.enable = lib.mkDefault false;
    programs.command-not-found.enable = false;
    services.journald.settings.Journal = {
      Storage = "volatile";
      MaxRetensionSec = "1day";
    };
    documentation = {
      info.enable = false;
      nixos.enable = false;
    };
    environment.defaultPackages = lib.mkDefault [];
  };
}
