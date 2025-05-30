{ config, pkgs, lib, ... }:
let modules = import ./lib/modules.nix { inherit lib; };
in {
  documentation.enable = false;
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = config.user.name;

  nixpkgs.overlays = [ (import ./overlays/pinned.nix) ];

  imports = [ ./certificates.nix ./users.nix ]
    ++ (modules.importAllModules ./darwin);

  programs.zsh.enable = true;

  environment = {
    shells = [ pkgs.zsh ];
    systemPackages = [ pkgs.nixpkgs-fmt ];
  };

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
