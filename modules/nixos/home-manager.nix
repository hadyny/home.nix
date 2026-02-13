# NixOS home-manager configuration using only shared modules
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

    sessionVariables = {
      EDITOR = "nvim";
      TERM = "xterm-256color";
    };

    packages = pkgs.callPackage ../shared/packages.nix { inherit inputs pkgs; };
  };

  programs = shared-programs // { };

  fonts.fontconfig.enable = true;

  services = {
    emacs = {
      enable = true;
      package = pkgs.emacs-unstable;
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

  home.stateVersion = "24.11";
}
