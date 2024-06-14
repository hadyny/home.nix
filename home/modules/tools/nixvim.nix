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
      # TODO: Add LspSaga and commenting
      keymaps = [
        {
          mode = "n";
          key = "<Esc>";
          action = "<cmd>nohlsearch<CR>";
        }
        {
          mode = "n";
          key = "<leader>gl";
          action = "<cmd>[L]azyGit<CR>";
          options = {
            desc = "LazyGit";
          };
        }
        # LspSaga
        {
          mode = "n";
          key = "<leader>ca";
          action = "<cmd>Lspsaga code_action<CR>";
          options = {
            desc = "[C]ode [A]ctions";
          };
        }
        {
          mode = "n";
          key = "<leader>cd";
          action = "<cmd>Lspsaga peek_definition<CR>";
          options = {
            desc = "[C]ode [D]efinition";
          };
        }
        {
          mode = "n";
          key = "<leader>ct";
          action = "<cmd>Lspsaga peek_type_definition<CR>";
          options = {
            desc = "[C]ode [T]ype Definition";
          };
        }
        {
          mode = "n";
          key = "<leader>cd";
          action = "<cmd>Lspsaga peek_definition<CR>";
          options = {
            desc = "[C]ode [D]efinition";
          };
        }
        {
          mode = "n";
          key = "<leader>co";
          action = "<cmd>Lspsaga outline<CR>";
          options = {
            desc = "[C]ode [O]utline";
          };
        }
        {
          mode = "n";
          key = "<leader>cr";
          action = "<cmd>Lspsaga rename<CR>";
          options = {
            desc = "[C]ode [R]ename";
          };
        }
        # Hover
        {
          mode = "n";
          key = "K";
          options.silent = true;
          action = "<cmd>Lspsaga hover_doc<CR>";
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

      plugins = {
        chadtree.enable = true;
        comment.enable = true;
        gitsigns = {
          enable = true;
          settings = {
            current_line_blame = true;
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
        git-worktree = {
          enable = true;
          enableTelescope = true;
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
        nvim-autopairs.enable = true;
        ts-autotag.enable = true;
        none-ls = {
          enable = true;
          enableLspFormat = true;
          sources = {
            formatting = {
              csharpier.enable = true;
              prettier.enable = true;
              rustywind.enable = true;
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
            "<leader>ft" = {
              action = "live_grep";
              options = {
                desc = "[F]ind [T]ext";
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
              # TODO: Is this needed?
              onAttach.function = "if client and client.name == 'eslint' then\n
                                    client.server_capabilities.documentFormattingProvider = true\n
                                  elseif client and client.name == 'typescript-tools' or client and client.name == 'tsserver' then\n
                                    client.server_capabilities.documentFormattingProvider = false\n
                                  end";
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
            # TODO: Not loading in lsp
            tailwindcss = {
              enable = true;
              filetypes = [
                "html"
                "js"
                "ts"
                "jsx"
                "tsx"
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
        lspsaga = {
          enable = true;
          lightbulb.enable = false;
          codeAction = {
            extendGitSigns = true;
            showServerName = true;
          };
          ui.border = "rounded";
        };
        lspkind = {
          enable = true;
          cmp.enable = true;
        };
        copilot-chat.enable = true;
        trouble.enable = true;
        typescript-tools = {
          enable = true;
          settings.codeLens = "all"; # TODO: monitor performance
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
