{
  lib,
  localPackages,
  nix,
  nix-output-monitor,
}:
localPackages.writeCheckedNuBin "image-builder" {makeWrapperArgs = ["--prefix" "PATH" ":" (lib.makeBinPath [nix nix-output-monitor])];} ./main.nu
