# Base NixOS system configuration
{
  pkgs,
  lib,
  userConfig,
  ...
}:

{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ (import ../../overlays/pinned.nix) ];
  };

  programs.zsh.enable = true;

  environment = {
    shells = [ pkgs.zsh ];
    systemPackages = [ pkgs.nixpkgs-fmt ];
    pathsToLink = [ "/share/zsh" ];
  };

  fonts.packages = import ../../modules/shared/fonts.nix { inherit pkgs; };

  users.users.${userConfig.name} = {
    isNormalUser = true;
    home = userConfig.home;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" ];
  };

  nix = {
    package = pkgs.nixVersions.latest;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 60d";
    };

    settings = {
      experimental-features = "nix-command flakes";

      substituters = [
        "https://cache.nixos.org/"
        "https://nix-tools.cachix.org"
        "https://nix-community.cachix.org"
        "https://devenv.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-tools.cachix.org-1:ebBEBZLogLxcCvipq2MTvuHlP7ZRdkazFSQsbs0Px1A="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };
  };

  system.stateVersion = "24.11";
}
