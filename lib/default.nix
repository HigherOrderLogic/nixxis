{lib}: {
  mkEnableTrueOption = name:
    (lib.mkEnableOption name)
    // {
      default = true;
    };
}
