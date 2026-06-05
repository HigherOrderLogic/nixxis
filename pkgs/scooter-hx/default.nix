{
  pins,
  stdenv,
  rustPlatform,
  fd,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  name = "scooter-hx";

  src = pins.scooter-hx;

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  cargoBuildFlags = ["--lib"];

  nativeBuildInputs = [fd];

  installPhase = ''
    runHook preInstall

    fd -t f -e scm -x install -Dm 644 '{}' -t "$out/lib/steel/cogs/${finalAttrs.name}/{//}"
    for file in target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/*.so; do
      install -Dm 755 "$file" -t $out/lib/steel/native/
    done

    runHook postInstall
  '';

  doCheck = false;
  dontCargoInstall = true;

  passthru.pluginEntrypoint = "scooter.scm";
})
