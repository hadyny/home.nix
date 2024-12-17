{ pkgs, lib, config, ... }:
{
  home-manager.users.${config.user.name}.home.file.".config/sketchybar/".source = ./sketchybar;
  services.sketchybar = {
    extraPackages = [
      pkgs.jq
      pkgs.gh
      pkgs.ripgrep
    ];
    enable = true;
  };
  launchd.user.agents.sketchybar = {
    serviceConfig = {
      StandardOutPath = "/tmp/sketchybar.log";
      StandardErrorPath = "/tmp/sketchybar.log";
    };
  };
}
