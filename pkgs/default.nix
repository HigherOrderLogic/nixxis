{
  pins,
  lib,
  pkgs,
}:
lib.pipe ./. [
  builtins.readDir
  (lib.filterAttrs (_: v: v == "directory"))
  (builtins.mapAttrs (k: _: pkgs.callPackage ./${k} {inherit pins;}))
]
