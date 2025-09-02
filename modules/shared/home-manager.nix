{ pkgs, ... }: {
  home-manager.enable = true;

  atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
  };

  bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
    config = { theme = "tokyo-night"; };
    themes = {
      tokyo-night = {
        src = pkgs.fetchFromGitHub {
          owner = "enkia";
          repo = "enki-theme";
          rev = "0b629142733a27ba3a6a7d4eac04f81744bc714f";
          sha256 = "sha256-Q+sac7xBdLhjfCjmlvfQwGS6KUzt+2fu+crG4NdNr4w=";
        };
        file = "/scheme/Enki-Tokyo-Night.tmTheme";
      };
    };
  };

  btop = {
    enable = true;
    settings = { theme_background = false; };
  };

  jq.enable = true;

  ssh.enable = true;

  eza = {
    enable = true;
    git = true;
    icons = "auto";
    extraOptions = [ "--group-directories-first" "--header" "--long" ];
  };

  direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.log_filter = "^(loading|using nix|error|deny|allow).*$";
  };

  emacs = {
    enable = true;
    package = pkgs.emacs-unstable;
    extraPackages = epkgs: [ epkgs.vterm ];
  };

  fish = {
    enable = true;
    shellInit = ''
      set -U fish_greeting "🐟"
    '';
    plugins = with pkgs.fishPlugins; [{
      name = "sponge";
      src = sponge.src;
    }];
  };

  fzf.enable = true;

  helix.enable = true;

  lazydocker.enable = true;

  nushell = {
    enable = true;
    shellAliases = {
      man = "batman";
      lg = "lazygit";
    };
    settings = {
      completions = {
        case_sensitive = false;
        quick = true;
        partial = true;
        algorithm = "fuzzy";
        external = {
          enable = true;
          max_results = 100;
        };
      };
    };
    plugins = with pkgs.nushellPlugins; [ query polars highlight ];
  };

  starship = {
    enable = true;
    settings = { command_timeout = 2000; };
  };

  yazi.enable = true;

  zellij = {
    enable = true;
    settings = { ui = { pane_frames = { rounded_corners = true; }; }; };
  };

  zsh.enable = true;

  zoxide.enable = true;
}
