{ pkgs, config, lib, ... }:
let
  inherit (lib) mkIf getExe;
  fishPath = getExe config.programs.fish.package;
  zshPath = getExe config.programs.zsh.package;
  isDarwin = pkgs.stdenv.isDarwin;
in {
  programs.ghostty = mkIf (!isDarwin) {
    enable = true;
    settings = {
      command = "${zshPath} -l -c ${fishPath}";
      font-family = "VictorMono Nerd Font Mono";
      font-size = 15;
      font-style = "SemiBold";
      font-style-bold = "Bold";
      font-style-italic = "SemiBold Italic";
      font-style-bold-italic = "Bold Italic";
      font-feature = "ss01,ss02,ss03,ss04,ss05,cv01,cv06";
      font-thicken = true;
      font-thicken-strength = 192;
      adjust-cell-height = "20%";
      theme = "light:catppuccin-latte,dark:catppuccin-mocha";
      window-padding-x = 20;
      window-padding-y = 20;
    };
  };
  home.file = mkIf (isDarwin || !(config.programs.ghostty.enable or false)) {
    ".config/ghostty/config".text = ''
      command = "${zshPath} -l -c ${fishPath}"
      font-family = "VictorMono Nerd Font Mono"
      font-size = 15
      font-style = SemiBold
      font-style-bold = Bold
      font-style-italic = SemiBold Italic
      font-style-bold-italic = Bold Italic
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
