{
  lib,
  localPackages,
  npins,
}:
localPackages.writeCheckedNuBin "pins-updater" {makeWrapperArgs = ["--prefix" "PATH" ":" (lib.makeBinPath [npins])];} ./main.nu
