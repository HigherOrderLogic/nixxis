{
  mkShell,
  npins,
}:
mkShell {
  packages = [npins];
  env.NPINS_DIRECTORY = "pins";
}
