{
  lib,
  writers,
  npins,
}:
writers.writeNuBin "pins-updater" {makeWrapperArgs = ["--prefix" "PATH" ":" (lib.makeBinPath [npins])];} (builtins.readFile ./main.nu)
