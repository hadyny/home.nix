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
    # Language servers already come from shared/packages.nix (shared with
    # helix/nvim), so don't restate the closure here.
    tools = [ ];
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
      fg = "#908caa,bg:#191724,hl:#ebbcba";
      "fg+" = "#e0def4,bg+:#26233a,hl+:#ebbcba";
      border = "#403d52,header:#31748f,gutter:#191724";
      spinner = "#f6c177,info:#9ccfd8";
      pointer = "#c4a7e7,marker:#eb6f92,prompt:#908caa";
    };
    defaultOptions = [
      "--style minimal"
    ];
  };

  gh-dash.enable = true;

  obsidian = {
    enable = true;
    cli.enable = true;
    defaultSettings = {
      app = {
        vimMode = true;
        useMarkdownLinks = true;
      };
      themes = [
        {
          enable = true;
          pkg = pkgs.stdenvNoCC.mkDerivation {
            pname = "obsidian-theme-catppuccin";
            version = "2.0.4";
            src = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "obsidian";
              rev = "667e1a893086bc8dec1db32b97ed6b23fdfd5d83";
              hash = "sha256-fbPkZXlk+TTcVwSrt6ljpmvRL+hxB74NIEygl4ICm2U=";
            };
            installPhase = ''
              runHook preInstall
              mkdir -p $out
              cp manifest.json theme.css $out/
              runHook postInstall
            '';
          };
        }
      ];
      cssSnippets = [
        {
          name = "maple-mono-font";
          text = ''
            body {
              --font-text: "Maple Mono NF";
              --font-monospace: "Maple Mono NF";
              --font-interface: "Maple Mono NF";
              font-size: 12px !important;
            }

            .markdown-preview-view,
            .markdown-rendered,
            .markdown-reading-view,
            .markdown-preview-section {
              font-family: "Maple Mono NF" !important;
            }

            .workspace,
            .sidebar-toggle-button,
            .nav-folder-title,
            .nav-file-title,
            .view-header-title,
            .menu,
            .prompt,
            .suggestion-item,
            .setting-item,
            .modal {
              font-family: "Maple Mono NF" !important;
            }

            .cm-editor .cm-content,
            .cm-editor .cm-line {
              font-family: "Maple Mono NF" !important;
            }

            code, pre, .HyperMD-codeblock {
              font-family: "Maple Mono NF" !important;
            }
          '';
        }
      ];
      communityPlugins = [
        {
          pkg = pkgs.fetchzip {
            url = "https://github.com/Vinzent03/obsidian-git/releases/download/2.38.0/obsidian-git-2.38.0.zip";
            hash = "sha256-GaSsWmIeBOI7bT8wt+0Y1HkU47puiqdsQOpps7Ue++8=";
          };
        }
      ];
    };

    vaults.notes = {
      enable = true;
      target = "notes";
    };
  };

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
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'mocha'
          set -g @catppuccin_status_background 'none'
          set -g @catppuccin_window_status_style 'rounded'
          set -g status-right-length 100
          set -g status-right "#{E:@catppuccin_status_application}#{E:@catppuccin_status_directory}#{E:@catppuccin_status_host}"
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

      # Catppuccin dark/light toggle
      # Prefix + D for dark (mocha), Prefix + L for light (latte)
      bind D run-shell "tmux set -g @catppuccin_flavor 'mocha'; tmux source ~/.config/tmux/tmux.conf"
      bind L run-shell "tmux set -g @catppuccin_flavor 'latte'; tmux source ~/.config/tmux/tmux.conf"

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
      set -g pane-border-style "fg=#313244"
      set -g pane-active-border-style "fg=#89b4fa"
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
        tmux new-session -d -s dev -n Claude claude \; \
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
