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
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (final) src;
    hash = "sha256-gfnalA3qI3a9h3PvsxgQLCrzapfjLLkxhTMJpwRh+ro=";
  };
  env =
    prev.env
    // {
      RUSTFLAGS = "${prev.env.RUSTFLAGS} -C target-cpu=native";
      NIRI_BUILD_COMMIT = final.src.revision;
    };
})
