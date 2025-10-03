{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.cfg.core.kernel;
in {
  options.cfg.core.kernel.type = lib.mkOption {
    type = lib.types.enum ["latest" "lts" "zen" "xanmod" "lqx"];
    default = "latest";
    description = "Set the Linux kenel type to use.";
  };
  config = {
    boot = {
      kernelPackages =
        if cfg.type == "latest"
        then pkgs.linuxPackages_latest
        else if cfg.type == "lts"
        then pkgs.linuxPackages
        else if cfg.type == "zen"
        then pkgs.linuxKernel.packages.linux_zen
        else if cfg.type == "xanmod"
        then pkgs.linuxKernel.packages.linux_xanmod_latest
        else if cfg.type == "lqx"
        then pkgs.linuxKernel.packages.linux_lqx
        else throw "Unknown kernel type.";
      kernel.sysctl."kernel.panic" = 5;
    };
  };
}
