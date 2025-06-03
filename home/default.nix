# Main user-level configuration
{ config, pkgs, lib, userConfig, ... }:

let
  modules = import ../lib/modules.nix { inherit lib; };
  nvm = builtins.fetchGit {
    url = "https://github.com/nvm-sh/nvm";
    rev = "977563e97ddc66facf3a8e31c6cff01d236f09bd";
  };

in {
  # Let Home Manager install and manage itself.
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ (import ../overlays/pinned.nix) ];
  };

  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  imports = [ ../modules/shared/ghostty ../modules/shared/neovim ./work ]
    ++ (modules.importAllModules ./modules);

  home = {
    username = userConfig.name;
    homeDirectory = userConfig.home;
    wallpaper.file = ./config/wallpaper/wallpaper.jpg;

    sessionVariables = {
      EDITOR = "nvim";
      TERM = "xterm-256color";
      AWS_PROFILE = "dev";
    };

    file.".nvm" = {
      source = nvm;
      recursive = true;
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

  programs = { } // import ../modules/shared/home-manager.nix { inherit pkgs; };

  services = {
    colima = {
      enable = true;

      config = {
        cpu = 4;
        memory = 8;
      };
    };
  };

  modules = { neovim.enable = true; };

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
