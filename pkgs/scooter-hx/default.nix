{
  pins,
  stdenv,
  rustPlatform,
  fd,
}: let
  inherit (stdenv) hostPlatform;
in
  rustPlatform.buildRustPackage (finalAttrs: {
    name = "scooter";

    src = pins.scooter-hx;

    cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

    cargoBuildFlags = ["--lib"];

    nativeBuildInputs = [fd];

    installPhase = ''
      runHook preInstall

      fd -t f -e scm -x install -Dm 644 '{}' -t "$out/lib/steel/cogs/${finalAttrs.name}/{//}"
      for file in target/${hostPlatform.rust.cargoShortTarget}/release/*${hostPlatform.extensions.sharedLibrary}; do
        install -Dm 755 "$file" -t $out/lib/steel/native/
      done

      runHook postInstall
    '';

    doCheck = false;
    dontCargoInstall = true;

    passthru.pluginEntrypoint = "scooter.scm";
  })
