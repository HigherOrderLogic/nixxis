{
  lib,
  callPackage,
}:
lib.pipe ./. [
  builtins.readDir
  (lib.filterAttrs (_: v: v == "directory"))
  (builtins.mapAttrs (k: _: callPackage ./${k} {}))
]
