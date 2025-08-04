# Main user-level configuration
{ pkgs, lib, userConfig, inputs, config, ... }:

let modules = import ../modules/shared/modules.nix { inherit lib; };

in {
  # Let Home Manager install and manage itself.
  nixpkgs = {
    config.allowUnfree = true;
    overlays =
      [ inputs.emacs-overlay.overlays.default (import ../overlays/pinned.nix) ];
  };

  imports = [
    ../modules/shared/ghostty
    ../modules/shared/neovim
    ../modules/shared/services/colima.nix
    ../modules/shared/settings/wallpaper.nix
    ./work
  ] ++ (modules.importAllModules ../modules/shared/tools);

  home = {
    username = userConfig.name;
    homeDirectory = userConfig.home;
    wallpaper.file = ./config/wallpaper/wallpaper.jpg;

    sessionVariables = {
      EDITOR = "nvim";
      TERM = "xterm-256color";
      AWS_PROFILE = "dev";
    };

    packages =
      pkgs.callPackage ../modules/shared/packages.nix { inherit pkgs; };

    sessionPath = [ "/opt/homebrew/bin" ];

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  fonts.fontconfig.enable = true;

  programs = { }
    // import ../modules/shared/home-manager.nix { inherit pkgs lib config; };

  services = {
    emacs = {
      enable = true;
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
