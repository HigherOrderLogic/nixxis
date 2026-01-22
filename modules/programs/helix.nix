{
  inputs,
  lib,
  lib',
  pkgs,
  config,
  ...
}: let
  cfg = config.cfg.programs.helix;

  inherit (inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}) helix;
  helixWrapped = pkgs.symlinkJoin {
    name = "${lib.getName helix}-wrapped";
    paths = [helix];
    nativeBuildInputs = [pkgs.makeBinaryWrapper];
    postBuild = ''
      wrapProgram $out/bin/hx --prefix PATH : ${lib.makeBinPath (
        builtins.concatLists [
          (lib.optionals cfg.languages.nix.enable (with pkgs; [nil nixd]))
          (lib.optionals cfg.languages.rust.enable (with pkgs; [rust-analyzer clippy crates-lsp]))
          (lib.optional cfg.languages.cpp.enable (pkgs.writeShellScriptBin "clangd" ''
            ${lib.getExe' pkgs.clang-tools "clangd"} "$@"
          ''))
          (lib.optionals cfg.languages.python.enable (with pkgs; [basedpyright ruff]))
          (lib.optional cfg.languages.java.enable pkgs.jdt-language-server)
          (lib.optionals cfg.languages.markdown.enable (with pkgs; [marksman harper]))
          (lib.optional cfg.languages.yaml.enable pkgs.yaml-language-server)
        ]
      )}
    '';
  };

  toml = pkgs.formats.toml {};
in {
  options.cfg.programs.helix = {
    enable = lib.mkEnableOption "helix";
    defaultEditor = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set Helix as the default editor.";
    };
    trueColor = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = "Override Helix's automatic terminal truecolor support detection.";
    };
    languages = {
      nix.enable = lib'.mkEnableTrueOption "nix";
      rust.enable = lib'.mkEnableTrueOption "rust";
      cpp.enable = lib'.mkEnableTrueOption "cpp";
      python.enable = lib'.mkEnableTrueOption "python";
      java.enable = lib'.mkEnableTrueOption "java";
      markdown.enable = lib'.mkEnableTrueOption "markdown";
      yaml.enable = lib'.mkEnableTrueOption "yaml";
    };
    integrations = {
      gitui.enable = lib'.mkEnableTrueOption "gitui";
      jjui.enable = lib'.mkEnableTrueOption "jjui";
    };
    extraConfig = lib.mkOption {
      inherit (toml) type;
      default = {};
      description = "Extra configuration for Helix.";
    };
  };
  config = lib.mkIf cfg.enable {
    hj = {
      packages = [helixWrapped];
      environment.sessionVariables = {
        EDITOR = lib.mkIf cfg.defaultEditor (lib.mkForce "hx");
      };
      xdg.config.files = {
        "helix/config.toml".source = toml.generate "helix-config.toml" ({
            editor =
              {
                line-number = "relative";
                soft-wrap.enable = true;
                rainbow-brackets = true;
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
              }
              // lib.optionalAttrs (cfg.trueColor != null) {true-color = cfg.trueColor;};
            keys = {
              insert = {
                C-left = "move_prev_word_start";
                C-right = ["move_next_word_start" "extend_char_right"];
              };
              normal = {
                C-g = lib.optionals cfg.integrations.gitui.enable [
                  ":write-all"
                  ":new"
                  ":insert-output ${lib.getExe pkgs.gitui} >/dev/tty"
                  ":buffer-close!"
                  ":redraw"
                  ":reload-all"
                ];
                C-j = lib.optionals cfg.integrations.jjui.enable [
                  ":write-all"
                  ":new"
                  ":insert-output ${lib.getExe pkgs.jjui} >/dev/tty"
                  ":buffer-close!"
                  ":redraw"
                  ":reload-all"
                ];
              };
            };
          }
          // cfg.extraConfig);
        "helix/languages.toml".source = toml.generate "helix-languages-config.toml" {
          language = builtins.concatLists [
            (lib.optional cfg.languages.nix.enable {
              name = "nix";
              language-servers = ["nil" "nixd"];
            })
            (lib.optionals cfg.languages.rust.enable [
              {
                name = "rust";
                language-servers = ["rust-analyzer"];
              }
              {
                name = "toml";
                language-servers = ["crates-lsp"];
              }
            ])
            (lib.optional cfg.languages.cpp.enable {
              name = "cpp";
              language-servers = ["clangd"];
            })
            (lib.optional cfg.languages.python.enable {
              name = "python";
              language-servers = ["basedpyright" "ruff"];
            })
            (lib.optional cfg.languages.java.enable {
              name = "java";
              language-servers = ["jdtls"];
            })
            (lib.optional cfg.languages.markdown.enable {
              name = "markdown";
              language-servers = ["marksman" "harper-ls"];
            })
            (lib.optional cfg.languages.yaml.enable {
              name = "yaml";
              language-servers = ["yaml-language-server"];
            })
          ];
          language-server = {
            crates-lsp = lib.optionalAttrs cfg.languages.rust.enable {
              command = "crates-lsp";
              except-features = ["format"];
            };
          };
        };
      };
    };
  };
}
