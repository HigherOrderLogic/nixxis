{lib, ...}: {
  config = {
    boot.tmp = {
      useTmpfs = true;
      tmpfsSize = "50%";
    };
    programs.command-not-found.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;
    environment.defaultPackages = lib.mkDefault [];
  };
}
