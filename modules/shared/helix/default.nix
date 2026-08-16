{
  pkgs,
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.settings.helix;

  # Build a wrapper that prefers a project binary over the Nix binary.
  #
  # `name` is the binary to look for. `fallback` is the binary that Nix supplies.
  # Set `node` to true for a tool that a package can install into
  # `node_modules/.bin`.
  #
  # Helix starts each language server in the workspace root. See
  # helix-lsp/src/client.rs, which calls `.current_dir(&root_path)`. The wrapper
  # therefore searches upwards from the current directory to find
  # `node_modules/.bin`.
  #
  # The wrapper has the suffix `-local`, so its own name is different from the
  # name it looks for. The PATH search cannot find the wrapper itself.
  # `launcher` runs in front of the server that the search finds. It stays empty
  # for a server that Helix starts directly.
  localFirst =
    {
      name,
      fallback,
      node ? true,
      launcher ? "",
    }:
    pkgs.writeShellScriptBin "${name}-local" ''
      server=""

      ${optionalString node ''
        # 1. Use a binary from the project, if the project supplies one.
        dir=$PWD
        while [ "$dir" != "/" ]; do
          if [ -x "$dir/node_modules/.bin/${name}" ]; then
            server="$dir/node_modules/.bin/${name}"
            break
          fi
          dir=$(dirname "$dir")
        done
      ''}

      # 2. Use a binary from PATH. A devenv or direnv shell can supply one.
      if [ -z "$server" ]; then
        server=$(command -v ${name} 2>/dev/null || true)
      fi

      # 3. Use the binary that Nix supplies.
      if [ -z "$server" ]; then
        server=${fallback}
      fi

      exec ${launcher} "$server" "$@"
    '';

  lspWrappers = map localFirst [
    {
      name = "nixd";
      fallback = "${pkgs.nixd}/bin/nixd";
      node = false;
    }
    {
      # nixpkgs names the binary after the assembly, not after the server.
      name = "roslyn-language-server";
      fallback = "${pkgs.roslyn-ls}/bin/Microsoft.CodeAnalysis.LanguageServer";
      node = false;
    }
    {
      name = "typescript-language-server";
      fallback = "${pkgs.typescript-language-server}/bin/typescript-language-server";
    }
    {
      name = "vscode-eslint-language-server";
      fallback = "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server";
      # The proxy adds the workspace folder that Helix cannot supply. Read the
      # comment at the top of the script for the reason.
      launcher = "${pkgs.nodejs}/bin/node ${./eslint-workspace-folder-proxy.js}";
    }
    {
      name = "tailwindcss-language-server";
      fallback = "${pkgs.tailwindcss-language-server}/bin/tailwindcss-language-server";
    }
  ];

  # ts/tsx/js/jsx share one language-server stack and the prettierd formatter,
  # differing only by language name.
  mkTsLang = lang: {
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
      # prettierd reads the prettier configuration and the prettier library
      # from the directory of this path. See service.js in @fsouza/prettierd,
      # which calls `require.resolve("prettier", { paths: [filePath] })`. A
      # relative dummy name makes prettierd read from the wrong directory, so
      # the true path of the file is necessary. Helix expands the variable. See
      # helix-view/src/expansion.rs.
      args = [
        "--stdin-filepath"
        "%{file_path_absolute}"
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
      # home-manager adds these to the end of PATH, not the start. A binary that
      # is already on PATH therefore has precedence.
      extraPackages =
        lspWrappers
        ++ (with pkgs; [
          lua-language-server
          roslyn-ls
          prettierd
          marksman
          nixfmt
        ]);

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
          # nixd reads `.nixd.json` from the workspace root, so the options for
          # nixpkgs and for the nix-darwin modules stay with each repository.
          nixd = {
            command = "nixd-local";
          };

          lua-language-server = {
            command = "lua-language-server";
          };

          marksman = {
            command = "marksman";
            args = [ "server" ];
          };

          # Microsoft.CodeAnalysis.LanguageServer (Roslyn) from nixpkgs.
          #
          # Roslyn selects how it supplies pull diagnostics from the capability
          # that the client sends. Helix sends `dynamic_registration: false`
          # (helix-lsp/src/client.rs), so Roslyn puts `diagnosticProvider` in the
          # initialize response. Helix then enables the feature. See
          # `LanguageServerFeature::PullDiagnostics` in the same file.
          #
          # These are also the Helix default arguments, but they stay here to
          # keep them clear and to keep them stable.
          roslyn-language-server = {
            command = "roslyn-language-server-local";
            args = [
              "--stdio"
              "--autoLoadProjects"
            ];
          };

          typescript-language-server = {
            command = "typescript-language-server-local";
            args = [ "--stdio" ];
          };

          # This name is not a Helix default name, so this server inherits no
          # default configuration. Each necessary key is therefore present here.
          eslint = {
            command = "vscode-eslint-language-server-local";
            args = [ "--stdio" ];
            config = {
              validate = "on";
              run = "onType";
              # `auto` lets the server find the ESLint configuration of each
              # package in a monorepo. The search starts at the file and stops
              # at the workspace folder, which the proxy supplies.
              workingDirectory.mode = "auto";
              format.enable = false;
              codeActionsOnSave = {
                mode = "all";
                "source.fixAll.eslint" = true;
              };
            };
          };

          tailwindcss = {
            command = "tailwindcss-language-server-local";
            args = [ "--stdio" ];
            language-id = "typescriptreact";
          };
        };

        language = [
          {
            name = "nix";
            auto-format = true;
            # nixd only. The Helix default also lists nil, and the two servers
            # report the same problems twice.
            language-servers = [ "nixd" ];
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
            # The Helix default also lists omnisharp and csharp-ls.
            language-servers = [ "roslyn-language-server" ];
          }
        ]
        ++ map mkTsLang [
          "typescript"
          "tsx"
          "javascript"
          "jsx"
        ];
      };
    };
  };
}
