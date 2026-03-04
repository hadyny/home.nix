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
  programs.sway.enable = true;

  environment = {
    shells = [ pkgs.zsh ];
    systemPackages = [ pkgs.nixpkgs-fmt ];
    pathsToLink = [ "/share/zsh" ];
  };

  hardware.graphics = {
    enable = true;
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${pkgs.sway}/bin/sway";
      user = "greeter";
    };
    settings.initial_session = {
      command = "env WLR_RENDERER=pixman LIBGL_ALWAYS_SOFTWARE=1 ${pkgs.sway}/bin/sway";
      user = userConfig.name;
    };
  };

  fonts.packages = import ../../modules/shared/fonts.nix { inherit pkgs; };

  users.users.${userConfig.name} = {
    isNormalUser = true;
    home = "/home/${userConfig.name}";
    shell = pkgs.zsh;
    initialPassword = "password123";
    extraGroups = [
      "wheel"
      "docker"
      "video"
      "input"
      "seat"
    ];
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

  fileSystems."/boot" = {
    device = "/dev/vda1";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  fileSystems."/" = {
    device = "/dev/vda2";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/dev/vda3"; } ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "24.11";
}
