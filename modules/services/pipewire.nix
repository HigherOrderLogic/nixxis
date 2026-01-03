{
  lib,
  config,
  ...
}: let
  cfg = config.cfg.services.pipewire;
in {
  options.cfg.services.pipewire.enable = lib.mkEnableOption "pipewire";
  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
}
