{lib, ...}: {
  config = {
    boot.tmp = {
      useTmpfs = true;
      tmpfsSize = "50%";
    };
    programs.command-not-found.enable = false;
    environment.defaultPackages = lib.mkDefault [];
  };
}
