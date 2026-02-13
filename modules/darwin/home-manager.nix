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
  shared-programs = import ../shared/home-manager.nix { inherit inputs config pkgs lib; };
in
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.emacs-overlay.overlays.default
      (import ../../overlays/pinned.nix)
    ];
  };

  imports = [ ../shared ];

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

  # https://nix-community.github.io/home-manager/release-notes.html
  home.stateVersion = "24.11";
}
