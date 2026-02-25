{
  pins,
  lib,
  ...
}: {
  nixpkgs.overlays = [
    (self: _: {
      localPackages = lib.pipe ./. [
        builtins.readDir
        (lib.filterAttrs (_: v: v == "directory"))
        (builtins.mapAttrs (k: _: self.callPackage "${./.}/${k}" {inherit pins;}))
      ];
    })
  ];
}
