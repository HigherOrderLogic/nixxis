{
  pins,
  rustPlatform,
  niri,
}:
niri.overrideAttrs (final: prev: {
  pname = "${prev.pname}-git";
  src = pins.niri;
  postPatch =
    prev.postPatch
    + ''
      substituteInPlace resources/niri.desktop --replace-fail 'Exec=niri-session' "Exec=$out/bin/niri-session"
    '';
  cargoDeps = rustPlatform.importCargoLock {
    lockFile = "${final.src}/Cargo.lock";
    allowBuiltinFetchGit = true;
  };
  env = prev.env // {NIRI_BUILD_COMMIT = final.src.revision;};
})
