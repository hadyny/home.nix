{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf getExe;
  fishPath = getExe config.programs.fish.package;
  zshPath = getExe config.programs.zsh.package;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  programs.ghostty = mkIf (!isDarwin) { enable = true; };
  home.file = mkIf (!(config.programs.ghostty.enable or false)) {
    ".config/ghostty/config".text = ''
      command = "${zshPath} -l -c ${fishPath}"
      font-family = "Maple Mono NF"
      font-size = 15
      font-thicken = true
      font-thicken-strength = 192
      adjust-cell-height = 40%
      theme = light:"TokyoNight Day",dark:"TokyoNight Night"
      window-padding-x = 20
      window-padding-y = 20
    '';
  };
}
