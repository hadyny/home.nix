{ config, lib, ... }:

with lib;

{
  options.modules.kitty = { enable = mkEnableOption "Kitty terminal"; };

  config = mkIf config.modules.kitty.enable {
    programs.kitty = {
      enable = true;
      themeFile = "Catppuccin-Mocha";
      extraConfig = builtins.readFile ./kitty.conf;
    };
    xdg.configFile = {
      "kitty/dark-theme.auto.conf".source = ./dark-theme.auto.conf;
      "kitty/light-theme.auto.conf".source = ./light-theme.auto.conf;
      "kitty/no-preference-theme.auto.conf".source = ./light-theme.auto.conf;
    };
  };
}
