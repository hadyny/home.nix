{ config, lib, pkgs, ... }:
{
  home.sessionVariables = {
    NNN_FIFO = "/tmp/nnn.fifo";
    NNN_OPTS = "cdE";
    NNN_OPENER = "$HOME/.config/nnn/plugins/nuke";
    NNN_COLORS = "#04020301;4231";
    NNN_FCOLORS = "E5E5999707E1E108D39FE5D3";
  };
  programs = {
    nnn = {
      enable = true;
      package = pkgs.nnn.override ({ withNerdIcons = true; });

      bookmarks = {
        d = "~/Downloads";
        s = "~/src";
        w = "~/src/ep";
        h = "~/";
      };

      extraPackages = with pkgs; [
        bat
        eza
        fzf
        libarchive
        mediainfo
      ];
      plugins = {
        src = "${pkgs.nnn.src}/plugins";
        mappings = {
          c = "fzcd";
          f = "finder";
          o = "fzopen";
          p = "preview-tui";
        };
      };
    };
  };
}