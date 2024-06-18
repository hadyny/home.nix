{ pkgs, ... }:

{
  programs = {
    nixvim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      vimdiffAlias = true;
      colorschemes = {
        catppuccin = {
          enable = true;
          settings.flavour = "mocha";
        };
      };

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      opts = {
        number = false;
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
        splitright = true;
        splitbelow = true;
        list = true;
        listchars = { tab = "» "; trail = "·"; nbsp = "␣"; };
        inccommand = "split";
        cursorline = true;
        hlsearch = true;

        # Use 4 spaces instead of tabs
        tabstop = 4;
        shiftwidth = 4;
        softtabstop = 4;
      };
      keymaps = [
        {
          mode = "n";
          key = "<Esc>";
          action = "<cmd>nohlsearch<CR>";
        }
        {
          mode = "n";
          key = "<leader>gl";
          action = "<cmd>LazyGit<CR>";
          options = {
            desc = "[L]azyGit";
          };
        }
        {
          mode = "n";
          key = "<leader>ca";
          action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
          options = {
            desc = "[C]ode [A]ctions";
          };
        }
        {
          mode = "n";
          key = "<leader>co";
          action = "<cmd>AerialToggle!<CR>";
          options = {
            desc = "[C]ode [O]utline";
          };
        }
        {
          mode = "n";
          key = "<leader>cr";
          action = "<cmd>lua vim.lsp.buf.rename()<CR>";
          options = {
            desc = "[C]ode [R]ename";
          };
        }
        {
          mode = "n";
          key = "<leader>ft";
          action = "<cmd>TodoTelescope<CR>";
          options = {
            desc = "[F]ind [T]odos";
          };
        }
      ];

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
        pkgs.vimPlugins.dropbar-nvim
        pkgs.vimPlugins.aerial-nvim
        pkgs.vimPlugins.nvim-treesitter-parsers.lua
        pkgs.vimPlugins.nvim-treesitter-parsers.nix
        pkgs.vimPlugins.nvim-treesitter-parsers.norg
        pkgs.vimPlugins.nvim-treesitter-parsers.typescript
        pkgs.vimPlugins.nvim-treesitter-parsers.tsx
        pkgs.vimPlugins.nvim-treesitter-parsers.c_sharp
      ];

      extraConfigLua = ''
        require("aerial").setup({
          -- optionally use on_attach to set keymaps when aerial has attached to a buffers
          on_attach = function(bufnr)
            -- Jump forwards/backwards with '{' and '}'
            vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
            vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
          end,
        })
        	'';

      plugins = {
        comment.enable = true;
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
          extensions = [ "fzf" ];
        };
        lazygit = {
          enable = true;
          settings = {
            config_file_path = [ ];
            floating_window_scaling_factor = 0.9;
            floating_window_use_plenary = false;
            floating_window_winblend = 0;
            use_custom_config_file_path = false;
            use_neovim_remote = true;
          };
        };
        neorg = {
          enable = true;
          modules = {
            "core.defaults".__empty = null;
            "core.dirman".config = {
              workspaces = {
                notes = "~/notes";
              };
              default_workspace = "notes";
            };
            "core.concealer".__empty = null;
            "core.completion".config.engine = "nvim-cmp";
          };
        };
        nvim-autopairs.enable = true;
        ts-autotag.enable = true;
        none-ls = {
          enable = true;
          sources = {
            formatting = {
              stylua.enable = true;
              nixpkgs_fmt.enable = true;
              gofmt.enable = true;
              goimports.enable = true;
            };
            code_actions = {
              gitrebase.enable = true;
              gitsigns.enable = true;
              refactoring.enable = true;
            };
          };
        };
        which-key = {
          enable = true;
          registrations = {
            "<leader>c" = "[C]ode";
            "<leader>d" = "[D]ocument";
            "<leader>f" = "[F]ind";
            "<leader>g" = "[G]it";
            "<leader>r" = "[R]ename";
            "<leader>u" = "[U]I";
            "<leader>w" = "[W]orkspace";
          };
        };

        telescope = {
          enable = true;
          extensions.fzf-native.enable = true;
          settings = {
            pickers.find_files = {
              hidden = true;
            };
          };
          keymaps = {
            "<leader>ff" = {
              action = "find_files";
              options = {
                desc = "[F]ind [F]ile";
              };
            };
            "<leader>fw" = {
              action = "live_grep";
              options = {
                desc = "[F]ind [W]ords";
              };
            };
            "<leader>fb" = {
              action = "buffers";
              options = {
                desc = "[F]ind [B]uffers";
              };
            };
            "<leader>fh" = {
              action = "help_tags";
              options = {
                desc = "[F]ind [H]elp";
              };
            };
            "<leader>fk" = {
              action = "keymaps";
              options = {
                desc = "[F]ind [K]eymaps";
              };
            };
            "<leader>fr" = {
              action = "oldfiles";
              options = {
                desc = "[F]ind [R]ecent";
              };
            };
            #"<leader>fc" = {
            #  actions = "git_commits";
            #  options = {
            #    desc = "[F]ind Git [Commits]";
            #  };
            #};
            "<leader>s" = {
              action = "current_buffer_fuzzy_find";
              options = {
                desc = "[S]earch in Buffer";
              };
            };
            "<leader>uc" = {
              action = "colorscheme";
              options = {
                desc = "[U]I [C]olorscheme preview";
              };
            };
          };
        };
        treesitter = {
          enable = true;
          nixvimInjections = true;
          folding = false;
          indent = true;
          nixGrammars = true;
          ensureInstalled = "all";
          incrementalSelection.enable = true;
          grammarPackages = with pkgs.tree-sitter-grammars; [
            tree-sitter-norg
            tree-sitter-norg-meta
          ];
        };
        treesitter-refactor = {
          enable = true;
        };
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
          servers = {
            nil-ls.enable = true;
            html.enable = true;
            cssls.enable = true;
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
            lua-ls.enable = true;
            omnisharp = {
              enable = true;
              settings = {
                enableImportCompletion = true;
                enableMsBuildLoadProjectsOnDemand = true;
                enableRoslynAnalyzer = true;
                organizeImportsOnFormat = true;
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

          keymaps = {
            silent = true;
            lspBuf = {
              gD = { action = "declaration"; desc = "Go to Declaration"; };
              gd = { action = "definition"; desc = "Go to Definition"; };
              gI = { action = "implementation"; desc = "Go to Implementation"; };
              gt = { action = "type_definition"; desc = "Go to Type Definition"; };
              gr = { action = "references"; desc = "Go to References"; };
            };

            diagnostic = {
              "[d" = { action = "goto_prev"; };
              "]d" = { action = "goto_next"; };
            };
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
          settings.codeLens = "all";
        };
        todo-comments = {
          enable = true;
          signs = true;
        };

        cmp-nvim-lsp.enable = true;
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
              { name = "neorg"; }
            ];

            window = {
              completion = { border = "rounded"; };
              documentation = { border = "rounded"; };
            };
          };
        };
      };
    };
  };
}
