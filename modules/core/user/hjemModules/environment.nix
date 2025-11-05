{lib, ...}: {
  options.environment = {
    shellAliases = lib.mkOption {
      default = {};
      type = lib.types.attrsOf (lib.types.either lib.types.str lib.types.path);
    };
  };
}
