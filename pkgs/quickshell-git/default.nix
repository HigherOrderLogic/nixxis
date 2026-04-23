{
  pins,
  callPackage,
}: let
  pin = pins.quickshell;
in
  callPackage "${pin}/default.nix" {
    gitRev = pin.revision;
    withX11 = false;
    withHyprland = false;
    withI3 = false;
  }
