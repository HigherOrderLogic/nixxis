{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.cfg.desktops.niri;

  niri = pkgs.localPackages.niri-git;
in {
  imports = [./services.nix];
  options.cfg.desktops.niri = {
    enable = lib.mkEnableOption "Niri";
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Set extra Niri config.";
    };
  };
  config = lib.mkIf cfg.enable {
    services.displayManager.sessionPackages = [niri];
    hj = {
      packages = lib.flatten [niri (with pkgs; [fuzzel phinger-cursors])];
      environment.sessionVariables = {
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        QT_QPA_PLATFORM = "wayland";
      };
      xdg.config.files."niri/config.kdl".source = pkgs.writeTextFile {
        name = "niri-config.kdl";
        text = let
          fuzzel = lib.getExe pkgs.fuzzel;
          wlCopy = lib.getExe' pkgs.wl-clipboard "wl-copy";
          cliphist = lib.getExe pkgs.cliphist;
          wpctl = lib.getExe' pkgs.wireplumber "wpctl";
          fuzzelEmoji = lib.getExe (pkgs.writeShellScriptBin "fuzzel-emoji" ''
            cat ${./emojis.txt} | ${fuzzel} --match-mode fzf --dmenu | cut -d ' ' -f 1 | tr -d '\n' | ${wlCopy}
          '');
          volumeControl = lib.getExe (pkgs.writeScriptBin "volume-control" ''
            if [[ -n $2 ]]; then
              _sink=$2
            else
              _sink=@DEFAULT_AUDIO_SINK@
            fi

            _volume=$(${wpctl} get-volume "''${_sink}")

            down() {
              if ! echo $${_volume} | grep -q '[MUTED]'; then
                ${wpctl} set-volume "''${_sink}" 2%-
              fi
            }

            up() {
              if ! echo $${_volume} | grep -q '[MUTED]'; then
            	  ${wpctl} set-volume -l 1.0 "''${_sink}" 2%+
              fi
            }

            case "$1" in
              up) up ;;
              down) down ;;
            esac
          '');
          spawnBindsCfg = pkgs.writeText "spawn-binds.kdl" ''
            binds {
              Mod+Return hotkey-overlay-title="Open terminal" repeat=false { spawn "foot"; }
              Mod+Space hotkey-overlay-title="Open launcher" repeat=false { spawn-sh "pkill fuzzel || ${fuzzel}"; }
              Mod+Period hotkey-overlay-title="Open emoji picker" repeat=false { spawn-sh "pkill fuzzel || ${fuzzelEmoji}"; }
              Mod+V hotkey-overlay-title="Open clipboard history" repeat=false { spawn-sh "pkill fuzzel || ${cliphist} list | ${fuzzel} --match-mode fzf --dmenu | ${cliphist} decode | ${wlCopy}"; }
              XF86AudioRaiseVolume allow-when-locked=true { spawn "${volumeControl}" "up"; }
              XF86AudioLowerVolume allow-when-locked=true { spawn "${volumeControl}" "down"; }
              XF86AudioMute allow-when-locked=true { spawn "${wpctl}" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
              XF86AudioMicMute allow-when-locked=true { spawn "${wpctl}" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
            }
          '';

          xwaylandCfg = pkgs.writeText "xwayland.kdl" ''
            xwayland-satellite {
              path "${lib.getExe pkgs.xwayland-satellite}"
            }
          '';
          extraCfg = pkgs.writeText "extra.kdl" cfg.extraConfig;
        in
          lib.pipe ./config [
            builtins.readDir
            (lib.filterAttrs (_: v: v == "regular"))
            lib.attrNames
            (lib.map (v: "${./config}/${v}"))
            (v: v ++ [xwaylandCfg spawnBindsCfg] ++ lib.optional (cfg.extraConfig != "") extraCfg)
            (lib.concatMapStrings (v: ''
              include "${v}"
            ''))
          ];
        checkPhase = "${lib.getExe niri} validate -c $target";
      };
    };
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [kdePackages.xdg-desktop-portal-kde xdg-desktop-portal-gnome xdg-desktop-portal-gtk];
      config = {
        niri = {
          default = ["kde" "gtk"];
          "org.freedesktop.impl.portal.ScreenCast" = "gnome";
          "org.freedesktop.impl.portal.Screenshot" = "gnome";
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        };
      };
    };
  };
}
