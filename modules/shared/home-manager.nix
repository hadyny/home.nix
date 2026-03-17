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

  nushell = {
    enable = true;
    configFile = {
      text = ''
        # tmux dev session mirroring the zellij dev layout
        def tdev [] {
          tmux new-session -d -s dev -n Claude claude
          tmux new-window -t dev -n Project nvim
          tmux new-window -t dev -n Git lazygit
          tmux new-window -t dev -n Files yazi
          tmux new-window -t dev -n Shell nu
          tmux select-window -t dev:Project
          tmux attach-session -t dev
        }

        $env.config.buffer_editor = "nvim"
        $env.config.hooks.env_change.PWD = [
          {|before, after|
            if ([".node-version" ".nvmrc"] | any {|f| ($after | path join $f | path exists)}) {
              fnm use
            }
          }
          {|before, after|
            if not ($after | path join "package.json" | path exists) {
              ^direnv export json | from json | default {} | load-env
            }
          }
        ]
      '';
    };
    envFile = {
      text = ''
        fnm env --json | from json | load-env
        $env.PATH = ($env.PATH | prepend $"($env.FNM_MULTISHELL_PATH)/bin")
      '';
    };
    settings = {
      completions.external = {
        enable = true;
        max_results = 200;
      };
    };
  };

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
    enableNushellIntegration = false;
    enableZshIntegration = false;
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
      require('git'):setup()
    '';
    plugins = {
      "git" = pkgs.yaziPlugins.git;
      "rich-preview" = pkgs.yaziPlugins.rich-preview;
    };
    settings = {
      plugin = {
        prepend_previewers = [
          {
            url = "*.csv";
            run = "rich-preview";
          }
          {
            url = "*.md";
            run = "rich-preview";
          }
          {
            url = "*.rst";
            run = "rich-preview";
          }
          {
            url = "*.ipynb";
            run = "rich-preview";
          }
          {
            url = "*.json";
            run = "rich-preview";
          }
        ];
      };
    };
  };

  starship = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = false;
    settings = builtins.fromTOML (
      builtins.readFile "${pkgs.starship}/share/starship/presets/pure-preset.toml"
    );
  };

  tmux = {
    enable = true;
    prefix = "C-a";
    terminal = "tmux-256color";
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      {
        plugin = rose-pine;
        extraConfig = ''
          set -g @rose_pine_variant 'main'
          set -g @rose_pine_host 'on'
          set -g @rose_pine_directory 'on'
          set -g @rose_pine_show_current_program 'on'
          set -g @rose_pine_show_pane_directory 'on'
          set -g @rose_pine_bar_bg_disable 'on'
          set -g @rose_pine_bar_bg_disabled_color_option 'default'
        '';
      }
      {
        plugin = tmux-which-key;
        extraConfig = ''
          set -g @tmux-which-key-xdg-enable 1
        '';
      }
    ];
    extraConfig = ''
      # True colour support
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Rose Pine dark/light toggle
      # Prefix + D for dark (main), Prefix + L for light (dawn)
      bind D run-shell "tmux set -g @rose_pine_variant 'main'; tmux source ~/.config/tmux/tmux.conf"
      bind L run-shell "tmux set -g @rose_pine_variant 'dawn'; tmux source ~/.config/tmux/tmux.conf"

      # Pane splitting (keep cwd)
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Pane navigation (vim-style)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Pane resizing
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Window renumbering
      set -g renumber-windows on

      # Subtle pane borders
      set -g pane-border-lines simple
      set -g pane-border-style "fg=#26233a"
      set -g pane-active-border-style "fg=#31748f"
    '';
  };

  zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    autosuggestion.enable = true;
    initContent = ''
      autoload -U promptinit; promptinit
      prompt pure
      eval "$(fnm env --use-on-cd --shell zsh)"

      # direnv hook — skip activation in Node projects
      _direnv_hook() {
        if [[ ! -f "$PWD/package.json" ]]; then
          eval "$(direnv export zsh)"
        fi
      }
      typeset -ag precmd_functions
      if (( ! ''${precmd_functions[(I)_direnv_hook]} )); then
        precmd_functions=(_direnv_hook $precmd_functions)
      fi
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
    shellAliases = {
      # tmux dev session mirroring the zellij dev layout
      tdev = ''
        tmux new-session -d -s dev -n Claude claude \; \
          new-window -t dev -n Project nvim \; \
          new-window -t dev -n Git lazygit \; \
          new-window -t dev -n Files yazi \; \
          new-window -t dev -n Shell nu \; \
          select-window -t dev:Project \; \
          attach-session -t dev
      '';
    };
    syntaxHighlighting.enable = true;
  };

  zoxide.enable = true;
}
