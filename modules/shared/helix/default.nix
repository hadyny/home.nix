{ inputs, pkgs, ... }:
{
  programs.helix = {
    enable = true;
    # package = pkgs.unstable.helix;
    package = inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default;
    extraPackages = with pkgs; [
      nixpkgs-fmt
      vtsls
      vscode-langservers-extracted
      emmet-language-server
      fsautocomplete
      prettierd
      roslyn-ls
      scooter
      tailwindcss-language-server
    ];
    # defaultEditor = true;
    settings = {
      theme = "tokyonight";
      editor = {
        line-number = "relative";
        mouse = true;
        auto-info = true;
        true-color = true;
        color-modes = true;
        popup-border = "all";
        completion-replace = true;
        continue-comments = false;
        cursorline = true;

        cursor-shape = {
          insert = "underline";
          normal = "block";
          select = "bar";
        };

        lsp = {
          display-inlay-hints = true;
          display-messages = true;
          display-progress-messages = true;
        };

        indent-guides.render = true;
        whitespace.render = {
          tab = "none";
          space = "none";
          newline = "none";
        };

        whitespace.characters = {
          space = "·";
          nbsp = "⍽";
          tab = "→";
          newline = "⏎";
          tabpad = "·";
        };

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
            "file-encoding"
            "file-line-ending"
            "file-type"
            "total-line-numbers"
          ];
        };

        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "error";
        };
      };

      keys = {
        normal = {
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

          "C-g" = [
            ":write-all"
            ":insert-output lazygit >/dev/tty"
            ":redraw"
            ":reload-all"
          ];

          "b" =
            ":echo %sh{git blame --date=short -L %{cursor_line},+1 %{buffer_name} | cut -d' ' -f1-4 | sed 's/$/)/g'}";

          "C-r" = [
            ":write-all"
            ":insert-output scooter >/dev/tty"
            ":redraw"
            ":reload-all"
          ];

          space = {
            "e" = [
              ":sh rm -f /tmp/unique-file-h21a434"
              ":insert-output yazi '%{buffer_name}' --chooser-file=/tmp/unique-file-h21a434"
              ":insert-output echo \"x1b[?1049h\" > /dev/tty"
              ":open %sh{cat /tmp/unique-file-h21a434}"
              ":redraw"
              ":set mouse false"
              ":set mouse true"
            ];
          };
        };
      };
    };

    languages = {
      language-server = {
        eslint = {
          args = [ "--stdio" ];
          command = "vscode-eslint-language-server";

          config = {
            nodePath = "";
            experimental = {
              useFlatConfig = true;
            };
            workingDirectory.mode = "auto";
            format.enable = false;
            codeActionsOnSave = {
              mode = "all";
              "source.fixAll.eslint" = true;
            };
          };
        };

        typescript-language-server = {
          command = "vtsls";
        };

        typescript-language-server.config.javascript.inlayHints = {
          includeInlayEnumMemberValueHints = false;
          includeInlayFunctionLikeReturnTypeHints = false;
          includeInlayFunctionParameterTypeHints = false;
          includeInlayParameterNameHints = "all";
          includeInlayParameterNameHintsWhenArgumentMatchesName = false;
          includeInlayPropertyDeclarationTypeHints = false;
          includeInlayVariableTypeHints = false;
        };
        typescript-language-server.config.typescript.inlayHints = {
          includeInlayEnumMemberValueHints = false;
          includeInlayFunctionLikeReturnTypeHints = false;
          includeInlayFunctionParameterTypeHints = false;
          includeInlayParameterNameHints = "all";
          includeInlayParameterNameHintsWhenArgumentMatchesName = false;
          includeInlayPropertyDeclarationTypeHints = false;
          includeInlayVariableTypeHints = false;
        };

        roslyn-ls = {
          command = "Microsoft.CodeAnalysis.LanguageServer";
          args = [
            "--logLevel"
            "Information"
            "--extensionLogDirectory"
            "/tmp/roslyn_ls/logs"
            "--stdio"
          ];
        };

        csls = {
          command = "csharp-language-server";
        };

        tailwindcss = {
          language-id = "typescriptreact";
          command = "tailwindcss-language-server";
          args = [ "--stdio" ];

        };
      };

      language = [
        {
          name = "javascript";
          indent = {
            tab-width = 4;
            unit = "    ";
          };
          auto-format = true;
          language-servers = [
            {
              except-features = [ "format" ];
              name = "typescript-language-server";
            }
            "tailwindcss"
            "eslint"
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
          indent = {
            tab-width = 4;
            unit = "    ";
          };
          auto-format = true;
          language-servers = [
            {
              except-features = [ "format" ];
              name = "typescript-language-server";
            }
            "tailwindcss"
            "eslint"
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
          name = "typescript";
          indent = {
            tab-width = 4;
            unit = "    ";
          };
          auto-format = true;
          language-servers = [
            {
              except-features = [ "format" ];
              name = "typescript-language-server";
            }
            "tailwindcss"
            "eslint"
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
          name = "tsx";
          indent = {
            tab-width = 4;
            unit = "    ";
          };
          auto-format = true;
          language-servers = [
            {
              except-features = [ "format" ];
              name = "typescript-language-server";
            }
            "tailwindcss"
            "eslint"
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
          name = "css";
          indent = {
            tab-width = 4;
            unit = "    ";
          };
          auto-format = true;
        }
        {
          name = "scss";
          indent = {
            tab-width = 4;
            unit = "    ";
          };
          auto-format = true;
        }
        {
          name = "json";
          indent = {
            tab-width = 4;
            unit = "    ";
          };
          auto-format = true;
        }
        {
          name = "yaml";
          indent = {
            tab-width = 4;
            unit = "    ";
          };
          auto-format = true;
        }
        {
          name = "html";
          indent = {
            tab-width = 4;
            unit = "    ";
          };
          auto-format = true;
        }
        {
          name = "nix";
          indent = {
            tab-width = 2;
            unit = "  ";
          };
          auto-format = true;
          formatter = {
            command = "nixpkgs-fmt";
          };
        }
        {
          name = "c-sharp";
          indent = {
            tab-width = 4;
            unit = "  ";
          };
          auto-format = true;
          language-servers = [
            # "roslyn-ls"
            "csls"
          ];
        }
      ];
    };
  };
}
