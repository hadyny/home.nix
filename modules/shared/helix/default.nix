{
  pkgs,
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.settings.helix;
in
{
  options.settings.helix = {
    enable = mkEnableOption "Enable Helix editor configuration";
  };

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;
      extraPackages = with pkgs; [
        nil
        lua-language-server
        roslyn-ls
        typescript-language-server
        vscode-langservers-extracted
        tailwindcss-language-server
        prettierd
        marksman
        nixpkgs-fmt
      ];

      settings = {
        theme = "rose_pine";

        editor = {
          line-number = "relative";
          mouse = true;
          true-color = true;
          color-modes = true;
          cursorline = true;
          popup-border = "all";
          completion-replace = true;
          continue-comments = false;

          cursor-shape = {
            insert = "underline";
            normal = "block";
            select = "bar";
          };

          lsp = {
            display-inlay-hints = true;
            display-messages = true;
          };

          indent-guides.render = true;

          statusline = {
            left = [
              "mode"
              "spinner"
            ];
            center = [
              "file-name"
              "file-modification-indicator"
            ];
            right = [
              "version-control"
              "diagnostics"
              "selections"
              "position"
              "file-type"
            ];
          };

          inline-diagnostics = {
            cursor-line = "hint";
            other-lines = "error";
          };
        };

        keys.normal = {
          "{" = [
            "goto_prev_paragraph"
            "collapse_selection"
          ];
          "}" = [
            "goto_next_paragraph"
            "collapse_selection"
          ];
          "C-h" = [
            "jump_view_left"
            "normal_mode"
          ];
          "C-l" = [
            "jump_view_right"
            "normal_mode"
          ];
          "C-k" = [
            "jump_view_up"
            "normal_mode"
          ];
          "C-j" = [
            "jump_view_down"
            "normal_mode"
          ];
          "V" = [
            "select_mode"
            "extend_to_line_bounds"
          ];
          "K" = [ "hover" ];
        };
      };

      languages = {
        language-server = {
          nil = {
            command = "nil";
          };

          lua-language-server = {
            command = "lua-language-server";
          };

          marksman = {
            command = "marksman";
            args = [ "server" ];
          };

          roslyn-ls = {
            command = "Microsoft.CodeAnalysis.LanguageServer";
            args = [
              "--logLevel"
              "Information"
              "--stdio"
            ];
          };

          typescript-language-server = {
            command = "typescript-language-server";
            args = [ "--stdio" ];
          };

          eslint = {
            command = "vscode-eslint-language-server";
            args = [ "--stdio" ];
            config = {
              nodePath = "";
              experimental.useFlatConfig = true;
              workingDirectory.mode = "auto";
              format.enable = false;
              codeActionsOnSave = {
                mode = "all";
                "source.fixAll.eslint" = true;
              };
            };
          };

          tailwindcss = {
            command = "tailwindcss-language-server";
            args = [ "--stdio" ];
            language-id = "typescriptreact";
          };
        };

        language = [
          {
            name = "nix";
            auto-format = true;
            language-servers = [ "nil" ];
            formatter.command = "nixpkgs-fmt";
          }
          {
            name = "lua";
            auto-format = true;
            language-servers = [ "lua-language-server" ];
          }
          {
            name = "markdown";
            auto-format = true;
            language-servers = [ "marksman" ];
          }
          {
            name = "c-sharp";
            auto-format = true;
            language-servers = [ "roslyn-ls" ];
          }
          {
            name = "typescript";
            auto-format = true;
            language-servers = [
              {
                name = "typescript-language-server";
                except-features = [ "format" ];
              }
              { name = "tailwindcss"; }
              { name = "eslint"; }
            ];
            formatter = {
              command = "prettierd";
              args = [
                "--stdin-filepath"
                "x.ts"
              ];
            };
          }
          {
            name = "tsx";
            auto-format = true;
            language-servers = [
              {
                name = "typescript-language-server";
                except-features = [ "format" ];
              }
              { name = "tailwindcss"; }
              { name = "eslint"; }
            ];
            formatter = {
              command = "prettierd";
              args = [
                "--stdin-filepath"
                "x.tsx"
              ];
            };
          }
          {
            name = "javascript";
            auto-format = true;
            language-servers = [
              {
                name = "typescript-language-server";
                except-features = [ "format" ];
              }
              { name = "tailwindcss"; }
              { name = "eslint"; }
            ];
            formatter = {
              command = "prettierd";
              args = [
                "--stdin-filepath"
                "x.js"
              ];
            };
          }
          {
            name = "jsx";
            auto-format = true;
            language-servers = [
              {
                name = "typescript-language-server";
                except-features = [ "format" ];
              }
              { name = "tailwindcss"; }
              { name = "eslint"; }
            ];
            formatter = {
              command = "prettierd";
              args = [
                "--stdin-filepath"
                "x.jsx"
              ];
            };
          }
        ];
      };
    };
  };
}
