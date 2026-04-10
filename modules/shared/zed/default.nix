{
  pkgs,
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.settings.zed;
in
{
  options.settings.zed = {
    enable = mkEnableOption "Enable Zed editor configuration";

    fontFamily = mkOption {
      type = types.str;
      default = "Maple Mono NF";
      description = "Font family to use in Zed";
    };

    fontSize = mkOption {
      type = types.number;
      default = 15;
      description = "Font size to use in Zed";
    };
  };

  config = mkIf cfg.enable {
    home.file.".config/zed/settings.json".text = builtins.toJSON {
      auto_install_extensions = {
        nix = true;
        lua = true;
        csharp = true;
        eslint = true;
        tailwindcss = true;
        rose-pine = true;
      };

      theme = {
        mode = "system";
        light = "Rosé Pine Dawn";
        dark = "Rosé Pine";
      };

      project_panel = {
        dock = "right";
      };

      vim_mode = true;

      buffer_font_family = cfg.fontFamily;
      buffer_font_size = cfg.fontSize;

      languages = {
        Nix = {
          language_servers = [
            "nil"
            "!nixd"
          ];
        };
        "C#" = {
          language_servers = [
            "roslyn"
            "!omnisharp"
          ];
        };
      };

      lsp = {
        nil = {
          binary = {
            path_lookup = true;
          };
        };
        roslyn = {
          binary = {
            path_lookup = true;
          };
        };
        tailwindcss-language-server = {
          binary = {
            path_lookup = true;
          };
        };
        typescript-language-server = {
          binary = {
            path_lookup = true;
          };
        };
        eslint = {
          binary = {
            path_lookup = true;
          };
        };
      };
    };
  };
}
