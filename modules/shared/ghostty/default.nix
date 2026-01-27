{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  programs.ghostty = mkIf (!isDarwin) { enable = true; };
  home.file = mkIf (!(config.programs.ghostty.enable or false)) {
    ".config/ghostty/config".text = ''
      font-family = "Maple Mono NF"
      font-size = 14
      font-thicken = true
      font-thicken-strength = 168
      adjust-cell-height = 25%
      theme = light:"TokyoNight Day",dark:"TokyoNight Night"
      window-padding-x = 20
      window-padding-y = 20
    '';
  };
}
