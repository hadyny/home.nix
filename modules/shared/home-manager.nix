{ pkgs, ... }:
{
  home-manager.enable = true;

  atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
  };

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

  jq.enable = true;

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

  fish = {
    enable = true;
    shellInit = ''
      string match -q "$TERM_PROGRAM" "vscode"
      and . (code --locate-shell-integration-path fish)
      set -U fish_greeting "🐟"
    '';
    plugins = with pkgs.fishPlugins; [
      {
        name = "sponge";
        src = sponge.src;
      }
    ];
  };

  fzf.enable = true;

  helix.enable = true;

  lazydocker.enable = true;

  nushell.enable = true;

  starship = {
    enable = true;
    settings = {
      command_timeout = 2000;
    };
  };

  yazi.enable = true;

  zellij = {
    enable = true;
    settings = {
      ui = {
        pane_frames = {
          rounded_corners = true;
        };
      };
    };
  };

  zsh.enable = true;

  zoxide.enable = true;
}
