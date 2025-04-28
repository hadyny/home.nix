{ config, lib, ... }: 

with lib;

{
  options.modules.kitty = { enable = mkEnableOption "Kitty terminal"; };

  config = mkIf config.modules.kitty.enable {
    programs.kitty = {
      enable = true;
      themeFile = "rose-pine-moon";

      font = {
        name = "CommitMono Regular";
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

        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";
      };
    };
    xdg.configFile = {
      "kitty/dark-theme.auto.conf".source = ./dark-theme.auto.conf;
      "kitty/light-theme.auto.conf".source = ./light-theme.auto.conf;
    };
  };
}
