{
  lib,
  modulesPath,
  ...
}: {
  imports = ["${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ./options.nix];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "26.11";
}
