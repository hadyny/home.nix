{ pkgs, config, lib, ... }:

with lib;

let
  isDarwin = pkgs.stdenv.isDarwin;
  
  # Use a custom namespace for cross-platform ghostty config
  cfg = config.settings.ghostty;
in
{
  options.settings.ghostty = {
    enable = mkEnableOption "Enable Ghostty terminal emulator";

    fontFamily = mkOption {
      type = types.str;
      default = "Maple Mono NF";
      description = "Font family to use in Ghostty";
    };

    fontSize = mkOption {
      type = types.int;
      default = 15;
      description = "Font size to use in Ghostty";
    };

    fontThicken = mkOption {
      type = types.bool;
      default = true;
      description = "Enable font thickening";
    };

    fontThickenStrength = mkOption {
      type = types.int;
      default = 168;
      description = "Font thickening strength (0-255)";
    };

    adjustCellHeight = mkOption {
      type = types.str;
      default = "5%";
      description = "Adjust cell height";
    };

    theme = mkOption {
      type = types.str;
      default = "light:\"Rose Pine Dawn\",dark:\"Rose Pine\"";
      description = "Theme configuration";
    };

    windowPaddingX = mkOption {
      type = types.int;
      default = 20;
      description = "Horizontal window padding";
    };

    windowPaddingY = mkOption {
      type = types.int;
      default = 20;
      description = "Vertical window padding";
    };

    macosOptionAsAlt = mkOption {
      type = types.bool;
      default = true;
      description = "Use Option key as Alt on macOS";
    };

    command = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Command to run instead of the default shell";
    };
  };

  config = mkIf cfg.enable {
    home.file.".config/ghostty/config".text = ''
      font-family = "${cfg.fontFamily}"
      font-size = ${toString cfg.fontSize}
      font-thicken = ${boolToString cfg.fontThicken}
      font-thicken-strength = ${toString cfg.fontThickenStrength}
      adjust-cell-height = ${cfg.adjustCellHeight}
      theme = ${cfg.theme}
      window-padding-x = ${toString cfg.windowPaddingX}
      window-padding-y = ${toString cfg.windowPaddingY}
      macos-option-as-alt = ${boolToString cfg.macosOptionAsAlt}
      ${optionalString (cfg.command != null) "command = ${cfg.command}"}
      keybind = alt+left=unbind
      keybind = alt+right=unbind
    '';
  };
}
