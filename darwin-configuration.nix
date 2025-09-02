{ pkgs, lib, userConfig, ... }:
let modules = import ./modules/shared/modules.nix { inherit lib; };
in {
  documentation.enable = false;

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
    overlays = [ (import ./overlays/pinned.nix) ];
  };

  imports = [ ./certificates.nix ]
    ++ (modules.importAllModules ./modules/darwin);

  programs.zsh.enable = true;

  environment = {
    shells = [ pkgs.zsh ];
    systemPackages = [ pkgs.nixpkgs-fmt ];
  };
  ids.gids.nixbld = 350;

  fonts.packages = with pkgs; [
    maple-mono.NF-unhinted
    nerd-fonts.fira-code
    nerd-fonts.commit-mono
  ];

  # set up current user
  users.users.${userConfig.name} = {
    name = userConfig.name;
    home = userConfig.home;
  };

  nix = {
    package = pkgs.nixVersions.latest;

    gc = {
      automatic = true;
      options = "--delete-older-than 60d";
    };

    settings = {
      max-jobs = 12;
      experimental-features = "nix-command flakes";

      cores = 12;
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
    registry = {
      ep = {
        from = {
          type = "indirect";
          id = "ep";
        };
        to = {
          type = "git";
          url = "ssh://git@github.com/educationperfect/ep-nix";
        };
      };
    };

  };

  system = {
    primaryUser = userConfig.name;
    stateVersion = 4;
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.trackpad.trackpadCornerClickBehavior" = 1;
        "com.apple.trackpad.enableSecondaryClick" = true;
        "com.apple.swipescrolldirection" = false;
      };

      loginwindow = { GuestEnabled = false; };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };

      finder = {
        CreateDesktop = false;
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
      };

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 1.0;
        orientation = "left";
        showhidden = true;
        show-recents = false;
        static-only = false;
        tilesize = 56;
      };
    };
  };
  targets.darwin.dock = {
    apps = [ "Slack" "Firefox Developer Edition" "Google Chrome" "Obsidian" ];

    others = [({
      path = "${userConfig.home}/Downloads";
      sort = "dateadded";
      view = "grid";
    })];
  };

}
