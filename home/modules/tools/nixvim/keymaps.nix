{
  programs = {
    nixvim = {
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
          action = "<cmd>Navbuddy<CR>";
          options = {
            desc = "[C]ode [O]utline";
          };
        }
        {
          mode = "n";
          key = "<leader>rs";
          action = "<cmd>lua vim.lsp.buf.rename()<CR>";
          options = {
            desc = "[R]ename [S]ymbol";
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
          key = "<leader>fn";
          action = "<cmd>Noice telescope<CR>";
          options = {
            desc = "[F]ind [N]otifications";
          };
        }
      ];
      plugins = {
        which-key = {
          enable = true;
          settings.spec = [
            { __unkeyed = "<leader>c"; desc = "[C]ode"; }
            { __unkeyed = "<leader>f"; desc = "[F]ind"; }
            { __unkeyed = "<leader>g"; desc = "[G]it"; }
            { __unkeyed = "<leader>r"; desc = "[R]ename"; }
            { __unkeyed = "<leader>u"; desc = "[U]I"; }
            { __unkeyed = "<leader>o"; desc = "[O]bsidian"; }
          ];
        };

        lsp = {
          keymaps = {
            silent = true;
            lspBuf = {
              gD = { action = "declaration"; desc = "Go to Declaration"; };
              gd = { action = "definition"; desc = "Go to Definition"; };
              gI = { action = "implementation"; desc = "Go to Implementation"; };
              gt = { action = "type_definition"; desc = "Go to Type Definition"; };
            };

            diagnostic = {
              "[d" = { action = "goto_prev"; };
              "]d" = { action = "goto_next"; };
            };
          };
        };

        telescope = {
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
            "<leader>/" = {
              action = "current_buffer_fuzzy_find";
              options = {
                desc = "Search in Buffer";
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
            "<leader>cr" = {
              action = "lsp_references";
              options = {
                desc = "[C]ode [R]eferences";
              };
            };
            "<leader>ci" = {
              action = "lsp_implementations";
              options = {
                desc = "[C]ode [I]mplementations";
              };
            };
            "<leader>cd" = {
              action = "lsp_definitions";
              options = {
                desc = "[C]ode [D]efinition";
              };
            };
          };
        };
      };
    };
  };
}
