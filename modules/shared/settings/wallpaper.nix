{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.settings.wallpaper;

  setWallpaper = file:
    if pkgs.stdenv.hostPlatform.isDarwin then
      ''
        /usr/bin/osascript -e 'tell application "Finder" to set desktop picture to POSIX file "${file}"' ''
    else
      ''echo "Unable to set wallpaper on ${pkgs.stdenv.hostPlatform.system}"'';
in
{
  options.settings.wallpaper = {
    enable = mkEnableOption "Enable automatic wallpaper setting";

    file = mkOption {
      type = types.path;
      description = "Path to image for wallpaper";
    };
  };

  config = mkIf cfg.enable {
    home.activation = {
      setDarwinWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ${setWallpaper cfg.file}
      '';
    };
  };
}
