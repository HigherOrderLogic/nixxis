{
  pins,
  runCommand,
  callPackage,
}: let
  pin = pins.helix;
  pin' = runCommand "helix-pin" {} ''
    cp -r ${pin} $out

    substituteInPlace $out/grammars.nix --replace-fail 'stdenv.isLinux' 'stdenv.hostPlatform.isLinux'
  '';
in
  callPackage "${pin'}/default.nix" {gitRev = pin.revision;}
