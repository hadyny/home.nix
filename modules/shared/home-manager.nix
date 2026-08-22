{ pkgs, config, ... }:
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

  # Emacs is provided by the dotemacs module below (nixpkgs emacs + emacs-plus
  # system-appearance patch on Darwin), so the built-in programs.emacs is off.
  emacs.enable = false;

  dotemacs = {
    enable = true;
    # Live, writable checkout: ~/.emacs.d out-of-store symlink so straight.el
    # can write to ~/.emacs.d/straight and config.org edits need no rebuild.
    configPath = "${config.home.homeDirectory}/src/dotemacs.d";
    # Cross-platform Emacs from the dotemacs flake: patched on Darwin plus every
    # config package on load-path (Nix-managed, not straight.el). Provided by the
    # dotemacs overlay added in each platform's nixpkgs.overlays.
    package = pkgs.emacs-dotemacs;
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
    settings = {
      "*" = {
        ForwardAgent = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        Compression = false;
        AddKeysToAgent = "no";
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
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
    enableZshIntegration = false;
    nix-direnv.enable = true;
    config.global.log_filter = "^(loading|using nix|error|deny|allow).*$";
  };

  fzf = {
    enable = true;
    # mcfly owns Ctrl-R (sourced after fzf); cede fzf's history widget to it.
    # Per-shell form avoids the fzf >=0.66.0 guard on the global option.
    historyWidget.zsh.command = "";
    colors = {
      fg = "#c0caf5,bg:#1a1b26,hl:#f7768e";
      "fg+" = "#c0caf5,bg+:#292e42,hl+:#f7768e";
      border = "#3b4261,header:#7aa2f7,gutter:#1a1b26";
      spinner = "#9ece6a,info:#7dcfff";
      pointer = "#7aa2f7,marker:#9ece6a,prompt:#a9b1d6";
    };
    defaultOptions = [
      "--style minimal"
    ];
  };

  gh-dash.enable = true;

  opencode.enable = true;

  ripgrep.enable = true;

  # Note-taking. fzf is already enabled above, so zk's interactive mode
  # (`zk edit -i` / `zk list -i`) shells out to fzf automatically; the
  # settings below give it a bat-powered preview and open notes in nvim.
  zk = {
    enable = true;
    settings = {
      note = {
        language = "en";
        default-title = "Untitled";
        # Slug the title so new notes read like `guitar-lessons.md` and are
        # safe against `:` `/` `?` in titles. Random IDs are still used as a
        # fallback via id-* below when a note has no title.
        filename = "{{slug title}}";
        extension = "md";
        id-charset = "alphanum";
        id-length = 4;
        id-case = "lower";
        # Keep zk's index clean: these dirs hold non-notes (templates,
        # deleted notes, attachments). Globs are relative to the notebook root.
        exclude = [
          "templates"
          ".trash"
          "assets"
        ];
      };
      # `[[wiki-links]]` instead of Markdown links, and `#hashtag` indexing.
      # Kept here (not in the notebook's .zk/config.toml) so the whole zk
      # config is declarative and survives re-init of the notebook.
      format.markdown = {
        link-format = "wiki";
        hashtags = true;
      };
      tool = {
        editor = "nvim";
        pager = "less -FIRX";
        fzf-preview = "bat -p --color always {-1}";
      };
      # Treat links to non-existent notes as errors in LSP-aware editors.
      lsp.diagnostics.dead-link = "error";
    };
  };

  yazi = {
    enable = true;
    extraPackages = with pkgs; [
      rich-cli
    ];
    shellWrapperName = "y";
    initLua = ''
      require('git'):setup()
      require('starship'):setup()
    '';
    plugins = {
      "git" = pkgs.yaziPlugins.git;
      "rich-preview" = pkgs.yaziPlugins.rich-preview;
      "starship" = pkgs.yaziPlugins.starship;
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
        plugin = tokyo-night-tmux;
        # This plugin builds the right side of the status line from widgets, so
        # a `status-right` of its own is not necessary.
        extraConfig = ''
          set -g @tokyo-night-tmux_theme night
          set -g @tokyo-night-tmux_transparent 1
          set -g @tokyo-night-tmux_show_path 1
          set -g @tokyo-night-tmux_show_hostname 1
          set -g status-right-length 100
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

      # Tokyo Night dark/light toggle
      # Prefix + D for dark (night), Prefix + L for light (day)
      bind D run-shell "tmux set -g @tokyo-night-tmux_theme night; tmux source ~/.config/tmux/tmux.conf"
      bind L run-shell "tmux set -g @tokyo-night-tmux_theme day; tmux source ~/.config/tmux/tmux.conf"

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
      set -g pane-border-style "fg=#3b4261"
      set -g pane-active-border-style "fg=#7aa2f7"
    '';
  };

  zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    autosuggestion.enable = true;
    initContent = ''
      # Source local secrets if they exist
      [[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

      autoload -U promptinit; promptinit
      prompt pure

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

      eval "$(fnm env --use-on-cd --shell zsh)"
    '';

    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
      {
        name = pkgs.zsh-nix-shell.pname;
        inherit (pkgs.zsh-nix-shell) src;
      }
      {
        name = pkgs.pure-prompt.pname;
        inherit (pkgs.pure-prompt) src;
      }
    ];
    shellAliases = {
      # tmux dev session mirroring the zellij dev layout
      tdev = ''
        tmux new-session -d -s dev -n Todos dooit \; \
          new-window -t dev -n Claude claude \; \
          new-window -t dev -n Project nvim \; \
          new-window -t dev -n Git lazygit \; \
          new-window -t dev -n Files yazi \; \
          new-window -t dev -n Shell zsh \; \
          select-window -t dev:Project \; \
          attach-session -t dev
      '';
    };
    syntaxHighlighting.enable = true;
  };

  z-lua = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "enhanced"
      "once"
      "fzf"
    ];
  };
}
