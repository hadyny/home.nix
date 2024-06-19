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
          settings = {
            flavour = "mocha";
            integrations = {
              cmp = true;
              noice = true;
              notify = true;
              gitsigns = true;
              which_key = true;
              illuminate = {
                enabled = true;
              };
              treesitter = true;
              treesitter_context = true;
              telescope.enabled = true;
              indent_blankline.enabled = true;
              mini.enabled = true;
              native_lsp = {
                enabled = true;
                inlay_hints = {
                  background = true;
                };
                underlines = {
                  errors = [ "underline" ];
                  hints = [ "underline" ];
                  information = [ "underline" ];
                  warnings = [ "underline" ];
                };
              };
            };
          };
        };
      };

      globals = {
        mapleader = " ";
        maplocalleader = " ";
        loaded_netrw = 1;
        loaded_netrwPlugin = 1;
      };

      localOpts = {
        conceallevel = 2;
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
          action = "<cmd>Lspsaga code_action<CR>";
          options = {
            desc = "[C]ode [A]ctions";
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
        {
          mode = "n";
          key = "<leader>ft";
          action = "<cmd>TodoTelescope<CR>";
          options = {
            desc = "[F]ind [T]odos";
          };
        }
        {
          mode = "n";
          key = "<leader>oo";
          action = "<cmd>ObsidianOpen<CR>";
          options = {
            desc = "[O]bsidian [O]pen";
          };
        }
        {
          mode = "n";
          key = "<leader>of";
          action = "<cmd>ObsidianQuickFind<CR>";
          options = {
            desc = "[O]bsidian [F]ind File";
          };
        }
        {
          mode = "n";
          key = "<leader>os";
          action = "<cmd>ObsidianSearch<CR>";
          options = {
            desc = "[O]bsidian [S]earch";
          };
        }
        {
          mode = "n";
          key = "<leader>ct";
          action = "<cmd>Trouble<CR>";
          options = {
            desc = "[C]ode [T]rouble";
          };
        }
        {
          mode = "n";
          key = "<leader>t";
          action = "<cmd>Telescope<CR>";
          options = {
            desc = "[T]elescope";
          };
        }
        {
          mode = "n";
          key = "K";
          action = "<cmd>Lspsaga hover_doc<CR>";
          options = {
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>cd";
          action = "<cmd>Lspsaga peek_definition<CR>";
          options = {
            desc = "[C]ode [D]efinition Peek";
          };
        }
        {
          mode = "n";
          key = "<leader>ct";
          action = "<cmd>Lspsaga peek_type_definition<CR>";
          options = {
            desc = "[C]ode [T]ype Definition Peek";
          };
        }
        {
          mode = "n";
          key = "<leader>cf";
          action = "<cmd>Lspsaga finder<CR>";
          options = {
            desc = "[C]ode [F]inder";
          };
        }
        {
          mode = "n";
          key = "<leader>fn";
          action = "<cmd>Noice telescope<CR>";
          options = {
            desc = "[F]ind [N]otifications";
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
        comment.enable = true;
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
        lspsaga = {
          enable = true;
          beacon.enable = false;
          ui.border = "single";
          symbolInWinbar = {
            enable = true; # Breadcrumbs
          };
          lightbulb = {
            enable = false;
            sign = false;
            virtualText = true;
          };
          outline = {
            autoClose = true;
            autoPreview = true;
            closeAfterJump = true;
            layout = "normal"; # normal or float
            winPosition = "right"; # left or right
            keys = {
              jump = "e";
              quit = "q";
              toggleOrJump = "o";
            };
          };
        };
        noice = {
          enable = true;
          notify = {
            enabled = true;
          };
          messages = {
            enabled = true;
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
            bottom_search = true;
            command_palette = true;
            long_message_to_split = true;
            lsp_doc_border = "single";
          };
          views = {
            popupmenu = {
              enabled = true;
              kind_icons = true;
            };

            format = {
              filter = {
                pattern = [ ":%s*%%s*s:%s*" ":%s*%%s*s!%s*" ":%s*%%s*s/%s*" "%s*s:%s*" ":%s*s!%s*" ":%s*s/%s*" ];
                icon = "";
                lang = "regex";
              };
              replace = {
                pattern = [ ":%s*%%s*s:%w*:%s*" ":%s*%%s*s!%w*!%s*" ":%s*%%s*s/%w*/%s*" "%s*s:%w*:%s*" ":%s*s!%w*!%s*" ":%s*s/%w*/%s*" ];
                icon = "󱞪";
                lang = "regex";
              };
            };
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
            "<leader>f" = "[F]ind";
            "<leader>g" = "[G]it";
            "<leader>r" = "[R]ename";
            "<leader>u" = "[U]I";
            "<leader>o" = "[O]bsidian";
          };
        };

        telescope = {
          enable = true;
          extensions = {
            fzf-native.enable = true;
            file-browser.enable = true;
          };
          settings = {
            pickers = {
              colorscheme.enable_preview = true;
              find_files.hidden = true;
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
            "<leader>fc" = {
              action = "git_commits";
              options = {
                desc = "[F]ind Git [Commits]";
              };
            };
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
            "<leader>e" = {
              action = "file_browser";
              options = {
                desc = "[E]xplorer";
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
            tree-sitter-regex
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
