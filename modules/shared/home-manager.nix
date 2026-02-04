{ pkgs, inputs, ... }:
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

  btop = {
    enable = true;
    settings = {
      theme_background = false;
    };
  };

  emacs = {
    enable = !pkgs.stdenv.isDarwin;
    package = pkgs.emacs-unstable;
  };

  jq.enable = true;

  lazydocker.enable = true;

  rclone.enable = true;

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

  fzf.enable = true;

  gh-dash.enable = true;

  mcfly = {
    enable = true;
    fzf.enable = true;
    keyScheme = "vim";
  };

  opencode.enable = true;

  ripgrep.enable = true;

  starship = {
    enable = true;
    settings = {
      command_timeout = 2000;
    };
  };

  taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
  };

  wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile ./config/wezterm/wezterm.lua;
  };

  yazi = {
    enable = true;
    extraPackages = with pkgs; [
      rich-cli
    ];
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

  yt-dlp.enable = true;

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
                  name = "Project";
                  focus = true;
                };
                _children = [
                  {
                    pane = {
                      command = "nvimIde";
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
                      command = "yazi";
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
      theme = "catppuccin-mocha";
    };
  };

  zk = {
    enable = true;
    settings = {
      notebook = {
        dir = "~/notes";
      };
      note = {
        language = "en";
        default-title = "Untitled";
        filename = "{{id}}-{{slug title}}";
        extension = "md";
        id-charset = "alphanum";
        id-length = 4;
        id-case = "lower";
      };
      extra = {
        author = "Hadyn";
      };
      tool = {
        fzf-preview = "bat -p --color always {-1}";
        editor = "nvimIde";
      };
    };
  };

  zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];
    syntaxHighlighting.enable = true;
  };

  zed-editor = {
    enable = true;
    extensions = [
      "HTML"
      "catppuccin"
      "lua"
      "csharp"
      "nix"
      "graphql"
      "elisp"
    ];
    extraPackages = [
      pkgs.nil
      pkgs.nixfmt
      pkgs.csharpier
      inputs.csharp-language-server.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };

  zoxide.enable = true;
}
