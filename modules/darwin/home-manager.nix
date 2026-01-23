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
  shared-programs = import ../shared/home-manager.nix { inherit config pkgs lib; };
in
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.emacs-overlay.overlays.default
      (import ../../overlays/pinned.nix)
    ];
  };

  imports = [
    ../shared/ghostty
    ../shared/neovim
    ../shared/helix
    ../shared/services/colima.nix
    ../shared/settings/wallpaper.nix

    ../shared/tools/aws.nix
    ../shared/tools/docker.nix
    ../shared/tools/dotnet.nix
    ../shared/tools/git.nix
  ];

  home = {
    username = userConfig.name;
    homeDirectory = userConfig.home;
    wallpaper.file = ../shared/config/wallpaper/nord.jpg;

    sessionVariables = {
      EDITOR = "nvim";
      TERM = "xterm-256color";
      AWS_PROFILE = "dev";
      HOMEBREW_NO_ENV_HINTS = 1;
    };

    packages = pkgs.callPackage ../shared/packages.nix { inherit inputs pkgs; };

    sessionPath = [ "/opt/homebrew/bin" ];

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  programs = shared-programs // { };

  fonts.fontconfig.enable = true;

  services = {
    emacs = {
      enable = !pkgs.stdenv.isDarwin;
      package = pkgs.emacs-unstable;
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
      githubUser = userConfig.githubUser;
      workspaces = userConfig.gitWorkspaces;
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
