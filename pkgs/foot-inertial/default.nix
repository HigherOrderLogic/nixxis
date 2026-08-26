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
        hash = "sha256-IUF6D5bH2kHduyoe9Z/l96qhOw7P1YHQbFGEzv9BQ78=";
      })
    ];
})
