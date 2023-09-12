/* Main user-level configuration */
{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets;
  modules = import ../lib/modules.nix {inherit lib;};
in
{
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
    # Programs to install
    ./packages.nix

    # everything for work
    ./work
  ] ++ (modules.importAllModules ./modules);

  # secureEnv.onePassword = {
  #   enable = true;
  #   sessionVariables = {
  #     GITHUB_TOKEN = {
  #       vault = "Private";
  #       item = "Github Token";
  #       field = "password";
  #     };
  #   };
  # };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = config.user.name;
    homeDirectory = config.user.home;
    wallpaper.file = ./config/wallpaper/drwho-macos.jpeg;

    sessionVariables = {
      EDITOR = "nvim";
    };

    sessionPath = [
    ];

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    _1password

    # fonts
    (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" "FantasqueSansMono" ]; })
  ];

  programs = {
    lazygit.enable = true;
    bat.enable = true;
    exa.enable = true;
    jq.enable = true;
    htop.enable = true;
    bottom.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
    };

    lsd = {
      enable = true;
      enableAliases = true;
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    lf.enable = true;
  };

  services.colima = {
    enable = false;

    config = {
      cpu = 4;
      memory = 4;
    };
  };


  programs.ssh = {
    enable = true;
  };

  tools.aws = {
    enable = true;
  };

  tools.dotnet = {
    enable = true;
  };

  tools.git = {
    enable = true;
    userName = secrets.github.fullName;
    userEmail = secrets.github.userEmail;
    githubUser = secrets.github.userName;
  };

  ### ZSH (TODO: Maybe Mmve to a module?)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    # history.extended = true;

    # this is to workaround zsh syntax highlighting slowness on copy/paste
    # https://github.com/zsh-users/zsh-syntax-highlighting/issues/295#issuecomment-214581607
    initExtra = ''
      zstyle ':bracketed-paste-magic' active-widgets '.self-*'
    '';

    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./config/p10k;
        file = "p10k-classic.zsh";
      }
    ];

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        # Get editor completions based on the config schema
        "$schema" = 'https://starship.rs/config-schema.json'

        command_timeout = 1000

        # Inserts a blank line between shell prompts
        add_newline = true

        # Replace the '❯' symbol in the prompt with '➜'
        [character] # The name of the module we are configuring is 'character'
        success_symbol = '[➜](bold green)' # The 'success_symbol' segment is being set to '➜' with the color 'bold green'
        error_symbol = '[✗](bold red)'

        # Disable the package module, hiding it from the prompt completely
        [package]
        disabled = true

        palette = "catppuccin_macchiato"

        [palettes.catppuccin_macchiato]
        rosewater = "#f4dbd6"
        flamingo = "#f0c6c6"
        pink = "#f5bde6"
        mauve = "#c6a0f6"
        red = "#ed8796"
        maroon = "#ee99a0"
        peach = "#f5a97f"
        yellow = "#eed49f"
        green = "#a6da95"
        teal = "#8bd5ca"
        sky = "#91d7e3"
        sapphire = "#7dc4e4"
        blue = "#8aadf4"
        lavender = "#b7bdf8"
        text = "#cad3f5"
        subtext1 = "#b8c0e0"
        subtext0 = "#a5adcb"
        overlay2 = "#939ab7"
        overlay1 = "#8087a2"
        overlay0 = "#6e738d"
        surface2 = "#5b6078"
        surface1 = "#494d64"
        surface0 = "#363a4f"
        base = "#24273a"
        mantle = "#1e2030"
        crust = "#181926"
      }
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
