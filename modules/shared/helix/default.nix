{
  pkgs,
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.settings.helix;

  # ts/tsx/js/jsx share one language-server stack and the prettierd formatter,
  # differing only by language name and the filename prettierd is told to use.
  mkTsLang =
    { lang, ext }:
    {
      name = lang;
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
          "x.${ext}"
        ];
      };
    };
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
        csharp-language-server
        typescript-language-server
        vscode-langservers-extracted
        tailwindcss-language-server
        prettierd
        marksman
        nixfmt-rfc-style
      ];

      settings = {
        theme = "catppuccin_mocha";

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

          # Wrapper around Microsoft.CodeAnalysis.LanguageServer (Roslyn) that
          # patches its initialize response to advertise pull diagnostics, which
          # Helix otherwise never receives (dotnet/roslyn#76624). The wrapper
          # fetches and manages its own Roslyn build on first launch.
          csharp-language-server = {
            command = "csharp-language-server";
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
            formatter.command = "nixfmt";
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
            language-servers = [ "csharp-language-server" ];
          }
        ]
        ++ map mkTsLang [
          {
            lang = "typescript";
            ext = "ts";
          }
          {
            lang = "tsx";
            ext = "tsx";
          }
          {
            lang = "javascript";
            ext = "js";
          }
          {
            lang = "jsx";
            ext = "jsx";
          }
        ];
      };
    };
  };
}
