# Main user-level configuration
{ config, pkgs, lib, ... }:

let
  modules = import ../lib/modules.nix { inherit lib; };
  secrets = import ./secrets;
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    # sometimes it is useful to pin a version of some tool or program.
    # this can be done in "overlays/pinned.nix"
    (import ../overlays/pinned.nix)
  ];

  # Flakes are not standard yet, but widely used, enable them.
  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  imports = [
    # Development packages
    ./development.nix

    # everything for work
    ./work

    ./modules/kitty
    ./modules/neovim
    ./modules/secureEnv/onePassword.nix
    ./modules/services/colima.nix
    ./modules/settings/wallpaper.nix
    ./modules/tools/aws.nix
    ./modules/tools/dotnet.nix
    ./modules/tools/git.nix
  ];
  # ] ++ (modules.importAllModules ./modules);

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = config.user.name;
    homeDirectory = config.user.home;
    wallpaper.file = ./config/wallpaper/wallpaper.jpg;

    sessionVariables = {
      EDITOR = "nvim";
      TERM = "xterm-256color";
    };

    sessionPath = [ "/opt/homebrew/bin" ];

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    _1password-cli
    # _1password-gui

    # fonts
    nerd-fonts.geist-mono
    nerd-fonts.fira-code
    nerd-fonts.victor-mono
    nerd-fonts.commit-mono

    jetbrains.datagrip
    jetbrains.rider
    jetbrains.goland
  ];

  programs = {
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
    htop.enable = true;
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
      '';
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

  };

  services = {
    colima = {
      enable = true;

      config = {
        cpu = 4;
        memory = 8;
      };
    };
  };

  modules = {
    kitty.enable = true;
    neovim.enable = true;
  };

  tools = {
    aws.enable = true;
    dotnet.enable = true;
    git = {
      enable = true;
      userName = secrets.github.fullName;
      userEmail = secrets.github.userEmail;
      githubUser = secrets.github.userName;
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
