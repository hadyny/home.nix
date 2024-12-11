/* Main user-level configuration */
{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets;
  modules = import ../lib/modules.nix { inherit lib; };

  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    ref = "main";
  });
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
    # nixvim
    nixvim.homeManagerModules.nixvim
    # Development packages
    ./development.nix

    # everything for work
    ./work
  ] ++ (modules.importAllModules ./modules);

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = config.user.name;
    homeDirectory = config.user.home;
    wallpaper.file = ./config/wallpaper/wallpaper.jpg;

    sessionVariables = { };

    sessionPath = [
    ];

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    _1password-cli

    # fonts
    nerd-fonts.geist-mono
    nerd-fonts.fira-code
    nerd-fonts.victor-mono
  ];

  programs = {
    bat = {
      enable = true;
      config = {
        theme = "catppuccin";
      };
      themes = {
        catppuccin = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "main";
            sha256 = "sha256-Q5B4NDrfCIK3UAMs94vdXnR42k4AXCqZz6sRn8bzmf4=";
          };
          file = "themes/Catppuccin Mocha.tmTheme";
        };
      };
    };

    emacs = {
      enable = true;
      package = pkgs.emacs-unstable;
    };

    jq.enable = true;
    htop.enable = true;
    bottom.enable = true;
    ssh.enable = true;

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
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      colors = {
        "bg+" = "#313244";
        "bg" = "#1e1e2e";
        "spinner" = "#f5e0dc";
        "hl" = "#f38ba8";
        "fg" = "#cdd6f4";
        "header" = "#f38ba8";
        "info" = "#cba6f7";
        "pointer" = "#f5e0dc";
        "marker" = "#f5e0dc";
        "fg+" = "#cdd6f4";
        "prompt" = "#cba6f7";
        "hl+" = "#f38ba8";
      };
    };

    starship =
      let
        flavour = "mocha";
      in
      {
        enable = true;
        enableZshIntegration = true;
        settings = {
          scan_timeout = 100;
          format = "$all";
          palette = "catppuccin_${flavour}";
        } // builtins.fromTOML (builtins.readFile
          (pkgs.fetchFromGitHub
            {
              owner = "catppuccin";
              repo = "starship";
              rev = "5629d2356f62a9f2f8efad3ff37476c19969bd4f";
              sha256 = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
            } + /palettes/${flavour}.toml));
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
