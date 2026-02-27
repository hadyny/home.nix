{ pkgs, ... }:
{
  bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batman
      batgrep
      batwatch
    ];
  };

  broot = {
    enable = true;
    enableZshIntegration = true;
  };

  btop = {
    enable = true;
    settings = {
      theme_background = false;
    };
  };

  emacs = {
    enable = !pkgs.stdenv.isDarwin;
    package = pkgs.emacs-unstable;
    extraPackages = epkgs: [ epkgs.vterm ];
  };

  jq.enable = true;

  lazydocker.enable = true;

  mcfly = {
    enable = true;
    fzf.enable = true;
  };

  ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        forwardAgent = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        compression = false;
        addKeysToAgent = "no";
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
    };
  };

  eza = {
    enable = true;
    git = true;
    icons = "auto";
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--long"
    ];
  };

  direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.log_filter = "^(loading|using nix|error|deny|allow).*$";
  };

  fzf = {
    enable = true;
    colors = {
      fg = "#908caa,bg:#191724,hl:#ebbcba";
      "fg+" = "#e0def4,bg+:#26233a,hl+:#ebbcba";
      border = "#403d52,header:#31748f,gutter:#191724";
      spinner = "#f6c177,info:#9ccfd8";
      pointer = "#c4a7e7,marker:#eb6f92,prompt:#908caa";
    };
  };

  gh-dash.enable = true;

  opencode.enable = true;

  ripgrep.enable = true;

  yazi = {
    enable = true;
    extraPackages = with pkgs; [
      rich-cli
    ];
    shellWrapperName = "y";
    initLua = ''
      require('starship'):setup()
      require('git'):setup()
      if not os.getenv 'NVIM' then
        require('full-border'):setup()
      end
    '';
    plugins = {
      "full-border" = pkgs.yaziPlugins.full-border;
      "starship" = pkgs.yaziPlugins.starship;
      "git" = pkgs.yaziPlugins.git;
    };
  };

  zellij = {
    enable = true;
    layouts = {
      dev = {
        layout = {
          _children = [
            {
              default_tab_template = {
                _children = [
                  {
                    pane = {
                      size = 1;
                      borderless = true;
                      plugin = {
                        location = "zellij:tab-bar";
                      };
                    };
                  }
                  { "children" = { }; }
                  {
                    pane = {
                      size = 2;
                      borderless = true;
                      plugin = {
                        location = "zellij:status-bar";
                      };
                    };
                  }
                ];
              };
            }
            {
              tab = {
                _props = {
                  name = "Claude";
                };
                _children = [
                  {
                    pane = {
                      command = "claude";
                    };
                  }
                ];
              };
            }

            {
              tab = {
                _props = {
                  name = "Project";
                  focus = true;
                };
                _children = [
                  {
                    pane = {
                      command = "nvim";
                    };
                  }
                ];
              };
            }
            {
              tab = {
                _props = {
                  name = "Git";
                };
                _children = [
                  {
                    pane = {
                      command = "lazygit";
                    };
                  }
                ];
              };
            }
            {
              tab = {
                _props = {
                  name = "Files";
                };
                _children = [
                  {
                    pane = {
                      command = "broot";
                      args = [ "-sdpg" ];
                    };
                  }
                ];
              };
            }
            {
              tab = {
                _props = {
                  name = "Shell";
                };
                _children = [
                  {
                    pane = {
                      command = "zsh";
                    };
                  }
                ];
              };
            }
          ];
        };
      };
    };
    extraConfig = ''
      keybinds {
          normal {
              unbind "Ctrl o"
              bind "Ctrl e" { SwitchToMode "Session"; }
          }
      }
    '';
    settings = {
      show_startup_tips = false;
      pane_frames = false;
    };
  };

  zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    autosuggestion.enable = true;
    initExtra = ''
      autoload -U promptinit; promptinit
      prompt pure
    '';

    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
      {
        name = pkgs.zsh-nix-shell.pname;
        src = pkgs.zsh-nix-shell.src;
      }
      {
        name = pkgs.pure-prompt.pname;
        src = pkgs.pure-prompt.src;
      }
    ];
    syntaxHighlighting.enable = true;
  };

  zoxide.enable = true;
}
