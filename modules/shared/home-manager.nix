{ pkgs, ... }: {
  home-manager.enable = true;

  atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
  };

  bat.enable = true;

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

  starship.enable = true;

  yazi.enable = true;

  zellij = {
    enable = true;
    settings = {
      theme = "dracula";
      ui = { pane_frames = { rounded_corners = true; }; };
    };
  };

  zsh.enable = true;

  zoxide.enable = true;
}
