{
  pins,
  rustPlatform,
  niri,
}:
niri.overrideAttrs (final: prev: {
  pname = "${prev.pname}-git";
  src = pins.niri;
  postPatch = ''
    patchShebangs resources/niri-session
    substituteInPlace resources/niri.service --replace-fail 'ExecStart=niri' "ExecStart=$out/bin/niri"
    substituteInPlace resources/niri.desktop --replace-fail 'Exec=niri-session' "Exec=$out/bin/niri-session"
  '';
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (final) src;
    hash = "sha256-uo4AWT4nGV56iiSLhXK30goI7HCPc7AUZjRLgUvLfUE=";
  };
})
