{ inputs, pkgs, ... }:
{
  programs.yazi.enable = true;
  programs.helix = {
    enable = true;
    package = inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default;
    extraPackages = with pkgs; [
      inputs.csharp-language-server.packages.${stdenv.hostPlatform.system}.default
      netcoredbg
      csharpier
      nixpkgs-fmt
      nil
      lua-language-server
      graphql-language-service-cli
      marksman
      vtsls
      vscode-langservers-extracted
      emmet-language-server
      fsautocomplete
      prettierd
      roslyn-ls
      scooter
      tailwindcss-language-server
      terraform-ls
    ];
    # defaultEditor = true;
    settings = {
      theme = "tokyonight";
      editor = {
        line-number = "relative";
        mouse = true;
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
            "version-control"
          ];
          right = [
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
        vscode-eslint-language-server = {
          command = "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server";
          args = [ "--stdio" ];
          config = {
            nodePath = "";
            quiet = false;
            rulesCustomizations = [
              {
                rule = "prettier/prettier";
                severity = "error";
              }
            ];
            run = "onType";
            validate = "on";
            codeAction = {
              disableRuleComment = {
                enable = true;
                location = "separateLine";
              };
              showDocumentation = {
                enable = true;
              };
            };
            experimental.useFlatConfig = true;
            problems = {
              shortenToSingleLine = false;
            };
            workingDirectory.mode = "auto";
            codeActionsOnSave = {
              enable = true;
              mode = "all";
            };
          };
        };

        typescript-language-server = {
          command = "vtsls";
          config = {
            javascript.inlayHints = {
              includeInlayEnumMemberValueHints = false;
              includeInlayFunctionLikeReturnTypeHints = false;
              includeInlayFunctionParameterTypeHints = false;
              includeInlayParameterNameHints = "all";
              includeInlayParameterNameHintsWhenArgumentMatchesName = false;
              includeInlayPropertyDeclarationTypeHints = false;
              includeInlayVariableTypeHints = false;
            };
            typescript.inlayHints = {
              # includeInlayEnumMemberValueHints = false;
              # includeInlayFunctionLikeReturnTypeHints = false;
              # includeInlayFunctionParameterTypeHints = false;
              includeInlayParameterNameHints = "all";
              # includeInlayParameterNameHintsWhenArgumentMatchesName = false;
              # includeInlayPropertyDeclarationTypeHints = false;
              # includeInlayVariableTypeHints = false;
            };
          };
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

        terraform = {
          command = "terraform-ls";
          args = [ "serve" ];
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
            "vscode-eslint-language-server"
          ];
          formatter = {
            command = "prettierd";
            args = [
              "--stdin-filepath"
              "x.js"
            ];
          };
          roots = [
            "package-lock.json"
            "tsconfig.json"
            ".prettierrc.json"
          ];
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
            "vscode-eslint-language-server"
          ];
          formatter = {
            command = "prettierd";
            args = [
              "--stdin-filepath"
              "x.ts"
            ];
          };
          roots = [
            "package-lock.json"
            "tsconfig.json"
            ".prettierrc.json"
          ];
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
            "vscode-eslint-language-server"
          ];
          formatter = {
            command = "prettierd";
            args = [
              "--stdin-filepath"
              "x.tsx"
            ];
          };
          roots = [
            "package-lock.json"
            "tsconfig.json"
            ".prettierrc.json"
          ];
        }
        {
          name = "graphql";
          language-servers = [
            {
              except-features = [ "format" ];
              name = "typescript-language-server";
            }
            "vscode-eslint-language-server"
          ];
          formatter = {
            command = "prettierd";
            args = [
              "--stdin-filepath"
              "x.graphql"
            ];
          };
          roots = [
            "package-lock.json"
            "tsconfig.json"
            ".prettierrc.json"
          ];
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
          formatter = {
            command = "csharpier";
            args = [ "format" ];
          };
        }
        {
          name = "hcl";
          language-servers = [ "terraform-ls" ];
          language-id = "terraform";
        }
        {
          name = "tfvars";
          language-servers = [ "terraform-ls" ];
          language-id = "terraform-vars";
        }
      ];
    };
  };
}
