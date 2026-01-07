{lib, ...}: {
  imports = [./hardware.nix ./options.nix];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.11";
}
