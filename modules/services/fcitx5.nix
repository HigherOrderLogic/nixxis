{
  lib,
  lib',
  pkgs,
  config,
  ...
}: let
  cfg = config.cfg.services.fcitx5;

  fcitx5Pkg = pkgs.qt6Packages.fcitx5-with-addons.override {addons = lib.optional cfg.languages.vietnamese.enable pkgs.qt6Packages.fcitx5-unikey;};
in {
  options.cfg.services.fcitx5 = {
    enable = lib.mkEnableOption "fcitx5";
    languages.vietnamese.enable = lib'.mkEnableTrueOption "Vietnamese";
  };
  config = lib.mkIf cfg.enable {
    hj = {
      packages = [fcitx5Pkg];
      environment.sessionVariables = {
        XMODIFIERS = "@im=fcitx";
        QT_PLUGIN_PATH = ["${fcitx5Pkg}/${pkgs.qt6.qtbase.qtPluginPrefix}"];
        SDL_IM_MODULES = "fcitx";
        GTK_IM_MODULE = "fcitx";
        QT_IM_MODULE = "fcitx";
      };
    };
  };
}
