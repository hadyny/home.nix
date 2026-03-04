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

  services = {
    emacs = {
      enable = true;
      package = pkgs.emacs-unstable;
    };
  };

  settings.ghostty.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",preferred,auto,1";

      env = [
        "WLR_RENDERER,pixman"
        "LIBGL_ALWAYS_SOFTWARE,1"
        "XDG_SESSION_TYPE,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
      ];

      exec-once = [ "ghostty" ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout = "dwindle";
      };

      decoration.rounding = 8;

      animations.enabled = false;

      input = {
        kb_layout = "us";
        follow_mouse = 1;
      };

      "$mod" = "SUPER";

      bind =
        [
          "$mod, Return, exec, ghostty"
          "$mod, Q, killactive"
          "$mod, D, exec, wofi --show drun"
          "$mod, F, fullscreen"
          "$mod, V, togglefloating"
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"
        ]
        ++ (builtins.genList (i: "$mod, ${toString (i + 1)}, workspace, ${toString (i + 1)}") 9)
        ++ (builtins.genList (i: "$mod SHIFT, ${toString (i + 1)}, movetoworkspace, ${toString (i + 1)}") 9);
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
