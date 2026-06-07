{
  pins,
  callPackage,
}: let
  pin = pins.helix;
in
  callPackage "${pin}/default.nix" {gitRev = pin.revision;}
