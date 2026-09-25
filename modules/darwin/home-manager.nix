# Main user-level configuration
{
  pkgs,
  lib,
  userConfig,
  config,
  inputs,
  ...
}:

let
  shared-programs = import ../shared/home-manager.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
in
{
  # nixpkgs.overlays + allowUnfree live in ../shared (shared with the linux config).
  imports = [ ../shared ];

  home = {
    username = userConfig.name;
    homeDirectory = "/Users/${userConfig.name}";

    sessionVariables = {
      EDITOR = "nvim";
      TERM = "xterm-256color";
      AWS_PROFILE = "dev";
      HOMEBREW_NO_ENV_HINTS = 1;
    };

    packages =
      (pkgs.callPackage ../shared/packages.nix { inherit inputs pkgs; })
      ++ (pkgs.callPackage ./packages.nix { inherit pkgs; });

    sessionPath = [ "/opt/homebrew/bin" ];

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  programs = shared-programs;

  fonts.fontconfig.enable = true;

  services = {
    emacs = {
      enable = true;
      package = pkgs.emacs-dotemacs;
    };
  };

  settings = {
    ghostty = {
      enable = true;
      adjustCellHeight = "35%";
      fontSize = 14;
      fontFamily = "MonaspiceNe Nerd Font Mono";
      fontFamilyItalic = "MonaspiceRn Nerd Font Mono";
      fontFamilyBold = "MonaspiceXe Nerd Font Mono";
      fontFamilyBoldItalic = "MonaspiceKr Nerd Font Mono";
      # calt = texture healing, liga = repeated-character ligatures, ss01-ss10 = coding ligature stylistic sets.
      fontFeatures = [
        "calt"
        "liga"
        "ss01"
        "ss02"
        "ss03"
        "ss04"
        "ss05"
        "ss06"
        "ss07"
        "ss08"
        "ss09"
        "ss10"
      ];
    };
    wallpaper = {
      enable = true;
      file = ../shared/config/wallpaper/nord.jpg;
    };
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
      userName = userConfig.fullName;
      userEmail = userConfig.email;
      inherit (userConfig) githubUser;
      workspaces = userConfig.gitWorkspaces;
    };
    koji.enable = true;
    tuxedo.enable = true;
  };

  # https://nix-community.github.io/home-manager/release-notes.html
  home.stateVersion = "24.11";
}
