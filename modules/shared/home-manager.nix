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
    config = {
      theme = "tokyo-night";
    };
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

  mcfly = {
    enable = true;
    fzf.enable = true;
    keyScheme = "vim";
  };

  starship = {
    enable = true;
    settings = {
      command_timeout = 2000;
    };
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

  zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
    syntaxHighlighting.enable = true;
  };

  zoxide.enable = true;
}
