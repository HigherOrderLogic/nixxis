{
  pins,
  foot,
  fetchpatch,
}:
foot.overrideAttrs (final: prev: {
  pname = "${prev.pname}-inertial";
  patches =
    (prev.patches or [])
    ++ [
      (fetchpatch {
        name = "intertial-scrolling-support";
        url = "https://codeberg.org/dnkl/foot/compare/${final.version}..${pins.foot-inertial.revision}.patch";
        hash = "sha256-qADEo04lqJDPUuAfnv9Km6tb/sUZTNHQ48KgdMVshq8=";
      })
    ];
})
