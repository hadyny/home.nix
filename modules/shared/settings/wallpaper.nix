{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.settings.wallpaper;

  setWallpaper =
    file:
    if pkgs.stdenv.hostPlatform.isDarwin then
      ''
        $DRY_RUN_CMD /usr/bin/osascript \
          -e 'with timeout of 30 seconds' \
          -e 'tell application "System Events" to tell every desktop to set picture to POSIX file "${file}"' \
          -e 'end timeout' \
          || echo "Warning: failed to set desktop wallpaper (Finder/System Events unavailable or timed out); skipping." >&2
      ''
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
        ${setWallpaper cfg.file}
      '';
    };
  };
}
