{lib}: {
  types = import ./types.nix {inherit lib;};

  mkEnableTrueOption = name:
    (lib.mkEnableOption name)
    // {
      default = true;
    };
}
