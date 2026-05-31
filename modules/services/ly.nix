{
  lib,
  config,
  ...
}: let
  cfg = config.cfg.services.ly;
in {
  imports = [(lib.mkAliasOptionModule ["cfg" "services" "ly"] ["services" "displayManager" "ly"])];
  config = lib.mkIf cfg.enable {services.displayManager.ly.x11Support = false;};
}
