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
  shared-programs = import ../shared/home-manager.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
in
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlays.default
      inputs.emacs-overlay.overlays.default
      inputs.nix-nvim.overlays.default
      (import ../../overlays/pinned.nix)
    ];
  };

  imports = [ ../shared ];

  home = {
    username = userConfig.name;
    homeDirectory = "/home/${userConfig.name}";

    sessionVariables = {
      EDITOR = "nvim";
      TERM = "xterm-256color";
    };

    packages =
      pkgs.callPackage ../shared/packages.nix { inherit pkgs; }
      ++ pkgs.callPackage ./packages.nix { inherit pkgs; }
      ++ [ pkgs.ghostty pkgs.wofi ];
  };

  programs = shared-programs // { };

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    theme = {
      name = "rose-pine";
      package = pkgs.rose-pine-gtk-theme;
    };
    iconTheme = {
      name = "rose-pine";
      package = pkgs.rose-pine-gtk-theme;
    };
  };

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  services = {
    emacs = {
      enable = true;
      package = pkgs.emacs-unstable;
    };
  };

  settings.ghostty.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "ghostty";
      menu = "wofi --show drun";

      input."*".xkb_layout = "us";

      startup = [ { command = "ghostty"; } ];

      keybindings =
        let mod = "Mod4";
        in lib.mkOptionDefault (
          {
            "${mod}+q" = "kill";
            "${mod}+f" = "fullscreen toggle";
            "${mod}+v" = "floating toggle";
          }
          // builtins.listToAttrs (builtins.genList (i: {
            name = "${mod}+${toString (i + 1)}";
            value = "workspace number ${toString (i + 1)}";
          }) 9)
          // builtins.listToAttrs (builtins.genList (i: {
            name = "${mod}+Shift+${toString (i + 1)}";
            value = "move container to workspace number ${toString (i + 1)}";
          }) 9)
        );

      gaps = {
        inner = 5;
        outer = 10;
      };

      bars = [ ];
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
    koji.enable = true;
  };

  home.stateVersion = "24.11";
}
