{ pkgs, config, lib, ... }:
let
  inherit (lib) mkIf getExe;
  nuPath = getExe config.programs.nushell.package;
  zshPath = getExe config.programs.zsh.package;
  isDarwin = pkgs.stdenv.isDarwin;
in {
  programs.ghostty = mkIf (!isDarwin) { enable = true; };
  home.file = mkIf (!(config.programs.ghostty.enable or false)) {
    ".config/ghostty/config".text = ''
      command = "${zshPath} -l -c ${nuPath}"
      font-family = "Maple Mono NF"
      font-size = 15
      font-thicken = true
      font-thicken-strength = 192
      adjust-cell-height = 20%
      theme = light:catppuccin-latte,dark:tokyonight_night
      window-padding-x = 20
      window-padding-y = 20
    '';
  };
}
