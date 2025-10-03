{
  lib,
  pkgs,
  config,
  ...
}: let
  mkEnableTrueOption = name:
    (lib.mkEnableOption name)
    // {
      default = true;
    };
  cfg = config.cfg.programs.helix;

  inherit (pkgs) helix;
  helixWrapped = pkgs.symlinkJoin {
    name = "${lib.getName helix}-wrapped-${lib.getVersion helix}";
    paths = [helix];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/hx --prefix PATH : ${lib.makeBinPath (
        (lib.optional cfg.languages.nix.enable pkgs.nixd)
        ++ (lib.optionals cfg.languages.rust.enable (with pkgs; [rust-analyzer clippy]))
        ++ (lib.optionals cfg.languages.python.enable (with pkgs; [basedpyright ruff]))
        ++ (lib.optionals cfg.languages.markdown.enable (with pkgs; [marksman harper]))
        ++ (lib.optional cfg.languages.yaml.enable pkgs.yaml-language-server)
        ++ (lib.optional cfg.integrations.gitui.enable pkgs.gitui)
      )}
    '';
  };

  configFormat = pkgs.formats.toml {};
in {
  options.cfg.programs.helix = {
    enable = lib.mkEnableOption "helix";
    defaultEditor = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set Helix as the default editor.";
    };
    languages = {
      nix.enable = mkEnableTrueOption "nix";
      rust.enable = mkEnableTrueOption "rust";
      python.enable = mkEnableTrueOption "python";
      markdown.enable = mkEnableTrueOption "markdown";
      yaml.enable = mkEnableTrueOption "yaml";
    };
    integrations = {
      gitui.enable = mkEnableTrueOption "gitui";
    };
  };
  config = lib.mkIf cfg.enable {
    hj = {
      packages = [helixWrapped];
      environment.sessionVariables = {
        EDITOR = lib.mkIf cfg.defaultEditor (lib.mkForce "hx");
      };
      xdg.config.files = {
        "helix/config.toml".source = configFormat.generate "helix-config" {
          editor = {
            line-number = "relative";
            soft-wrap.enable = true;
            cursor-shape = {
              insert = "bar";
              select = "bar";
            };
            completion-timeout = 5;
            completion-replace = true;
            lsp.display-inlay-hints = true;
            end-of-line-diagnostics = "hint";
            inline-diagnostics.cursor-line = "hint";
            indent-guides = {
              render = true;
              character = "╎";
            };
            statusline = {
              left = ["mode" "spinner"];
              center = ["file-name" "read-only-indicator" "file-modification-indicator"];
              right = ["diagnostics" "version-control" "register" "file-encoding" "position"];
            };
          };
          keys = {
            insert = {
              C-left = "move_prev_word_start";
              C-right = ["move_next_word_start" "extend_char_right"];
            };
            normal = {
              C-g = lib.optionals cfg.integrations.gitui.enable [
                ":write-all"
                ":new"
                ":insert-output gitui >/dev/tty"
                ":buffer-close!"
                ":redraw"
                ":reload-all"
              ];
            };
          };
        };
        "helix/languages.toml".source = configFormat.generate "helix-languages-config" {
          language =
            (lib.optional cfg.languages.nix.enable {
              name = "nix";
              language-servers = ["nixd"];
            })
            ++ (lib.optional cfg.languages.rust.enable {
              name = "rust";
              language-servers = ["rust-analyzer"];
            })
            ++ (lib.optional cfg.languages.python.enable {
              name = "python";
              language-servers = ["basedpyright" "ruff"];
            })
            ++ (lib.optional cfg.languages.markdown.enable {
              name = "markdown";
              language-servers = ["marksman" "harper-ls"];
            })
            ++ (lib.optional cfg.languages.yaml.enable {
              name = "yaml";
              language-servers = ["yaml-language-server"];
            });
        };
      };
    };
  };
}
