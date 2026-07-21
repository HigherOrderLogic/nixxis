{
  lib,
  writers,
  npins,
}:
writers.writeNuBin "pins-updater" {
  makeWrapperArgs = ["--prefix" "PATH" ":" (lib.makeBinPath [npins])];
  check = writers.writeNu "nu-check" ''
    def main [file: string] {
      nu-check $file
    }
  '';
} (builtins.readFile ./main.nu)
