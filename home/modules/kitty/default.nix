{ config, lib, ... }:

with lib;

{
  options.modules.kitty = { enable = mkEnableOption "Kitty terminal"; };

  config = mkIf config.modules.kitty.enable {
    programs.kitty = {
      enable = true;
      themeFile = "Catppuccin-Mocha";

      font = {
        name =
          "family='CommitMono Nerd Font' features='+ss01 +ss02 +ss03 +ss04 +ss05 +cv01 +cv06'";
        size = 14;
      };

      settings = {
        tab_bar_min_tabs = 1;
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template =
          "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";

        modify_font = "cell_height 120%";
        window_padding_width = 20;

        wayland_titlebar_color = "#2a273f";
        macos_titlebar_color = "#2a273f";

        regular_font =
          "family='CommitMono Nerd Font Regular' features='+ss01 +ss02 +ss03 +ss04 +ss05 +cv01 +cv06'";

        bold_font =
          "family='CommitMono Nerd Font Bold' features='+ss01 +ss02 +ss03 +ss04 +ss05 +cv01 +cv06'";
        italic_font =
          "family='CommitMono Nerd Font Italic' features='+ss01 +ss02 +ss03 +ss04 +ss05 +cv01 +cv06'";
        bold_italic_font =
          "family='CommitMono Nerd Font Bold Italic' features='+ss01 +ss02 +ss03 +ss04 +ss05 +cv01 +cv06'";
      };
    };
    xdg.configFile = {
      "kitty/dark-theme.auto.conf".source = ./dark-theme.auto.conf;
      "kitty/light-theme.auto.conf".source = ./light-theme.auto.conf;
    };
  };
}
