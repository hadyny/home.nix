{ pkgs, ... }: {
  home-manager.enable = true;

  atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
  };

  bat = {
    enable = true;
    config = { theme = "ansi"; };
  };

  btop = {
    enable = true;
    settings = { theme_background = false; };
  };

  jq.enable = true;

  ssh.enable = true;

  eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
    extraOptions = [ "--group-directories-first" "--header" "--long" ];
  };

  direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  emacs = {
    enable = true;
    package = pkgs.emacs-unstable;
  };

  fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  lazydocker.enable = true;

  yazi.enable = true;

  zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    autosuggestion.enable = true;
    shellAliases = {
      nu = "nvm use";
      dcu = "docker compose up";
      dcd = "docker compose down";
    };
    syntaxHighlighting = {
      enable = true;
      highlighters = [ "main" "brackets" ];
    };
    plugins = [{
      name = "pure";
      src = "${pkgs.pure-prompt}/share/zsh/site-functions";
    }];
    initContent = ''
      autoload -U promptinit; promptinit
      prompt pure
      zstyle :prompt:pure:git:stash show yes
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    '';
  };

  zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
