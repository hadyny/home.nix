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
      color_theme = "catppuccin_mocha";
    };
    themes = {
      catppuccin_mocha = ''
        theme[main_bg]="#1e1e2e"
        theme[main_fg]="#cdd6f4"
        theme[title]="#cdd6f4"
        theme[hi_fg]="#89b4fa"
        theme[selected_bg]="#45475a"
        theme[selected_fg]="#89b4fa"
        theme[inactive_fg]="#7f849c"
        theme[graph_text]="#f5e0dc"
        theme[meter_bg]="#45475a"
        theme[proc_misc]="#f5e0dc"
        theme[cpu_box]="#cba6f7"
        theme[mem_box]="#a6e3a1"
        theme[net_box]="#eba0ac"
        theme[proc_box]="#89b4fa"
        theme[div_line]="#6c7086"
        theme[temp_start]="#a6e3a1"
        theme[temp_mid]="#f9e2af"
        theme[temp_end]="#f38ba8"
        theme[cpu_start]="#94e2d5"
        theme[cpu_mid]="#74c7ec"
        theme[cpu_end]="#b4befe"
        theme[free_start]="#cba6f7"
        theme[free_mid]="#b4befe"
        theme[free_end]="#89b4fa"
        theme[cached_start]="#74c7ec"
        theme[cached_mid]="#89b4fa"
        theme[cached_end]="#b4befe"
        theme[available_start]="#fab387"
        theme[available_mid]="#eba0ac"
        theme[available_end]="#f38ba8"
        theme[used_start]="#a6e3a1"
        theme[used_mid]="#94e2d5"
        theme[used_end]="#89dceb"
        theme[download_start]="#fab387"
        theme[download_mid]="#eba0ac"
        theme[download_end]="#f38ba8"
        theme[upload_start]="#a6e3a1"
        theme[upload_mid]="#94e2d5"
        theme[upload_end]="#89dceb"
        theme[process_start]="#74c7ec"
        theme[process_mid]="#b4befe"
        theme[process_end]="#cba6f7"
      '';
      catppuccin_latte = ''
        theme[main_bg]="#eff1f5"
        theme[main_fg]="#4c4f69"
        theme[title]="#4c4f69"
        theme[hi_fg]="#1e66f5"
        theme[selected_bg]="#bcc0cc"
        theme[selected_fg]="#1e66f5"
        theme[inactive_fg]="#8c8fa1"
        theme[graph_text]="#dc8a78"
        theme[meter_bg]="#bcc0cc"
        theme[proc_misc]="#dc8a78"
        theme[cpu_box]="#8839ef"
        theme[mem_box]="#40a02b"
        theme[net_box]="#e64553"
        theme[proc_box]="#1e66f5"
        theme[div_line]="#9ca0b0"
        theme[temp_start]="#40a02b"
        theme[temp_mid]="#df8e1d"
        theme[temp_end]="#d20f39"
        theme[cpu_start]="#179299"
        theme[cpu_mid]="#209fb5"
        theme[cpu_end]="#7287fd"
        theme[free_start]="#8839ef"
        theme[free_mid]="#7287fd"
        theme[free_end]="#1e66f5"
        theme[cached_start]="#209fb5"
        theme[cached_mid]="#1e66f5"
        theme[cached_end]="#7287fd"
        theme[available_start]="#fe640b"
        theme[available_mid]="#e64553"
        theme[available_end]="#d20f39"
        theme[used_start]="#40a02b"
        theme[used_mid]="#179299"
        theme[used_end]="#04a5e5"
        theme[download_start]="#fe640b"
        theme[download_mid]="#e64553"
        theme[download_end]="#d20f39"
        theme[upload_start]="#40a02b"
        theme[upload_mid]="#179299"
        theme[upload_end]="#04a5e5"
        theme[process_start]="#209fb5"
        theme[process_mid]="#7287fd"
        theme[process_end]="#8839ef"
      '';
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
      fg = "#cdd6f4,bg:#1e1e2e,hl:#f38ba8";
      "fg+" = "#cdd6f4,bg+:#313244,hl+:#f38ba8";
      border = "#6c7086,header:#f38ba8,gutter:#1e1e2e,label:#cdd6f4";
      spinner = "#f5e0dc,info:#cba6f7";
      pointer = "#f5e0dc,marker:#b4befe,prompt:#cba6f7";
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
