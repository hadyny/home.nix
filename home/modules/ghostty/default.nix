{ ... }: {
  home.file = {
    ".config/ghostty/config".text = ''
      font-family = "VictorMono Nerd Font Mono"
      font-size = 14
      font-feature = 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'cv01', 'cv06'
      font-thicken = true
      font-thicken-strength = 192
      adjust-cell-height = 20%
      theme = light:catppuccin-latte,dark:catppuccin-mocha
      window-padding-x = 20
      window-padding-y = 20
    '';
  };
}
