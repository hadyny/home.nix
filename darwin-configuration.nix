# Global MacOS configuration using nix-darwin (https://github.com/LnL7/nix-darwin).
# Sets up minimal required system-level configuration, such as
# Darwin-specific modules, certificates, etc.
#
# Also enables Home Manager.
# Home Manager is used for the rest of user-level configuration.
# Home Manager configuratio is located in ./home folder.
{ config, pkgs, lib, ... }:
let modules = import ./lib/modules.nix { inherit lib; };
in {
  documentation.enable = false;
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = config.user.name;

  nixpkgs.overlays = [
    # sometimes it is useful to pin a version of some tool or program.
    # this can be done in "overlays/pinned.nix"
    (import ./overlays/pinned.nix)
  ];

  imports = [ ./certificates.nix ./users.nix ]
    ++ (modules.importAllModules ./darwin);

  programs.zsh.enable = true;

  environment = {
    shells = [ pkgs.zsh ];
    systemPackages = [
      pkgs.nixpkgs-fmt
      # (import (fetchTarball https://github.com/cachix/devenv/archive/v0.5.tar.gz)).default
    ];
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  ids.gids.nixbld = 350;

  # set up current user
  users.users.${config.user.name} = {
    name = config.user.name;
    home = config.user.home;
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.latest;

    settings = {
      max-jobs = 12;

      # $ sysctl -n hw.ncpu
      cores = 12;
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-tools.cachix.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-tools.cachix.org-1:ebBEBZLogLxcCvipq2MTvuHlP7ZRdkazFSQsbs0Px1A="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
