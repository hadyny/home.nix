{ pkgs, ... }:

{
  programs = {
    nixvim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      vimdiffAlias = true;

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      localOpts = {
        conceallevel = 2;
      };

      diagnostics = {
        signs.text = {
          __raw = ''
            {
              [vim.diagnostic.severity.ERROR] = " ";
              [vim.diagnostic.severity.WARN] = " ";
              [vim.diagnostic.severity.HINT] = " ";
              [vim.diagnostic.severity.INFO] = " ";
            }
          '';
        };

        severity_sort = true;
        virtual_text = {
          spacing = 4;
          source = "if_many";
          prefix = "●";
        };
      };

      opts = {
        mouse = "a";
        showmode = false;
        clipboard = "unnamedplus";
        breakindent = true;
        undofile = true;
        ignorecase = true;
        smartcase = true;
        signcolumn = "yes";
        updatetime = 250;
        timeoutlen = 300;
        list = true;
        listchars = { tab = "» "; trail = "·"; nbsp = "␣"; };
        inccommand = "split";
        cursorline = true;
        hlsearch = true;
        termguicolors = true;

        tabstop = 4;
        shiftwidth = 4;
      };

      # TODO: Get this working
      #autoCmd = [
      #  {
      #    event = "TextYankPost";
      #    desc = "Highlight when yanking (copying) text";
      #    group = "vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true })";
      #    callback = "function() vim.highlight.on_yank() end";
      #  }
      #];
      extraPlugins = [
        pkgs.vimPlugins.nvim-treesitter-parsers.lua
        pkgs.vimPlugins.nvim-treesitter-parsers.nix
        pkgs.vimPlugins.nvim-treesitter-parsers.norg
        pkgs.vimPlugins.nvim-treesitter-parsers.typescript
        pkgs.vimPlugins.nvim-treesitter-parsers.tsx
        pkgs.vimPlugins.nvim-treesitter-parsers.c_sharp
        pkgs.vimPlugins.nvim-treesitter-parsers.diff
        (pkgs.vimUtils.buildVimPlugin {
          name = "hlchunk";
          src = pkgs.fetchFromGitHub {
            owner = "shellRaining";
            repo = "hlchunk.nvim";
            rev = "882d1bc86d459fa8884398223c841fd09ea61b6b";
            hash = "sha256-fvFvV7KAOo7xtOCjhGS5bDUzwd10DndAKs3++dunED8=";
          };
        })
      ];

      extraConfigLua = ''
         require('hlchunk').setup({
          chunk = {
              enable = true
          },
          line_num = {
              enable = true
          },
          indent = {
            enable = false
          },
            blank = {
              enable = false
          }
        })
      '';

      plugins = {
        bufferline = {
          enable = true;
          settings.options.always_show_bufferline = false;
        };
        barbecue.enable = true;
        better-escape.enable = true;
        comment.enable = true;
        guess-indent.enable = true;
        indent-blankline = {
          enable = true;
          settings = {
            scope.enabled = false;
            indent = {
              char = "";
              highlight = [
                "CursorColumn"
                "Whitespace"
              ];
            };
            whitespace = {
              highlight = [
                "CursorColumn"
                "Whitespace"
              ];
              remove_blankline_trail = false;

            };
          };
        };
        notify.enable = true;
        gitsigns = {
          enable = true;
          settings = {
            preview_config = {
              border = "single";
              style = "minimal";
              relative = "cursor";
              row = 0;
              col = 1;
            };
            signs = {
              add = { text = "│"; };
              change = { text = "│"; };
              delete = { text = "󰍵"; };
              topdelete = { text = "‾"; };
              changedelete = { text = "~"; };
              untracked = { text = "│"; };
            };
          };
        };
        lualine = {
          enable = true;
          settings.extensions = [ "fzf" ];
        };
        lazygit = {
          enable = true;
          settings = {
            config_file_path = [ ];
            floating_window_scaling_factor = 0.9;
            floating_window_use_plenary = 0;
            floating_window_winblend = 0;
            use_custom_config_file_path = 0;
            use_neovim_remote = 1;
          };
        };
        navbuddy = {
          enable = true;
          lsp.autoAttach = true;
        };

        noice = {
          enable = true;
          notify = {
            enabled = true;
          };
          messages = {
            enabled = true;
            view = "mini";
          };
          lsp = {
            message = {
              enabled = true;
            };
            progress = {
              enabled = true;
              view = "mini";
            };
            override = {
              "vim.lsp.util.convert_input_to_markdown_lines" = true;
              "vim.lsp.util.stylize_markdown" = true;
              "cmp.entry.get_documentation" = true;
            };
          };
          presets = {
            command_palette = true;
            long_message_to_split = true;
            lsp_doc_border = "single";
          };
        };

        obsidian = {
          enable = true;
          settings = {
            completion.nvim_cmp = true;
            workspaces = [
              {
                name = "notes";
                path = "~/Documents/Vault";
              }
            ];
          };
        };
        nvim-autopairs.enable = true;

        neotest = {
          enable = true;
          adapters = {
            dotnet.enable = true;
            golang.enable = true;
            vitest.enable = true;
          };
        };

        none-ls = {
          enable = true;
          sources = {
            formatting = {
              csharpier.enable = true;
              stylua.enable = true;
              nixpkgs_fmt.enable = true;
              gofmt.enable = true;
              goimports.enable = true;
              prettier = {
                enable = true;
                disableTsServerFormatter = true;
              };
            };
            code_actions = {
              gitrebase.enable = true;
              gitsigns.enable = true;
              refactoring.enable = true;
            };
          };
        };

        telescope = {
          enable = true;
          extensions = {
            fzf-native.enable = true;
            file-browser.enable = true;
            ui-select = {
              enable = true;
              settings.theme = "dropdown";
            };
          };
          settings = {
            pickers = {
              colorscheme.enable_preview = true;
              find_files.hidden = true;
              buffers = { theme = "dropdown"; };
              marks = { theme = "dropdown"; };
              git_commits = { theme = "dropdown"; };
              live_grep = { theme = "ivy"; };
              current_buffer_fuzzy_find = { theme = "ivy"; };
              keymaps = { theme = "dropdown"; };
              vim_options = { theme = "dropdown"; };
              commands = { theme = "dropdown"; };
            };

            extensions.ui-select.__raw = ''require('telescope.themes').get_dropdown()'';
          };
        };
        treesitter = {
          enable = true;
          nixvimInjections = true;
          folding = false;
          nixGrammars = true;
          settings = {
            incremental_selection.enable = true;
            ensure_installed = "all";
          };
          grammarPackages = with pkgs.tree-sitter-grammars; [
            tree-sitter-regex
            tree-sitter-norg
            tree-sitter-norg-meta
          ];
        };
        treesitter-context.enable = true;
        treesitter-refactor.enable = true;
        nvim-colorizer = {
          enable = true;
          userDefaultOptions = {
            css = true;
            mode = "foreground";
            tailwind = "both";
          };
        };
        lsp = {
          enable = true;
          inlayHints = true;
          servers = {
            nil_ls.enable = true;
            html.enable = true;
            cssls.enable = true;
            graphql.enable = true;
            eslint = {
              enable = true;
              onAttach.function = ''
                if client and client.name == "eslint" then
                  client.server_capabilities.documentFormattingProvider = true
                elseif client and client.name == "typescript-tools" or client and client.name == "tsserver" then
                  client.server_capabilities.documentFormattingProvider = false
                end
              '';
            };
            lua_ls.enable = true;
            omnisharp = {
              enable = true;
              settings = {
                enableImportCompletion = true;
                enableMsBuildLoadProjectsOnDemand = true;
                enableRoslynAnalyzer = true;
                organizeImportsOnFormat = true;
                sdkIncludePrereleases = true;
                enableEditorConfigSupport = true;
              };
            };
            tailwindcss = {
              enable = true;
              filetypes = [
                "html"
                "css"
                "scss"
                "javascript"
                "typescript"
                "javascriptreact"
                "typescriptreact"
              ];
            };
            gopls.enable = true;
          };
        };
        lsp-format.enable = true;
        lspkind = {
          enable = true;
          cmp.enable = true;
        };
        copilot-chat.enable = true;
        trouble.enable = true;
        typescript-tools = {
          enable = true;
          onAttach = ''
            function(client, bufnr)
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false

              if vim.lsp.inlay_hint then
                vim.lsp.inlay_hint.enable()
              end
            end
          '';
          settings = {
            codeLens = "all";
            completeFunctionCalls = true;
            tsserverFilePreferences = {
              includeCompletionsForModuleExports = true;
              quotePreference = "auto";
              # Inlay Hints
              includeInlayParameterNameHints = "all";
              includeInlayParameterNameHintsWhenArgumentMatchesName = true;
              includeInlayFunctionParameterTypeHints = true;
              includeInlayVariableTypeHints = true;
              includeInlayVariableTypeHintsWhenTypeMatchesName = true;
              includeInlayPropertyDeclarationTypeHints = true;
              includeInlayFunctionLikeReturnTypeHints = true;
              includeInlayEnumMemberValueHints = true;
            };
          };
        };
        todo-comments = {
          enable = true;
          settings.signs = true;
        };

        diffview.enable = true;
        fugitive.enable = true;
        navic = {
          enable = true;
          settings.lsp.autoAttach = true;
        };
        neo-tree.enable = true;

        web-devicons.enable = true;

        yanky = {
          enable = true;
          enableTelescope = true;
        };

        cmp-cmdline.enable = true;
        cmp-dap.enable = true;
        cmp-git.enable = true;
        cmp-nvim-lsp.enable = true;
        cmp-npm.enable = true;
        cmp-nvim-lsp-signature-help.enable = true;
        cmp-treesitter.enable = true;
        luasnip.enable = true;
        cmp_luasnip.enable = true;
        cmp = {
          enable = true;
          settings = {
            snippet.expand = "luasnip";
            mapping = {
              "<C-d>" = "cmp.mapping.scroll_docs(-4)";
              "<C-f>" = "cmp.mapping.scroll_docs(4)";
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-e>" = "cmp.mapping.close()";
              "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<Down>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<Up>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<C-j>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<C-k>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
            };
            sources = [
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              { name = "path"; }
              { name = "buffer"; }
              { name = "nvim_lua"; }
            ];

            window = {
              completion = { border = "single"; };
              documentation = { border = "single"; };
            };
          };
        };
      };
    };
  };
}
