{
  lib,
  writers,
  nh,
}:
writers.writeNuBin "image-builder" {makeWrapperArgs = ["--prefix" "PATH" ":" (lib.makeBinPath [nh])];} (builtins.readFile ./main.nu)
